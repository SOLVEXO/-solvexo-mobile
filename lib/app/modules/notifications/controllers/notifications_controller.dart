import 'package:book_store_app/app/data/models/common_models/notification_model.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final RxList<NotificationModel> _all = <NotificationModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  String _role = 'user';

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter.value == 'all') return List.unmodifiable(_all);
    return _all.where((n) => n.filterKey == selectedFilter.value).toList();
  }

  int get unreadCount => _all.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    _role = await AppPreferences.getUserRole() ?? 'user';
    await Future.delayed(const Duration(milliseconds: 500));
    _all.assignAll(_role == 'seller' ? _sellerMock() : _buyerMock());
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => fetchNotifications();

  void setFilter(String filter) => selectedFilter.value = filter;

  void markRead(String id) {
    final idx = _all.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _all[idx] = _all[idx].copyWith(isRead: true);
      _all.refresh();
    }
  }

  void markAllRead() {
    for (int i = 0; i < _all.length; i++) {
      _all[i] = _all[i].copyWith(isRead: true);
    }
    _all.refresh();
  }

  // ── Mock data (swap for API call) ─────────────────────────────────────────

  List<NotificationModel> _buyerMock() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Order Confirmed',
        body: 'Your order #ORD-2024 has been placed successfully.',
        type: NotificationType.order,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        title: 'Order Shipped',
        body: 'Your order #ORD-2023 is on its way via DHL. Track: TRK12345.',
        type: NotificationType.order,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '3',
        title: 'Seller Replied',
        body: '"Yes, we have it in blue as well — order before stock runs out!"',
        type: NotificationType.message,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        id: '4',
        title: 'Flash Sale — 40% Off',
        body: 'Limited time: 40% off all electronics until midnight tonight.',
        type: NotificationType.promo,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: '5',
        title: 'Order Delivered',
        body: 'Your order #ORD-2022 has been delivered. Enjoy your purchase!',
        type: NotificationType.order,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '6',
        title: 'Leave a Review',
        body: 'How was your recent order? Share your experience and earn coins.',
        type: NotificationType.system,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      NotificationModel(
        id: '7',
        title: 'New Arrivals for You',
        body: 'Products just dropped in categories you love. Check them out!',
        type: NotificationType.promo,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationModel(
        id: '8',
        title: 'App Updated',
        body: 'Solvexo v2.5 is here with faster checkout and new features.',
        type: NotificationType.system,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  List<NotificationModel> _sellerMock() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 's1',
        title: 'New Order Received',
        body: 'Order #ORD-5091 just came in — 2x Cotton Tee, 1x Hoodie.',
        type: NotificationType.order,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      NotificationModel(
        id: 's2',
        title: 'Low Stock Alert',
        body: '"Classic Sneakers (Size 42)" has only 2 units left.',
        type: NotificationType.system,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: 's3',
        title: 'New Buyer Message',
        body: 'Ahmed K.: "Can I get a custom colour on the leather wallet?"',
        type: NotificationType.message,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: 's4',
        title: 'Product Review',
        body: 'Your product "Wireless Earbuds" received a 5-star review.',
        type: NotificationType.system,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 's5',
        title: 'Order Cancelled',
        body: 'Buyer cancelled order #ORD-5088. Reason: Wrong size.',
        type: NotificationType.order,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      NotificationModel(
        id: 's6',
        title: 'Solvexo Tips',
        body: 'Sellers with 10+ reviews get 2x more visibility. Start today!',
        type: NotificationType.promo,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 's7',
        title: 'Payout Processed',
        body: 'PKR 24,500 has been transferred to your registered account.',
        type: NotificationType.system,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
