import 'dart:async';
import 'dart:io';

import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/models/messaging/message_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A single conversation thread — shared by both the buyer and seller sides
/// (both navigate to `Routes.chatView`); which bubbles align left/right is
/// purely a function of `senderId == myUserId`, so one implementation covers
/// both roles.
class ChatController extends GetxController {
  final MessagingRepository _repo = MessagingRepository();

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

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? _nextCursor;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 4);

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
    _pollTimer = Timer.periodic(_pollInterval, (_) => loadMessages(silent: true));
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
      final newOnes = result.messages.where((m) => !existingIds.contains(m.id)).toList();
      if (newOnes.isNotEmpty) messages.addAll(newOnes);
    }

    await _markLatestSeen();
  }

  Future<void> loadOlderMessages() async {
    if (!hasOlder.value || isLoadingOlder.value) return;
    isLoadingOlder.value = true;
    final result = await _repo.getMessages(conversationId, before: _nextCursor, limit: 30);
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
    await _repo.markSeen(conversationId: conversationId, lastMessageId: lastFromOther.id);
  }

  Future<void> sendText() async {
    final text = textController.text.trim();
    if (text.isEmpty || isSending.value || isBlocked) return;

    textController.clear();
    isSending.value = true;
    final msg = await _repo.sendMessage(conversationId, type: 'text', text: text);
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
    final ok = await _repo.blockUser(targetId: targetId, targetRole: targetRole);
    if (ok) {
      ToastUtil.showToast('Blocked — you will no longer receive messages from them.');
      conversation.value = await _repo.getConversationById(conversationId);
    }
  }

  Future<void> reportConversation(String reason) async {
    final ok = await _repo.reportTarget(
      targetType: 'conversation',
      targetId: conversationId,
      reason: reason,
    );
    if (ok) ToastUtil.showToast('Reported. Our team will review this conversation.');
  }
}
