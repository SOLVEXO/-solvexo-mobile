import 'package:book_store_app/app/modules/my_memberships/controllers/my_memberships_controller.dart';
import 'package:get/get.dart';

class MyMembershipsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyMembershipsController>(() => MyMembershipsController());
  }
}
