import 'package:book_store_app/app/modules/pos_daily_report/controllers/pos_daily_report_controller.dart';
import 'package:get/get.dart';

class PosDailyReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosDailyReportController>(() => PosDailyReportController());
  }
}
