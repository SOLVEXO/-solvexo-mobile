import 'package:book_store_app/app/data/models/subscriptions/buyer_credit_wallet_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/buyer_subscription_model.dart';
import 'package:book_store_app/app/data/repositories/buyer_memberships_repository.dart';
import 'package:get/get.dart';

class MyMembershipsController extends GetxController {
  final BuyerMembershipsRepository _repo = BuyerMembershipsRepository();

  final RxBool isLoading = true.obs;

  /// Id of the membership an action (pause/resume/cancel) is running for —
  /// empty when idle. Guards against double-taps and drives button spinners.
  final RxString actioningId = ''.obs;

  final RxList<BuyerSubscriptionModel> memberships = <BuyerSubscriptionModel>[].obs;
  final RxList<BuyerCreditWalletModel> credits = <BuyerCreditWalletModel>[].obs;

  /// Membership currently shown in the details bottom sheet. Re-emitted after
  /// the detail fetch (adds invoices) and after every successful action.
  final Rx<BuyerSubscriptionModel?> selected = Rx<BuyerSubscriptionModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    // Kick off both requests before awaiting so they run concurrently.
    final membershipsFuture = _repo.getMyMemberships();
    final creditsFuture = _repo.getCreditWallets();
    memberships.assignAll(await membershipsFuture);
    credits.assignAll(await creditsFuture);
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _load();

  /// Selects [membership] for the details sheet and loads its full detail
  /// (invoice history) in the background.
  void select(BuyerSubscriptionModel membership) {
    selected.value = membership;
    _repo.getMembershipById(membership.id).then((detail) {
      if (detail != null && selected.value?.id == membership.id) {
        selected.value = detail;
      }
    });
  }

  Future<void> pause(BuyerSubscriptionModel membership) =>
      _runAction(membership, () => _repo.pauseMembership(membership.id));

  Future<void> resume(BuyerSubscriptionModel membership) =>
      _runAction(membership, () => _repo.resumeMembership(membership.id));

  /// Cancels at period end — the buyer keeps their benefits until the current
  /// billing period runs out (backend `atPeriodEnd=true`).
  Future<void> cancel(BuyerSubscriptionModel membership) => _runAction(
        membership,
        () => _repo.cancelMembership(membership.id, atPeriodEnd: true),
      );

  Future<void> _runAction(
    BuyerSubscriptionModel membership,
    Future<BuyerSubscriptionModel?> Function() action,
  ) async {
    if (actioningId.value.isNotEmpty) return;
    actioningId.value = membership.id;
    final updated = await action();
    if (updated != null) {
      // The action response is the bare subscription document (no store/plan
      // join), so re-fetch the enriched list instead of patching in place.
      memberships.assignAll(await _repo.getMyMemberships());
      if (selected.value?.id == membership.id) {
        final detail = await _repo.getMembershipById(membership.id);
        if (detail != null) selected.value = detail;
      }
    }
    actioningId.value = '';
  }
}
