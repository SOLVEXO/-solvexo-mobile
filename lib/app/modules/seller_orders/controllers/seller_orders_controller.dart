import 'package:get/get.dart';

enum OrderStatus { all, pending, processing, fulfilled, refund }

class SellerOrder {
  final String id;
  final String productName;
  final String customer;
  final String type; // 'Digital' | 'Physical'
  final double amount;
  final String date;
  final OrderStatus status;

  const SellerOrder({
    required this.id,
    required this.productName,
    required this.customer,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });
}

class SellerOrdersController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<OrderStatus> selectedFilter = OrderStatus.all.obs;

  final List<SellerOrder> _allOrders = const [
    SellerOrder(
      id: '#8821',
      productName: 'Math Bundle — Full Year',
      customer: 'Sarah M.',
      type: 'Digital',
      amount: 49.00,
      date: 'Today 2:14 PM',
      status: OrderStatus.pending,
    ),
    SellerOrder(
      id: '#8820',
      productName: 'Fractions Mastery Kit',
      customer: 'David R.',
      type: 'Digital',
      amount: 18.00,
      date: 'Today 11:03 AM',
      status: OrderStatus.fulfilled,
    ),
    SellerOrder(
      id: '#8819',
      productName: 'Ceramic Mug Set (2pk)',
      customer: 'Lena K.',
      type: 'Physical',
      amount: 58.00,
      date: 'Yesterday',
      status: OrderStatus.processing,
    ),
    SellerOrder(
      id: '#8818',
      productName: 'Science Workbook Grade 5',
      customer: 'Omar T.',
      type: 'Physical',
      amount: 22.50,
      date: 'Yesterday',
      status: OrderStatus.refund,
    ),
  ];

  RxList<SellerOrder> get filteredOrders {
    if (selectedFilter.value == OrderStatus.all) {
      return _allOrders.obs;
    }
    return _allOrders
        .where((o) => o.status == selectedFilter.value)
        .toList()
        .obs;
  }

  int countFor(OrderStatus status) {
    if (status == OrderStatus.all) return _allOrders.length;
    return _allOrders.where((o) => o.status == status).length;
  }

  void setFilter(OrderStatus status) => selectedFilter.value = status;

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
  }

  Future<void> refreshData() async => _loadOrders();
}
