import 'package:book_store_app/app/modules/seller/utils/plan_lapse.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/services/account_switch_service.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

enum PlanExpiredLoad { loading, ready, error }

/// Plan expired screen (docs Part B 2.8 / 6.1; checklist #4): "Choose a
/// plan" plus "Switch to buyer account" (or "Create buyer account" when the
/// person has none, from free-trial-eligibility.hasBuyerAccount).
class SellerPlanExpiredController extends GetxController {
  SellerPlanExpiredController({AccountSwitchService? switcher})
      : _switcher = switcher ?? AccountSwitchService();

  final AccountSwitchService _switcher;

  final Rx<PlanExpiredLoad> load = PlanExpiredLoad.loading.obs;
  final RxnString status = RxnString();
  final RxnString planName = RxnString();
  final RxBool hasBuyerAccount = true.obs;
  final RxBool switching = false.obs;

  bool get lapsed => PlanLapse.isLapsed(status.value);

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map && arg['status'] is String) status.value = arg['status'] as String;
    refreshState();
  }

  Future<void> refreshState() async {
    load.value = PlanExpiredLoad.loading;
    final plan = await PlanGate.check(force: true);
    final elig = await _switcher.eligibility();
    if (plan.failed) {
      load.value = PlanExpiredLoad.error;
      return;
    }
    status.value = plan.status;
    planName.value = plan.planName;
    if (elig != null) hasBuyerAccount.value = elig.hasBuyerAccount;
    load.value = PlanExpiredLoad.ready;
  }

  void choosePlan() => Get.toNamed(Routes.sellerPlatformPlan);

  void continueToDashboard() => Get.offAllNamed(Routes.sellerHome);

  Future<void> switchOrCreateBuyer() async {
    if (switching.value) return;
    switching.value = true;
    final result = hasBuyerAccount.value
        ? await _switcher.switchToBuyer()
        : await _switcher.createBuyerAccount();
    switching.value = false;
    if (!result.ok) {
      ToastUtil.showToast(result.message ?? 'Could not switch account.');
      return;
    }
    PlanGate.clearCache();
    await AccountSwitchService.openFor(result.session!);
  }
}
