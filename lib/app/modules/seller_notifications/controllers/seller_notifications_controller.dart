import 'package:get/get.dart';

class SellerNotificationsController extends GetxController {
  // Orders
  final RxBool newOrders = true.obs;
  final RxBool orderShipped = true.obs;
  final RxBool orderCancelled = false.obs;
  // Store
  final RxBool customerMessages = true.obs;
  final RxBool lowStockAlerts = true.obs;
  final RxBool productReviews = false.obs;
  // Marketing
  final RxBool promotionalTips = false.obs;
  final RxBool platformUpdates = true.obs;
}
