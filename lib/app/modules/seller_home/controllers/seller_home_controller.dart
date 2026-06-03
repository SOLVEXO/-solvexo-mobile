import 'package:get/get.dart';

class SellerMessage {
  final String id;
  final String senderName;
  final String preview;
  final String timeAgo;
  final bool isUnread;

  const SellerMessage({
    required this.id,
    required this.senderName,
    required this.preview,
    required this.timeAgo,
    this.isUnread = false,
  });

  String get initials {
    final parts = senderName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

class SellerHomeController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxDouble todayRevenue = 1284.00.obs;
  final RxDouble revenueChange = 12.4.obs;
  final RxInt ordersCount = 38.obs;
  final RxString visitors = '2.1K'.obs;
  final RxDouble conversionRate = 1.78.obs;
  final RxDouble avgOrderValue = 33.79.obs;

  final RxList<Map<String, dynamic>> recentOrders = <Map<String, dynamic>>[
    {'id': '#8821', 'customer': 'Sarah M.', 'amount': 49.00, 'status': 'Paid'},
    {'id': '#8820', 'customer': 'John D.', 'amount': 125.50, 'status': 'Processing'},
    {'id': '#8819', 'customer': 'Emma L.', 'amount': 67.00, 'status': 'Shipped'},
  ].obs;

  final RxList<String> lowStockItems =
      <String>['Wall Hanging', 'Candle', 'Photo Book'].obs;

  final RxList<SellerMessage> messages = <SellerMessage>[
    SellerMessage(
      id: '1',
      senderName: 'Sarah M.',
      preview: 'Hi! Does the Math Bundle include answer k...',
      timeAgo: '2m ago',
      isUnread: true,
    ),
    SellerMessage(
      id: '2',
      senderName: 'David R.',
      preview: "My order hasn't arrived yet...",
      timeAgo: '1h ago',
    ),
  ].obs;

  Future<void> refreshData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 3));
    isLoading.value = false;
  }
}
