import 'package:book_store_app/app/modules/my_bookings/controllers/my_bookings_controller.dart';
import 'package:get/get.dart';

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyBookingsController>(() => MyBookingsController());
  }
}
