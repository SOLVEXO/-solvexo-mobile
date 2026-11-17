import 'package:book_store_app/app/data/models/loyalty/my_loyalty_balance_model.dart';
import 'package:book_store_app/app/data/models/loyalty/reward_model.dart';
import 'package:book_store_app/app/data/repositories/loyalty_repository.dart';
import 'package:get/get.dart';

class LoyaltyRewardsController extends GetxController {
  final LoyaltyRepository _repo = LoyaltyRepository();

  late final String storeId;
  late final String storeName;

  final RxBool isLoading = true.obs;
  final RxString redeemingId = ''.obs;
  final Rx<MyLoyaltyBalanceModel> balance = Rx<MyLoyaltyBalanceModel>(MyLoyaltyBalanceModel.empty);
  final RxList<RewardModel> rewards = <RewardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    storeId = args?['storeId'] as String? ?? '';
    storeName = args?['storeName'] as String? ?? 'Store';
    _load();
  }

  Future<void> _load() async {
    if (storeId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    // Kick off both requests before awaiting so they run concurrently.
    final balanceFuture = _repo.getMyBalance(storeId);
    final rewardsFuture = _repo.getPublicRewards(storeId);
    balance.value = await balanceFuture;
    rewards.assignAll(await rewardsFuture);
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _load();

  bool canAfford(RewardModel reward) => balance.value.pointsBalance >= reward.pointsCost;

  Future<void> redeem(RewardModel reward) async {
    if (redeemingId.value.isNotEmpty) return;
    redeemingId.value = reward.id;
    final remaining = await _repo.redeemReward(storeId, reward.id);
    redeemingId.value = '';
    if (remaining != null) {
      balance.value = MyLoyaltyBalanceModel(
        pointsBalance: remaining,
        lifetimePoints: balance.value.lifetimePoints,
        currentTier: balance.value.currentTier,
        nextTier: balance.value.nextTier,
      );
      // Reward stock counters may have changed — refresh the catalog.
      rewards.assignAll(await _repo.getPublicRewards(storeId));
    }
  }
}
