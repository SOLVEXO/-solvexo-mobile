import 'package:book_store_app/app/data/models/subscriptions/subscriber_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscription_dashboard_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscription_plan_model.dart';
import 'package:book_store_app/app/data/repositories/subscription_plans_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum SubscriptionsTab { dashboard, plans, subscribers }

class SellerSubscriptionsController extends GetxController {
  final SubscriptionPlansRepository _repo = SubscriptionPlansRepository();

  String storeId = '';
  final Rx<SubscriptionsTab> tab = SubscriptionsTab.dashboard.obs;

  final RxBool isLoadingDashboard = true.obs;
  final Rx<SubscriptionDashboardModel> dashboard = Rx<SubscriptionDashboardModel>(SubscriptionDashboardModel.empty);

  final RxBool isLoadingPlans = false.obs;
  final RxBool isSavingPlan = false.obs;
  final RxList<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[].obs;
  bool _plansLoaded = false;

  final RxBool isLoadingSubscribers = false.obs;
  final RxList<SubscriberModel> subscribers = <SubscriberModel>[].obs;
  bool _subscribersLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerSubscriptionsController: no storeId in prefs');
      isLoadingDashboard.value = false;
      return;
    }
    await loadDashboard();
  }

  void changeTab(SubscriptionsTab value) {
    tab.value = value;
    switch (value) {
      case SubscriptionsTab.dashboard:
        loadDashboard();
        break;
      case SubscriptionsTab.plans:
        if (!_plansLoaded) loadPlans();
        break;
      case SubscriptionsTab.subscribers:
        if (!_subscribersLoaded) loadSubscribers();
        break;
    }
  }

  Future<void> loadDashboard() async {
    if (storeId.isEmpty) return;
    isLoadingDashboard.value = true;
    dashboard.value = await _repo.getDashboard(storeId);
    isLoadingDashboard.value = false;
  }

  Future<void> loadPlans() async {
    if (storeId.isEmpty) return;
    isLoadingPlans.value = true;
    final result = await _repo.listPlans(storeId);
    plans.assignAll(result);
    _plansLoaded = true;
    isLoadingPlans.value = false;
  }

  Future<bool> createPlan({
    required String name,
    String? description,
    required double monthlyPriceUSD,
    double? yearlyPriceUSD,
    String? displayCurrency,
    List<String>? features,
  }) async {
    isSavingPlan.value = true;
    final created = await _repo.createPlan(
      storeId,
      name: name,
      description: description,
      monthlyPriceUSD: monthlyPriceUSD,
      yearlyPriceUSD: yearlyPriceUSD,
      displayCurrency: displayCurrency,
      features: features,
    );
    isSavingPlan.value = false;
    if (created != null) {
      plans.insert(0, created);
      return true;
    }
    return false;
  }

  Future<bool> updatePlan(
    SubscriptionPlanModel existing, {
    String? name,
    String? description,
    double? monthlyPriceUSD,
    double? yearlyPriceUSD,
    String? displayCurrency,
    List<String>? features,
    String? status,
  }) async {
    isSavingPlan.value = true;
    final updated = await _repo.updatePlan(
      storeId,
      existing.id,
      name: name,
      description: description,
      monthlyPriceUSD: monthlyPriceUSD,
      yearlyPriceUSD: yearlyPriceUSD,
      displayCurrency: displayCurrency,
      features: features,
      status: status,
    );
    isSavingPlan.value = false;
    if (updated != null) {
      final index = plans.indexWhere((p) => p.id == existing.id);
      if (index != -1) plans[index] = updated;
      return true;
    }
    return false;
  }

  Future<bool> archivePlan(SubscriptionPlanModel plan, {bool force = false}) async {
    final ok = await _repo.archivePlan(storeId, plan.id, force: force);
    if (ok) await loadPlans();
    return ok;
  }

  Future<void> loadSubscribers() async {
    if (storeId.isEmpty) return;
    isLoadingSubscribers.value = true;
    final result = await _repo.listSubscriptions(storeId, limit: 100);
    subscribers.assignAll(result.subscribers);
    _subscribersLoaded = true;
    isLoadingSubscribers.value = false;
  }

  Future<void> pauseSubscriber(SubscriberModel s) async {
    final ok = await _repo.pauseSubscription(storeId, s.id);
    if (ok) await loadSubscribers();
  }

  Future<void> resumeSubscriber(SubscriberModel s) async {
    final ok = await _repo.resumeSubscription(storeId, s.id);
    if (ok) await loadSubscribers();
  }

  Future<void> cancelSubscriber(SubscriberModel s, {bool atPeriodEnd = false}) async {
    final ok = await _repo.cancelSubscription(storeId, s.id, atPeriodEnd: atPeriodEnd);
    if (ok) await loadSubscribers();
  }

  @override
  Future<void> refresh() async {
    switch (tab.value) {
      case SubscriptionsTab.dashboard:
        await loadDashboard();
        break;
      case SubscriptionsTab.plans:
        await loadPlans();
        break;
      case SubscriptionsTab.subscribers:
        await loadSubscribers();
        break;
    }
  }
}
