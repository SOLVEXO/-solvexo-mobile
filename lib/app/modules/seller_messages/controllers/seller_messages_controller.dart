import 'dart:async';

import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

enum InboxFilter { active, archived }

/// The seller's message inbox for their active store — buyer conversations,
/// scoped by `storeId` (backend requirement for the seller role) with
/// archive/pin/mute inbox management the buyer side doesn't get.
class SellerMessagesController extends GetxController {
  final MessagingRepository _repo = MessagingRepository();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final Rx<InboxFilter> filter = InboxFilter.active.obs;
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  List<ConversationModel> get filteredConversations {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return conversations;
    return conversations.where((c) => c.peerName('seller').toLowerCase().contains(q)).toList();
  }

  int get totalUnread => conversations.fold(0, (sum, c) => sum + c.unreadFor('seller'));

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    await loadConversations();
    _pollTimer = Timer.periodic(_pollInterval, (_) => loadConversations(silent: true));
  }

  Future<void> loadConversations({bool silent = false}) async {
    if (storeId.isEmpty) {
      isLoading.value = false;
      return;
    }
    if (!silent) isLoading.value = true;
    final result = await _repo.getConversations(
      page: 1,
      limit: 50,
      storeId: storeId,
      isArchived: filter.value == InboxFilter.archived,
    );
    // Pinned conversations float to the top, preserving the backend's
    // activity-based order within each group (List.sort isn't stable).
    final pinned = result.conversations.where((c) => c.isPinned).toList();
    final rest = result.conversations.where((c) => !c.isPinned).toList();
    conversations.assignAll([...pinned, ...rest]);
    isLoading.value = false;
  }

  void onSearch(String value) => searchQuery.value = value;

  void setFilter(InboxFilter value) {
    if (filter.value == value) return;
    filter.value = value;
    loadConversations();
  }

  void openChat(ConversationModel c) {
    Get.toNamed(Routes.chatView, arguments: {
      'conversationId': c.id,
      'peerName': c.peerName('seller'),
      'peerAvatar': c.peerAvatar('seller'),
    });
  }

  // ── Inbox management ─────────────────────────────────────────────────────

  Future<void> togglePin(ConversationModel c) async {
    final newValue = !c.isPinned;
    await _repo.setPinned(c.id, newValue);
    ToastUtil.showToast(newValue ? 'Pinned to top' : 'Unpinned');
    loadConversations(silent: true);
  }

  Future<void> toggleMute(ConversationModel c) async {
    final newValue = !c.isMuted;
    await _repo.setMuted(c.id, newValue);
    ToastUtil.showToast(newValue ? 'Conversation muted' : 'Conversation unmuted');
    loadConversations(silent: true);
  }

  Future<void> toggleArchive(ConversationModel c) async {
    final newValue = !c.isArchived;
    await _repo.setArchived(c.id, newValue);
    ToastUtil.showToast(newValue ? 'Archived' : 'Restored to inbox');
    loadConversations(silent: true);
  }

  Future<void> deleteConversation(ConversationModel c) async {
    final ok = await _repo.deleteConversation(c.id);
    if (ok) {
      conversations.removeWhere((e) => e.id == c.id);
      ToastUtil.showToast('Conversation removed');
    }
  }
}
