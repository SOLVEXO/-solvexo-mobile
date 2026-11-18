import 'package:book_store_app/app/modules/seller_course/controllers/course_builder_controller.dart';
import 'package:get/get.dart';

class CourseBuilderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseBuilderController>(() => CourseBuilderController());
  }
}
