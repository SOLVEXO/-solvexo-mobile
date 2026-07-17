import 'dart:async';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Realtime layer for `solvexo-api`'s `MessagingGateway` (Socket.IO,
/// namespace `/messaging`). Authenticates via the JWT in the handshake
/// `auth.token`; the gateway auto-joins the personal `user:{userId}` room,
/// and each open thread joins `conversation:{id}` for message-level events.
///
/// The existing polling timers stay in place as a fallback — controllers
/// skip silent polls while [isConnected] is true, so a dropped socket
/// degrades back to the old polling behaviour instead of going silent.
class MessagingSocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;
  bool _connecting = false;

  // Conversations the current screen(s) want to be in — re-joined after every
  // reconnect, since Socket.IO room membership doesn't survive a new socket id.
  final Set<String> _joinedConversations = {};

  final _newMessage = StreamController<Map<String, dynamic>>.broadcast();
  final _messageEdited = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeleted = StreamController<Map<String, dynamic>>.broadcast();
  final _messagesSeen = StreamController<Map<String, dynamic>>.broadcast();
  final _conversationUpdate = StreamController<Map<String, dynamic>>.broadcast();
  final _typing = StreamController<Map<String, dynamic>>.broadcast();
  final _joined = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage => _newMessage.stream;
  Stream<Map<String, dynamic>> get onMessageEdited => _messageEdited.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _messageDeleted.stream;
  Stream<Map<String, dynamic>> get onMessagesSeen => _messagesSeen.stream;
  Stream<Map<String, dynamic>> get onConversationUpdate => _conversationUpdate.stream;
  Stream<Map<String, dynamic>> get onTyping => _typing.stream;
  Stream<Map<String, dynamic>> get onJoined => _joined.stream;

  static MessagingSocketService get instance {
    if (!Get.isRegistered<MessagingSocketService>()) {
      Get.put(MessagingSocketService(), permanent: true);
    }
    return Get.find<MessagingSocketService>();
  }

  /// Connects (or no-ops if already connected). Safe to call from every
  /// messaging screen's onInit.
  Future<void> ensureConnected() async {
    // `_connecting` guards the window where several controllers init at once
    // (badge + inbox + chat) — without it each call would dispose the
    // in-flight socket and start over.
    if (_connecting || _socket?.connected == true) return;
    if (!await AppPreferences.isLoggedIn()) return;

    final token = await AppPreferences.getAccessTokenAsync();
    if (token == null || token.isEmpty) return;
    _connecting = true;

    // A stale disconnected socket keeps its old (possibly expired) token —
    // rebuild instead of reusing so reconnects always carry a fresh JWT.
    _socket?.dispose();

    final socket = io.io(
      '${ApiConstants.baseUrl}/messaging',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      _connecting = false;
      isConnected.value = true;
      for (final id in _joinedConversations) {
        socket.emit('join-conversation', id);
      }
    });
    socket.onDisconnect((_) => isConnected.value = false);
    socket.onConnectError((e) {
      // Cleared so the next ensureConnected() can rebuild with a fresh token
      // (auto-reconnect reuses the handshake auth from connect time).
      _connecting = false;
      debugPrint('💬 socket connect error: $e');
    });

    void pipe(String event, StreamController<Map<String, dynamic>> sink) {
      socket.on(event, (data) {
        if (data is Map) sink.add(Map<String, dynamic>.from(data));
      });
    }

    pipe('message:new', _newMessage);
    pipe('message:edited', _messageEdited);
    pipe('message:deleted', _messageDeleted);
    pipe('message:seen', _messagesSeen);
    pipe('conversation:update', _conversationUpdate);
    pipe('typing', _typing);
    pipe('messaging:joined', _joined);

    socket.connect();
  }

  void joinConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    _joinedConversations.add(conversationId);
    if (_socket?.connected == true) {
      _socket!.emit('join-conversation', conversationId);
    }
  }

  void leaveConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    _joinedConversations.remove(conversationId);
    if (_socket?.connected == true) {
      _socket!.emit('leave-conversation', conversationId);
    }
  }

  void sendTyping(String conversationId, bool isTyping) {
    if (_socket?.connected != true) return;
    _socket!.emit('typing', {'conversationId': conversationId, 'isTyping': isTyping});
  }

  /// Live online/offline pushes for one user (the gateway broadcasts
  /// `presence:{userId}` on their first connect / last disconnect).
  /// Returns a cleanup function that removes the listener.
  VoidCallback subscribePresence(String userId, void Function(bool online) onChange) {
    final socket = _socket;
    if (socket == null || userId.isEmpty) return () {};
    void handler(dynamic data) {
      if (data is Map) onChange(data['online'] == true);
    }

    socket.on('presence:$userId', handler);
    return () => socket.off('presence:$userId', handler);
  }

  /// Call on logout — tears the socket down so the next login reconnects
  /// with the new user's token.
  void disconnect() {
    _connecting = false;
    _joinedConversations.clear();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    _newMessage.close();
    _messageEdited.close();
    _messageDeleted.close();
    _messagesSeen.close();
    _conversationUpdate.close();
    _typing.close();
    _joined.close();
    super.onClose();
  }
}
