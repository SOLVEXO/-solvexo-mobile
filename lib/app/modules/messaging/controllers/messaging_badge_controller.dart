import 'dart:async';

import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

/// App-wide singleton (via `Get.put`, reused across rebuilds — see
/// `GetInstance._insert`, which no-ops if already registered) that keeps a
/// buyer's total unread-message count fresh for the `MainAppBar` badge.
///
/// There is no WebSocket layer in `solvexo-api`'s messaging module, so this
/// polls periodically instead of pushing — good enough for a badge count
/// that doesn't need sub-second accuracy.
class MessagingBadgeController extends GetxController {
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
    if (!await AppPreferences.isLoggedIn()) {
      unreadCount.value = 0;
      return;
    }
    final result = await _repo.getConversations(page: 1, limit: 50);
    unreadCount.value = result.conversations.fold<int>(
      0,
      (sum, c) => sum + c.unreadFor('user'),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
