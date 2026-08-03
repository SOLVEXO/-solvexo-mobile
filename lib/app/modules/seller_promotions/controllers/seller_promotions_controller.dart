import 'package:book_store_app/app/data/models/promotions/promotion_analytics_model.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_request_model.dart';
import 'package:book_store_app/app/data/repositories/promotions_repository.dart';
import 'package:book_store_app/config/stripe_config.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

/// Seller-facing list of paid ad-placement requests (`solvexo-api`'s
/// `src/promotions`) — pull-to-refresh list + aggregate analytics, plus the
/// pay/cancel actions available per request. The heavy lifting (previewing
/// price, submitting the creative, computing entitlements) all lives in
/// [PromotionsRepository] / the backend; this controller only orchestrates
/// what's already built.
class SellerPromotionsController extends GetxController {
  SellerPromotionsController({PromotionsRepository? repository}) : _repo = repository ?? PromotionsRepository();

  final PromotionsRepository _repo;

  String storeId = '';
  final RxBool isLoading = true.obs;

  final RxList<PromotionRequestModel> requests = <PromotionRequestModel>[].obs;
  final Rx<PromotionAnalyticsModel> analytics = Rx<PromotionAnalyticsModel>(PromotionAnalyticsModel.empty);

  /// Id of the request currently mid Stripe flow — only that card's "Pay
  /// Now" button shows a spinner / gets disabled.
  final RxnString payingId = RxnString();

  /// Id of the request currently being cancelled.
  final RxnString cancelingId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerPromotionsController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await refresh();
  }

  @override
  Future<void> refresh() async {
    if (storeId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    final results = await Future.wait([_repo.list(storeId), _repo.getAnalytics(storeId)]);
    requests.assignAll(results[0] as List<PromotionRequestModel>);
    analytics.value = results[1] as PromotionAnalyticsModel;
    isLoading.value = false;
  }

  /// Mirrors `PaymentController.payWithStripe` in
  /// `lib/app/modules/payment/controllers/payment_controller.dart` — same
  /// PaymentSheet shape, same Canceled-is-silent handling — just backed by
  /// [PromotionsRepository.pay]/[PromotionsRepository.confirm] instead of
  /// the checkout repository.
  Future<void> payNow(PromotionRequestModel request) async {
    if (payingId.value != null) return;

    if (!StripeConfig.isConfigured) {
      ToastUtil.showToast('Online payments are not available yet. Please try again later.');
      return;
    }

    payingId.value = request.id;
    try {
      final result = await _repo.pay(request.id);
      if (!result.success || result.clientSecret == null) {
        ToastUtil.showToast(result.message ?? 'Failed to start payment');
        return;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result.clientSecret!,
          merchantDisplayName: 'Solvexo',
        ),
      );

      try {
        await Stripe.instance.presentPaymentSheet();
      } on StripeException catch (e) {
        // FailureCode.Canceled is the user backing out of the sheet — not
        // an error worth surfacing.
        if (e.error.code != FailureCode.Canceled) {
          ToastUtil.showToast(e.error.localizedMessage ?? 'Payment failed');
        }
        return;
      }

      final confirmed = await _repo.confirm(request.id);
      ToastUtil.showToast(
        confirmed
            ? 'Payment successful — your promotion is now live.'
            : 'Payment received — your promotion will go live shortly.',
      );
      await refresh();
    } catch (e) {
      debugPrint('❌ promotion payNow error: $e');
      ToastUtil.showToast('Something went wrong while processing your payment.');
    } finally {
      payingId.value = null;
    }
  }

  Future<void> cancelRequest(String id) async {
    if (cancelingId.value != null) return;
    cancelingId.value = id;
    try {
      final ok = await _repo.cancel(id);
      if (ok) {
        ToastUtil.showToast('Promotion cancelled.');
        await refresh();
      } else {
        ToastUtil.showToast('Failed to cancel promotion.');
      }
    } finally {
      cancelingId.value = null;
    }
  }
}
