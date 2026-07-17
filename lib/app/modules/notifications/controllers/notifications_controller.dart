import 'dart:async';

import 'package:book_store_app/app/data/models/common_models/notification_model.dart';
import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/network/notifications_socket_service.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository _repository = NotificationsRepository();
  final NotificationsSocketService _socket = NotificationsSocketService.instance;
  StreamSubscription? _newSub;
  StreamSubscription? _countSub;

  final RxList<NotificationModel> _all = <NotificationModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter.value == 'all') return List.unmodifiable(_all);
    return _all.where((n) => n.filterKey == selectedFilter.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _socket.ensureConnected();
    _newSub = _socket.onNewNotification.listen((json) {
      _all.insert(0, NotificationModel.fromJson(json));
    });
    _countSub = _socket.onUnreadCount.listen((count) => unreadCount.value = count);
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    final result = await _repository.list();
    _all.assignAll(result.items);
    unreadCount.value = result.unreadCount;
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => fetchNotifications();

  void setFilter(String filter) => selectedFilter.value = filter;

  Future<void> markRead(String id) async {
    final idx = _all.indexWhere((n) => n.id == id);
    if (idx < 0 || _all[idx].isRead) return;
    _all[idx] = _all[idx].copyWith(isRead: true);
    _all.refresh();
    unreadCount.value = (unreadCount.value - 1).clamp(0, 1 << 30);
    await _repository.markRead(id);
  }

  Future<void> markAllRead() async {
    for (int i = 0; i < _all.length; i++) {
      _all[i] = _all[i].copyWith(isRead: true);
    }
    _all.refresh();
    unreadCount.value = 0;
    await _repository.markAllRead();
  }

  @override
  void onClose() {
    _newSub?.cancel();
    _countSub?.cancel();
    super.onClose();
  }
}
