import 'package:get/get.dart';

enum PosPaymentMethod { card, cash, tap }

class PosTransaction {
  final String id;
  final String customer;
  final PosPaymentMethod paymentMethod;
  final double amount;
  final String time;

  const PosTransaction({
    required this.id,
    required this.customer,
    required this.paymentMethod,
    required this.amount,
    required this.time,
  });
}

class PosOrdersController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString dateFilter = 'Today'.obs;

  // 14 txns · total $842.50 · cash $340 · avg $60.18
  static const List<PosTransaction> _allTransactions = [
    PosTransaction(id: 'POS-8841', customer: 'David R.', paymentMethod: PosPaymentMethod.card, amount: 52.00, time: '3:05 PM'),
    PosTransaction(id: 'POS-8840', customer: 'Walk-in', paymentMethod: PosPaymentMethod.cash, amount: 86.00, time: '2:48 PM'),
    PosTransaction(id: 'POS-8839', customer: 'Lena K.', paymentMethod: PosPaymentMethod.tap, amount: 24.00, time: '2:31 PM'),
    PosTransaction(id: 'POS-8838', customer: 'Walk-in', paymentMethod: PosPaymentMethod.card, amount: 61.50, time: '1:59 PM'),
    PosTransaction(id: 'POS-8837', customer: 'Omar T.', paymentMethod: PosPaymentMethod.cash, amount: 120.00, time: '1:22 PM'),
    PosTransaction(id: 'POS-8836', customer: 'Sarah M.', paymentMethod: PosPaymentMethod.card, amount: 33.00, time: '12:44 PM'),
    PosTransaction(id: 'POS-8835', customer: 'Walk-in', paymentMethod: PosPaymentMethod.tap, amount: 78.00, time: '12:01 PM'),
    PosTransaction(id: 'POS-8834', customer: 'Amira L.', paymentMethod: PosPaymentMethod.cash, amount: 134.00, time: '11:30 AM'),
    PosTransaction(id: 'POS-8833', customer: 'James W.', paymentMethod: PosPaymentMethod.card, amount: 18.00, time: '10:55 AM'),
    PosTransaction(id: 'POS-8832', customer: 'Walk-in', paymentMethod: PosPaymentMethod.tap, amount: 44.00, time: '10:12 AM'),
    PosTransaction(id: 'POS-8831', customer: 'Fatima H.', paymentMethod: PosPaymentMethod.card, amount: 62.50, time: '9:44 AM'),
    PosTransaction(id: 'POS-8830', customer: 'Nina P.', paymentMethod: PosPaymentMethod.tap, amount: 44.50, time: '9:10 AM'),
    PosTransaction(id: 'POS-8829', customer: 'Walk-in', paymentMethod: PosPaymentMethod.card, amount: 38.00, time: '8:55 AM'),
    PosTransaction(id: 'POS-8828', customer: 'Yusuf K.', paymentMethod: PosPaymentMethod.tap, amount: 47.00, time: '8:31 AM'),
  ];

  List<PosTransaction> get transactions => _allTransactions;

  double get totalSales =>
      _allTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get avgTransaction =>
      _allTransactions.isEmpty ? 0.0 : totalSales / _allTransactions.length;

  double get cashTotal => _allTransactions
      .where((t) => t.paymentMethod == PosPaymentMethod.cash)
      .fold(0.0, (sum, t) => sum + t.amount);

  int get txnCount => _allTransactions.length;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
  }

  Future<void> refreshData() async => _load();
}
