import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_tier_model.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SellerPlatformPlansController extends GetxController {
  final PlatformPlansRepository _repo = PlatformPlansRepository();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;
  final RxString billingInterval = 'monthly'.obs; // toggle for the pricing screen

  final RxList<PlatformTierModel> tiers = <PlatformTierModel>[].obs;
  final RxDouble posAddonMonthlyPriceUSD = 29.0.obs;
  final Rx<PlatformSubscriptionModel?> myPlan = Rx<PlatformSubscriptionModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerPlatformPlansController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await refresh();
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    final results = await Future.wait([_repo.getTiers(), _repo.getMyPlan(storeId)]);
    final tiersResult = results[0] as ({List<PlatformTierModel> tiers, double posAddonMonthlyPriceUSD});
    tiers.assignAll(tiersResult.tiers);
    posAddonMonthlyPriceUSD.value = tiersResult.posAddonMonthlyPriceUSD;
    myPlan.value = results[1] as PlatformSubscriptionModel?;
    isLoading.value = false;
  }

  void toggleBillingInterval() {
    billingInterval.value = billingInterval.value == 'monthly' ? 'yearly' : 'monthly';
  }

  bool isCurrentTier(String tier) => myPlan.value?.tier == tier;

  Future<void> selectTier(PlatformTierModel tier) async {
    if (isUpdating.value) return;
    if (isCurrentTier(tier.tier) && myPlan.value?.billingInterval == billingInterval.value) return;

    isUpdating.value = true;
    try {
      final isFirstUpgrade = myPlan.value == null || myPlan.value!.isStarter;
      final updated = isFirstUpgrade
          ? await _repo.subscribe(storeId, tier: tier.tier, billingInterval: billingInterval.value)
          : await _repo.changeTier(storeId, tier: tier.tier, billingInterval: billingInterval.value);
      if (updated != null) myPlan.value = updated;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> cancelToStarter({bool atPeriodEnd = true}) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final ok = await _repo.cancelToStarter(storeId, atPeriodEnd: atPeriodEnd);
      if (ok) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> subscribeToPosAddon() async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final ok = await _repo.subscribeToPosAddon(storeId);
      if (ok) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> cancelPosAddon() async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final ok = await _repo.cancelPosAddon(storeId);
      if (ok) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }
}
