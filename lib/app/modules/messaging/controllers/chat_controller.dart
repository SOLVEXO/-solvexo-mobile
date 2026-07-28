import 'dart:async';
import 'dart:io';

import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/models/messaging/message_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/network/messaging_socket_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A single conversation thread — shared by both the buyer and seller sides
/// (both navigate to `Routes.chatView`); which bubbles align left/right is
/// purely a function of `senderId == myUserId`, so one implementation covers
/// both roles.
class ChatController extends GetxController {
  ChatController({
    MessagingRepository? repository,
    MessagingSocketService? socketService,
  }) : _repo = repository ?? MessagingRepository(),
       _socket = socketService ?? MessagingSocketService.instance;

  final MessagingRepository _repo;

  late final String conversationId;
  late final String initialPeerName;
  final Rxn<String> peerAvatar = Rxn<String>();

  String myUserId = '';
  String myRole = 'user';

  final Rxn<ConversationModel> conversation = Rxn<ConversationModel>();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool isLoadingOlder = false.obs;
  final RxBool hasOlder = false.obs;

  // Realtime (MessagingGateway) — typing + online state of the other party.
  final RxBool peerIsTyping = false.obs;
  final RxBool peerIsOnline = false.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? _nextCursor;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 4);

  final MessagingSocketService _socket;
  final List<StreamSubscription> _socketSubs = [];
  VoidCallback? _presenceCleanup;
  Timer? _typingStopTimer;
  Timer? _peerTypingTimeout;
  bool _sentTyping = false;

  @override
  void onInit() {
    super.onInit();
    _readArgs();
    _init();
    // The list is rendered with `reverse: true` (newest message pinned to
    // the bottom, matching a normal chat) so "near the top" (older history)
    // is the *far* end of the scroll extent, not offset 0.
    scrollController.addListener(() {
      final position = scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200) {
        loadOlderMessages();
      }
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _typingStopTimer?.cancel();
    _peerTypingTimeout?.cancel();
    if (_sentTyping) _socket.sendTyping(conversationId, false);
    _presenceCleanup?.call();
    for (final sub in _socketSubs) {
      sub.cancel();
    }
    _socket.leaveConversation(conversationId);
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _readArgs() {
    final args = Get.arguments;
    final map = args is Map ? args : const {};
    conversationId = map['conversationId'] as String? ?? '';
    initialPeerName = map['peerName'] as String? ?? 'Chat';
    peerAvatar.value = map['peerAvatar'] as String?;
  }

  Future<void> _init() async {
    myUserId = await AppPreferences.getUserId() ?? '';
    myRole = await AppPreferences.getUserRole() ?? 'user';

    if (conversationId.isEmpty) {
      isLoading.value = false;
      return;
    }

    conversation.value = await _repo.getConversationById(conversationId);
    if (conversation.value != null) {
      peerAvatar.value ??= conversation.value!.peerAvatar(myRole);
    }

    await loadMessages(initial: true);
    // Polling stays as a fallback: silent polls no-op while the socket is
    // live, so a dropped connection degrades to the old 4s refresh.
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_socket.isConnected.value) loadMessages(silent: true);
    });

    await _connectRealtime();
  }

  // ── Realtime (Socket.IO /messaging) ──────────────────────────────────────

  Future<void> _connectRealtime() async {
    // Listeners first — if the socket is already live, `join-conversation`
    // answers with `messaging:joined` immediately and we'd miss it otherwise.
    _socketSubs.add(
      _socket.onNewMessage.listen((data) {
        final msg = MessageModel.fromJson(data);
        if (msg.conversationId != conversationId) return;
        if (messages.any((m) => m.id == msg.id)) return;
        messages.add(msg);
        if (msg.senderId != myUserId) {
          _peerTypingTimeout?.cancel();
          peerIsTyping.value = false;
          _repo.markSeen(conversationId: conversationId, lastMessageId: msg.id);
        }
      }),
    );

    _socketSubs.add(
      _socket.onMessageEdited.listen((data) {
        final msg = MessageModel.fromJson(data);
        if (msg.conversationId != conversationId) return;
        final index = messages.indexWhere((m) => m.id == msg.id);
        if (index != -1) messages[index] = msg;
      }),
    );

    _socketSubs.add(
      _socket.onMessageDeleted.listen((data) {
        final messageId = (data['messageId'] ?? '').toString();
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index == -1) return;
        final m = messages[index];
        messages[index] = MessageModel(
          id: m.id,
          conversationId: m.conversationId,
          senderId: m.senderId,
          senderRole: m.senderRole,
          type: m.type,
          text: m.text,
          attachments: m.attachments,
          productShare: m.productShare,
          replyTo: m.replyTo,
          status: m.status,
          seenByUserIds: m.seenByUserIds,
          isEdited: m.isEdited,
          isDeleted: true,
          deletedByUsers: m.deletedByUsers,
          createdAt: m.createdAt,
        );
      }),
    );

    _socketSubs.add(
      _socket.onMessagesSeen.listen((data) {
        if ((data['conversationId'] ?? '').toString() != conversationId) return;
        if ((data['userId'] ?? '').toString() == myUserId) return;
        // The peer read the thread — flip my messages to 'seen'.
        for (var i = 0; i < messages.length; i++) {
          final m = messages[i];
          if (m.senderId != myUserId || m.status == 'seen') continue;
          messages[i] = MessageModel(
            id: m.id,
            conversationId: m.conversationId,
            senderId: m.senderId,
            senderRole: m.senderRole,
            type: m.type,
            text: m.text,
            attachments: m.attachments,
            productShare: m.productShare,
            replyTo: m.replyTo,
            status: 'seen',
            seenByUserIds: m.seenByUserIds,
            isEdited: m.isEdited,
            isDeleted: m.isDeleted,
            deletedByUsers: m.deletedByUsers,
            createdAt: m.createdAt,
          );
        }
        messages.refresh();
      }),
    );

    _socketSubs.add(
      _socket.onTyping.listen((data) {
        if ((data['conversationId'] ?? '').toString() != conversationId) return;
        if ((data['userId'] ?? '').toString() == myUserId) return;
        final isTyping = data['isTyping'] == true;
        peerIsTyping.value = isTyping;
        _peerTypingTimeout?.cancel();
        if (isTyping) {
          // Safety net in case the peer's "stopped typing" event never arrives.
          _peerTypingTimeout = Timer(const Duration(seconds: 6), () {
            peerIsTyping.value = false;
          });
        }
      }),
    );

    _socketSubs.add(
      _socket.onJoined.listen((data) {
        if ((data['conversationId'] ?? '').toString() != conversationId) return;
        peerIsOnline.value = data['otherOnline'] == true;
        final otherUserId = (data['otherUserId'] ?? '').toString();
        _presenceCleanup?.call();
        _presenceCleanup = _socket.subscribePresence(otherUserId, (online) {
          peerIsOnline.value = online;
        });
      }),
    );

    await _socket.ensureConnected();
    _socket.joinConversation(conversationId);
  }

  /// Hook for the input bar's onChanged — emits `typing: true` immediately
  /// and `typing: false` after 2.5s of inactivity.
  void onInputChanged(String value) {
    if (value.trim().isEmpty) {
      _stopTyping();
      return;
    }
    if (!_sentTyping) {
      _sentTyping = true;
      _socket.sendTyping(conversationId, true);
    }
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(milliseconds: 2500), _stopTyping);
  }

  void _stopTyping() {
    _typingStopTimer?.cancel();
    if (_sentTyping) {
      _sentTyping = false;
      _socket.sendTyping(conversationId, false);
    }
  }

  bool get isBlocked => conversation.value?.isBlocked(myRole) ?? false;

  // ── Messages ─────────────────────────────────────────────────────────────

  Future<void> loadMessages({bool initial = false, bool silent = false}) async {
    if (initial) isLoading.value = true;
    final result = await _repo.getMessages(conversationId, limit: 30);

    if (initial) {
      messages.assignAll(result.messages);
      _nextCursor = result.nextCursor;
      hasOlder.value = result.hasMore;
      isLoading.value = false;
    } else {
      final existingIds = messages.map((m) => m.id).toSet();
      final newOnes = result.messages
          .where((m) => !existingIds.contains(m.id))
          .toList();
      if (newOnes.isNotEmpty) messages.addAll(newOnes);
    }

    await _markLatestSeen();
  }

  Future<void> loadOlderMessages() async {
    if (!hasOlder.value || isLoadingOlder.value) return;
    isLoadingOlder.value = true;
    final result = await _repo.getMessages(
      conversationId,
      before: _nextCursor,
      limit: 30,
    );
    messages.insertAll(0, result.messages);
    _nextCursor = result.nextCursor;
    hasOlder.value = result.hasMore;
    isLoadingOlder.value = false;
  }

  Future<void> _markLatestSeen() async {
    if (messages.isEmpty) return;
    MessageModel? lastFromOther;
    for (final m in messages.reversed) {
      if (m.senderId != myUserId) {
        lastFromOther = m;
        break;
      }
    }
    if (lastFromOther == null) return;
    await _repo.markSeen(
      conversationId: conversationId,
      lastMessageId: lastFromOther.id,
    );
  }

  Future<void> sendText() async {
    final text = textController.text.trim();
    if (text.isEmpty || isSending.value || isBlocked) return;

    textController.clear();
    _stopTyping();
    isSending.value = true;
    final msg = await _repo.sendMessage(
      conversationId,
      type: 'text',
      text: text,
    );
    isSending.value = false;

    if (msg != null) {
      messages.add(msg);
    } else {
      textController.text = text;
    }
  }

  Future<void> sendImage(File file) async {
    if (isSending.value || isBlocked) return;
    isSending.value = true;
    final attachment = await _repo.uploadAttachment(conversationId, file);
    if (attachment != null) {
      final msg = await _repo.sendMessage(
        conversationId,
        type: 'image',
        attachments: [attachment.toJson()],
      );
      if (msg != null) messages.add(msg);
    }
    isSending.value = false;
  }

  // ── Moderation ───────────────────────────────────────────────────────────

  Future<void> blockPeer() async {
    final conv = conversation.value;
    if (conv == null) return;
    final targetId = myRole == 'seller' ? conv.buyerId : conv.sellerId;
    final targetRole = myRole == 'seller' ? 'user' : 'seller';
    final ok = await _repo.blockUser(
      targetId: targetId,
      targetRole: targetRole,
    );
    if (ok) {
      ToastUtil.showToast(
        'Blocked — you will no longer receive messages from them.',
      );
      conversation.value = await _repo.getConversationById(conversationId);
    }
  }

  Future<void> reportConversation(String reason) async {
    final ok = await _repo.reportTarget(
      targetType: 'conversation',
      targetId: conversationId,
      reason: reason,
    );
    if (ok)
      ToastUtil.showToast('Reported. Our team will review this conversation.');
  }
}
