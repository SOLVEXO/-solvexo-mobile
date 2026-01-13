import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_timeline.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:get/get.dart';

class MyOrdersController extends GetxController {
  RxInt selectedTab = 0.obs;
  final Rx<OrderDeliveryStatus> currentStatus = OrderDeliveryStatus.deliver.obs;
  int get currentStep =>
      OrderDeliveryStatus.values.indexOf(currentStatus.value);
  RxList<OrderModel> orders = <OrderModel>[
    OrderModel(
      orderNumber: "741214",
      date: DateTime(2024, 1, 24),
      productName: "HemBox",
      image: AppImages.sampleProduct,
      totalItems: 2,
      totalAmount: 19.98,
      status: OrderStatus.delivered,
      isReviewed: false,
    ),
    OrderModel(
      orderNumber: "741215",
      date: DateTime(2024, 1, 24),
      productName: "Mopple Storage",
      image: AppImages.sampleProduct,
      totalItems: 2,
      totalAmount: 59.98,
      status: OrderStatus.delivered,
      isReviewed: true,
    ),
    OrderModel(
      orderNumber: "741216",
      date: DateTime(2024, 1, 24),
      productName: "Kupong",
      image: AppImages.sampleProduct,
      totalItems: 1,
      totalAmount: 10.98,
      status: OrderStatus.shipped,
    ),
  ].obs;

  final List<OrderTimeline> timeline = [
    OrderTimeline(
      status: OrderDeliveryStatus.process,
      title: "Package picked up",
      description: "Your package has left the sorting centre",
    ),
    OrderTimeline(
      status: OrderDeliveryStatus.deliver,
      title: "Deliver",
      description: "Preparing for delivery",
    ),
    OrderTimeline(
      status: OrderDeliveryStatus.inTransit,
      title: "Arrived at delivery hub",
      description: "Package arrived at logistics hub",
    ),
    OrderTimeline(
      status: OrderDeliveryStatus.delivered,
      title: "Delivered",
      description: "Your package has been delivered",
    ),
  ];

  double get subTotal =>
      orders.fold(0, (sum, e) => sum + (e.totalAmount * e.totalItems));

  double get shipping => 9.0;
  double get discount => 5.0;

  double get total => subTotal + shipping - discount;

  bool get canCancel => currentStatus.value == OrderDeliveryStatus.process;
  bool get canRefund => currentStatus.value != OrderDeliveryStatus.delivered;
  bool get canReview => currentStatus.value == OrderDeliveryStatus.delivered;

  void updateStatus(OrderDeliveryStatus status) {
    currentStatus.value = status;
  }

  List<OrderModel> get filteredOrders {
    switch (selectedTab.value) {
      case 1:
        return orders.where((e) => e.status == OrderStatus.unpaid).toList();
      case 2:
        return orders.where((e) => e.status == OrderStatus.toShip).toList();
      case 3:
        return orders.where((e) => e.status == OrderStatus.shipped).toList();
      case 4:
        return orders
            .where((e) => e.status == OrderStatus.delivered && !e.isReviewed)
            .toList();
      default:
        return orders;
    }
  }

  final tabs = ["All", "Unpaid", "To ship", "Shipped", "To review"];

  void changeTab(int index) {
    selectedTab.value = index;
  }
}
