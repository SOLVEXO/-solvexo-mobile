import 'dart:async';

import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/network/messaging_socket_service.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Buyer's message inbox — lists every store conversation they've started.
class ConversationsController extends GetxController {
  ConversationsController({
    MessagingRepository? repository,
    MessagingSocketService? socketService,
  }) : _repo = repository ?? MessagingRepository(),
       _socket = socketService ?? MessagingSocketService.instance;

  final MessagingRepository _repo;

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final RxBool unreadOnly = false.obs;

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  final MessagingSocketService _socket;
  StreamSubscription? _updateSub;

  List<ConversationModel> get filteredConversations {
    var result = conversations.toList();
    if (unreadOnly.value) {
      result = result.where((c) => c.unreadFor('user') > 0).toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (c) =>
                c.peerName('user').toLowerCase().contains(q) ||
                (c.lastMessage?.previewText.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return result;
  }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadFor('user'));

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    // Poll only while the realtime socket is down — `conversation:update`
    // pushes (MessagingGateway) reorder the inbox instantly otherwise.
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (!_socket.isConnected.value) loadConversations(silent: true);
    });
    _socket.ensureConnected();
    _updateSub = _socket.onConversationUpdate.listen(
      (_) => loadConversations(silent: true),
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _updateSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadConversations({bool silent = false}) async {
    // Messaging is a login-only feature — a guest opening the inbox gets a
    // clear reason it's empty, not a raw 401. Only the initial (non-silent)
    // load toasts; the background poll/socket refresh must stay quiet.
    if (!await AppPreferences.isLoggedIn()) {
      if (!silent) ToastUtil.showToast('Login to view your messages');
      isLoading.value = false;
      return;
    }
    if (!silent) isLoading.value = true;
    final result = await _repo.getConversations(page: 1, limit: 50);
    // Pinned conversations float to the top, same convention as the seller inbox.
    final pinned = result.conversations.where((c) => c.isPinned).toList();
    final rest = result.conversations.where((c) => !c.isPinned).toList();
    conversations.assignAll([...pinned, ...rest]);
    isLoading.value = false;
  }

  void onSearch(String value) => searchQuery.value = value;

  void setUnreadOnly(bool value) => unreadOnly.value = value;

  void openChat(ConversationModel c) {
    Get.toNamed(
      Routes.chatView,
      arguments: {
        'conversationId': c.id,
        'peerName': c.peerName('user'),
        'peerAvatar': c.peerAvatar('user'),
      },
    );
  }
}
