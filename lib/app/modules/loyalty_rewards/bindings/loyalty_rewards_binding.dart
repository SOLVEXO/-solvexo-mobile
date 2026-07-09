import 'package:book_store_app/app/modules/loyalty_rewards/controllers/loyalty_rewards_controller.dart';
import 'package:get/get.dart';

class LoyaltyRewardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoyaltyRewardsController>(() => LoyaltyRewardsController());
  }
}
