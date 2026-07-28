import 'package:book_store_app/app/data/models/platform_plans/platform_addon_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_entitlements_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_invoice_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_plan_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/app/modules/seller_platform_plans/widgets/plan_change_preview_sheet.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:book_store_app/utils/toast_util.dart';

/// Placeholder return-url for the Stripe-hosted billing portal — there's no
/// in-app deep-link callback handling; the seller manually returns to the
/// app after managing billing in the external browser tab.
const String _kBillingPortalReturnUrl =
    'https://solvexo.store/seller/platform-plan';

class SellerPlatformPlansController extends GetxController {
  SellerPlatformPlansController({PlatformPlansRepository? repository})
    : _repo = repository ?? PlatformPlansRepository();

  final PlatformPlansRepository _repo;

  String storeId = '';
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isPreviewing = false.obs;
  final RxString billingInterval = 'monthly'.obs; // pricing-section toggle

  final RxList<PlatformPlanModel> plans = <PlatformPlanModel>[].obs;
  final Rx<PlatformSubscriptionModel?> myPlan = Rx<PlatformSubscriptionModel?>(
    null,
  );
  final Rx<PlatformEntitlementsModel?> entitlements =
      Rx<PlatformEntitlementsModel?>(null);
  final RxList<PlatformAddonModel> addons = <PlatformAddonModel>[].obs;
  final RxList<PlatformInvoiceModel> invoices = <PlatformInvoiceModel>[].obs;
  final RxInt invoicesTotal = 0.obs;

  List<PlatformAddonModel> get activeAddons =>
      addons.where((a) => a.isActive).toList();

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
        results[4]
            as ({List<PlatformInvoiceModel> invoices, int total, int pages});
    invoices.assignAll(invoiceResult.invoices);
    invoicesTotal.value = invoiceResult.total;
    isLoading.value = false;
  }

  void toggleBillingInterval() {
    billingInterval.value = billingInterval.value == 'monthly'
        ? 'yearly'
        : 'monthly';
  }

  bool isCurrentPlan(PlatformPlanModel plan) =>
      myPlan.value?.plan?.id == plan.id;

  /// Dry-runs the switch via `preview-change-plan` first, then hands the
  /// pricing math to [PlanChangePreviewSheet] — the seller only actually
  /// commits (via [_applyPlanChange]) after confirming there.
  Future<void> selectPlan(PlatformPlanModel plan) async {
    if (isUpdating.value || isPreviewing.value) return;
    if (isCurrentPlan(plan) &&
        myPlan.value?.billingInterval == billingInterval.value)
      return;

    isPreviewing.value = true;
    try {
      final preview = await _repo.previewChangePlan(
        storeId,
        newPlatformPlanId: plan.id,
        newBillingInterval: billingInterval.value,
      );
      if (preview == null) return;
      PlanChangePreviewSheet.show(
        preview: preview,
        onConfirm: () => _applyPlanChange(plan),
      );
    } finally {
      isPreviewing.value = false;
    }
  }

  /// The actual plan/interval switch — only reached once the seller taps
  /// "Confirm Change" on the preview sheet.
  Future<void> _applyPlanChange(PlatformPlanModel plan) async {
    if (isUpdating.value) return;
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

  /// Schedules a downgrade-to-free at the current period's end — access is
  /// unaffected until then. [reason] is optional (max 500 chars, enforced
  /// server-side).
  Future<void> cancelPlan(String? reason) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final updated = await _repo.cancelSubscription(storeId, reason: reason);
      if (updated != null) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }

  /// Undoes a pending cancellation from [cancelPlan].
  Future<void> reactivatePlan() async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final updated = await _repo.reactivateSubscription(storeId);
      if (updated != null) await refresh();
    } finally {
      isUpdating.value = false;
    }
  }

  /// Opens the Stripe-hosted billing portal (or, without Stripe configured
  /// for this store, whatever placeholder URL the backend echoes back) in
  /// an external browser tab.
  Future<void> openBillingPortal() async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final url = await _repo.openBillingPortal(
        storeId,
        returnUrl: _kBillingPortalReturnUrl,
      );
      if (url == null || url.trim().isEmpty) return;
      final uri = Uri.tryParse(url.trim());
      if (uri == null) return;
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) ToastUtil.showToast('Could not open the billing portal.');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> purchaseAddon(String addonType, {int quantity = 1}) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      final ok = await _repo.purchaseAddon(
        storeId,
        addonType: addonType,
        quantity: quantity,
      );
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
