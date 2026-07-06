import 'dart:async';

import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

/// App-wide singleton (via `Get.put`, reused across rebuilds) that keeps the
/// active store's total unread-message count fresh for the `SellerAppBar`
/// badge. Polling-based — see `MessagingBadgeController` (buyer side) for
/// why: `solvexo-api`'s messaging module has no WebSocket layer.
class SellerMessagingBadgeController extends GetxController {
  final MessagingRepository _repo = MessagingRepository();

  final RxInt unreadCount = 0.obs;

  Timer? _timer;
  static const _pollInterval = Duration(seconds: 20);

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();
    _timer = Timer.periodic(_pollInterval, (_) => refreshUnreadCount());
  }

  Future<void> refreshUnreadCount() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) {
      unreadCount.value = 0;
      return;
    }
    final result = await _repo.getConversations(page: 1, limit: 50, storeId: storeId);
    unreadCount.value = result.conversations.fold<int>(
      0,
      (sum, c) => sum + c.unreadFor('seller'),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
