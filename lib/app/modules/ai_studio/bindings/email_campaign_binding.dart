import 'package:book_store_app/app/modules/ai_studio/controllers/email_campaign_controller.dart';
import 'package:get/get.dart';

class EmailCampaignBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailCampaignController>(() => EmailCampaignController());
  }
}
