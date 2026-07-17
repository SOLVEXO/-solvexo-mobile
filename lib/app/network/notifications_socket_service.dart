import 'dart:async';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Realtime layer for `solvexo-api`'s `NotificationsGateway` (Socket.IO,
/// namespace `/notifications`). Mirrors `MessagingSocketService`:
/// authenticates via the JWT in the handshake `auth.token`, the gateway
/// auto-joins the personal `user:{userId}` room, and pushes `notification:new`
/// / `notification:unread-count` while the app is foregrounded. Background /
/// killed-app delivery goes through FCM instead (see FcmService).
class NotificationsSocketService extends GetxService {
  io.Socket? _socket;
  final RxBool isConnected = false.obs;
  bool _connecting = false;

  final _newNotification = StreamController<Map<String, dynamic>>.broadcast();
  final _unreadCount = StreamController<int>.broadcast();

  Stream<Map<String, dynamic>> get onNewNotification => _newNotification.stream;
  Stream<int> get onUnreadCount => _unreadCount.stream;

  static NotificationsSocketService get instance {
    if (!Get.isRegistered<NotificationsSocketService>()) {
      Get.put(NotificationsSocketService(), permanent: true);
    }
    return Get.find<NotificationsSocketService>();
  }

  Future<void> ensureConnected() async {
    if (_connecting || _socket?.connected == true) return;
    if (!await AppPreferences.isLoggedIn()) return;

    final token = await AppPreferences.getAccessTokenAsync();
    if (token == null || token.isEmpty) return;
    _connecting = true;

    _socket?.dispose();

    final socket = io.io(
      '${ApiConstants.baseUrl}/notifications',
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
    });
    socket.onDisconnect((_) => isConnected.value = false);
    socket.onConnectError((e) {
      _connecting = false;
      debugPrint('🔔 notifications socket connect error: $e');
    });

    socket.on('notification:new', (data) {
      if (data is Map) _newNotification.add(Map<String, dynamic>.from(data));
    });
    socket.on('notification:unread-count', (data) {
      if (data is Map && data['unreadCount'] != null) {
        _unreadCount.add(data['unreadCount'] as int);
      }
    });

    socket.connect();
  }

  /// Call on logout — tears the socket down so the next login reconnects
  /// with the new user's token.
  void disconnect() {
    _connecting = false;
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    _newNotification.close();
    _unreadCount.close();
    super.onClose();
  }
}
