import 'package:book_store_app/app/data/models/platform_plans/platform_addon_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_entitlements_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_invoice_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_plan_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SellerPlatformPlansController extends GetxController {
  final PlatformPlansRepository _repo = PlatformPlansRepository();

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;
  final RxString billingInterval = 'monthly'.obs; // pricing-section toggle

  final RxList<PlatformPlanModel> plans = <PlatformPlanModel>[].obs;
  final Rx<PlatformSubscriptionModel?> myPlan = Rx<PlatformSubscriptionModel?>(null);
  final Rx<PlatformEntitlementsModel?> entitlements = Rx<PlatformEntitlementsModel?>(null);
  final RxList<PlatformAddonModel> addons = <PlatformAddonModel>[].obs;
  final RxList<PlatformInvoiceModel> invoices = <PlatformInvoiceModel>[].obs;
  final RxInt invoicesTotal = 0.obs;

  List<PlatformAddonModel> get activeAddons => addons.where((a) => a.isActive).toList();

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
    final results = await Future.wait([
      _repo.getPublicPlans(),
      _repo.getStorePlan(storeId),
      _repo.getEntitlements(storeId),
      _repo.getAddons(storeId),
      _repo.getInvoices(storeId, limit: 10),
    ]);
    plans.assignAll(results[0] as List<PlatformPlanModel>);
    myPlan.value = results[1] as PlatformSubscriptionModel?;
    entitlements.value = results[2] as PlatformEntitlementsModel?;
    addons.assignAll(results[3] as List<PlatformAddonModel>);
    final invoiceResult =
        results[4] as ({List<PlatformInvoiceModel> invoices, int total, int pages});
    invoices.assignAll(invoiceResult.invoices);
    invoicesTotal.value = invoiceResult.total;
    isLoading.value = false;
  }

  void toggleBillingInterval() {
    billingInterval.value = billingInterval.value == 'monthly' ? 'yearly' : 'monthly';
  }

  bool isCurrentPlan(PlatformPlanModel plan) => myPlan.value?.plan?.id == plan.id;

  Future<void> selectPlan(PlatformPlanModel plan) async {
    if (isUpdating.value) return;
    if (isCurrentPlan(plan) && myPlan.value?.billingInterval == billingInterval.value) return;

    isUpdating.value = true;
    try {
      final updated = await _repo.changePlan(
        storeId,
        planId: plan.id,
        billingInterval: billingInterval.value,
      );
      // Refresh everything — a plan change moves entitlements/limits too.
      if (updated != null) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> purchaseAddon(String addonType, {int quantity = 1}) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final ok = await _repo.purchaseAddon(storeId, addonType: addonType, quantity: quantity);
      if (ok) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> cancelAddon(PlatformAddonModel addon) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final ok = await _repo.cancelAddon(storeId, addon.id);
      if (ok) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }
}
