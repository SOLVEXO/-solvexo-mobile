import 'package:book_store_app/app/modules/course_player/controllers/course_player_controller.dart';
import 'package:get/get.dart';

class CoursePlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoursePlayerController>(() => CoursePlayerController());
  }
}
