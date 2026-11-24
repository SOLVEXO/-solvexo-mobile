import 'package:book_store_app/config/app_config.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';

/// Plan lapse (docs Part B 2.8, 6.1): when the store's platform plan is
/// `expired`, `past_due` or `canceled`, its live listings are paused, the
/// seller sees the Plan expired screen and cannot create or activate
/// products. Status comes only from `GET /api/platform-plans/:storeId`
/// (`data.status`; live value for the test store: 'trialing').
class PlanLapse {
  PlanLapse._();

  static const Set<String> lapsedStatuses = {'expired', 'past_due', 'canceled'};

  static bool isLapsed(String? status) => lapsedStatuses.contains(status);

  static String title(String? status) => switch (status) {
        'past_due' when !AppFeatures.digitalPurchases => 'Your plan is not active',
        'past_due' => 'Your plan payment is overdue',
        'canceled' => 'Your plan was canceled',
        _ => 'Your plan has ended',
      };

  static String message(String? status) => switch (status) {
        _ when !AppFeatures.digitalPurchases =>
          'Your listings are not visible to buyers while your plan is not active.',
        'past_due' =>
          'We could not take the payment for your Edudeen plan. Your listings are paused until a plan is active again.',
        _ =>
          'Your listings are hidden from buyers until you choose a plan. They come back as soon as a plan is active.',
      };
}

class PlanCheck {
  const PlanCheck({this.status, this.planName, this.failed = false});
  final String? status;
  final String? planName;

  /// The plan could not be read (network/server). Callers do not block.
  final bool failed;
  bool get lapsed => PlanLapse.isLapsed(status);
}

/// Reads the active store's plan, cached briefly so gates stay quick.
class PlanGate {
  PlanGate._();

  static PlanCheck? _cache;
  static String? _cacheStore;
  static DateTime? _cacheAt;

  static void clearCache() => _cache = null;

  static Future<PlanCheck> check({
    bool force = false,
    PlatformPlansRepository? repository,
  }) async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) return const PlanCheck();
    final fresh = _cache != null &&
        _cacheStore == storeId &&
        _cacheAt != null &&
        DateTime.now().difference(_cacheAt!) < const Duration(minutes: 2);
    if (!force && fresh) return _cache!;

    final PlatformSubscriptionModel? sub;
    try {
      sub = await (repository ?? PlatformPlansRepository()).getStorePlan(storeId);
    } catch (_) {
      return const PlanCheck(failed: true);
    }
    final result = PlanCheck(status: sub?.status, planName: sub?.plan?.name);
    _cache = result;
    _cacheStore = storeId;
    _cacheAt = DateTime.now();
    return result;
  }
}
