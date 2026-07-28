import 'dart:async';

import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/network/notifications_socket_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

/// App-wide singleton (via `Get.put`, reused across rebuilds) that keeps the
/// unread-notification count fresh for the bell-icon badge on both the
/// buyer (`MainAppBar`, `HomeGreetingHeader`) and seller (`SellerAppBar`)
/// headers — mirrors `MessagingBadgeController`.
///
/// Primary signal is the `NotificationsGateway` socket's
/// `notification:unread-count` push; the poll timer stays as a fallback for
/// when the socket is down.
class NotificationsBadgeController extends GetxController {
  final NotificationsRepository _repo = NotificationsRepository();

  final RxInt unreadCount = 0.obs;

  Timer? _timer;
  static const _pollInterval = Duration(seconds: 20);

  final NotificationsSocketService _socket = NotificationsSocketService.instance;
  StreamSubscription? _countSub;
  StreamSubscription? _newSub;

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();
    _timer = Timer.periodic(_pollInterval, (_) {
      if (!_socket.isConnected.value) refreshUnreadCount();
    });
    _socket.ensureConnected();
    _countSub = _socket.onUnreadCount.listen((count) => unreadCount.value = count);
    _newSub = _socket.onNewNotification.listen((_) => unreadCount.value += 1);
  }

  Future<void> refreshUnreadCount() async {
    if (!await AppPreferences.isLoggedIn()) {
      unreadCount.value = 0;
      return;
    }
    unreadCount.value = await _repo.unreadCount();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _countSub?.cancel();
    _newSub?.cancel();
    super.onClose();
  }
}
