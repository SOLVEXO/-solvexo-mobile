import 'package:book_store_app/app/modules/worksheet_trial/controllers/worksheet_trial_controller.dart';
import 'package:get/get.dart';

class WorksheetTrialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorksheetTrialController>(() => WorksheetTrialController());
  }
}
