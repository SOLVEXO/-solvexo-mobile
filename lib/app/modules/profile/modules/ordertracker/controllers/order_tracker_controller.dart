import 'package:book_store_app/app/modules/profile/modules/ordertracker/models/tracker_model.dart';
import 'package:book_store_app/utils/enums.dart';
import 'package:get/get.dart';

class OrderTrackerController extends GetxController {
  RxBool showAll = false.obs;

  /// 🔴 Change this value to test UI behavior
  Rx<TrackingStatus> currentStatus = TrackingStatus.outForDelivery.obs;

  late RxList<TrackingEvent> events;

  @override
  void onInit() {
    super.onInit();
    events = _buildEvents().obs;
  }

  List<TrackingEvent> _buildEvents() {
    final all = [
      TrackingEvent(
        status: TrackingStatus.delivered,
        title: "Delivered",
        description: "Your package has been delivered. Recipient: customer",
        time: DateTime.now(),
      ),
      TrackingEvent(
        status: TrackingStatus.outForDelivery,
        title: "Out of delivery",
        description: "Our carrier will attempt to deliver your package.",
        time: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TrackingEvent(
        status: TrackingStatus.arrivedHub,
        title: "Arrived at logistics delivery hub",
        description:
            "Your package is on the way to delivery hub in Shiloh, Hawaii",
        time: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TrackingEvent(
        status: TrackingStatus.arrivedSorting,
        title: "Arrived in sorting center",
        description: "Your package is in the sorting center",
        time: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      TrackingEvent(
        status: TrackingStatus.departed,
        title: "Departed from sorting centre",
        description: "Your package has been collected by our carrier",
        time: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TrackingEvent(
        status: TrackingStatus.preparing,
        title: "Preparing to ship",
        description: "Warehouse team is preparing your package",
        time: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    /// Filter based on current status
    return all
        .where(
          (e) =>
              TrackingStatus.values.indexOf(e.status) <=
              TrackingStatus.values.indexOf(currentStatus.value),
        )
        .toList();
  }

  List<TrackingEvent> get visibleEvents {
    if (showAll.value) return events;
    return events.take(3).toList();
  }

  void toggleShow() {
    showAll.value = !showAll.value;
  }
}
