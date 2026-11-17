import 'package:book_store_app/app/data/models/loyalty/loyalty_member_model.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_overview_model.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_program_model.dart';
import 'package:book_store_app/app/data/models/loyalty/reward_model.dart';
import 'package:book_store_app/app/data/repositories/loyalty_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum LoyaltyTab { overview, program, members, rewards }

class SellerLoyaltyController extends GetxController {
  final LoyaltyRepository _repo = LoyaltyRepository();

  String storeId = '';
  final Rx<LoyaltyTab> tab = LoyaltyTab.overview.obs;

  final RxBool isLoadingOverview = true.obs;
  final Rx<LoyaltyOverviewModel> overview = Rx<LoyaltyOverviewModel>(LoyaltyOverviewModel.empty);

  final RxBool isLoadingProgram = false.obs;
  final RxBool isSavingProgram = false.obs;
  final Rx<LoyaltyProgramModel> program = Rx<LoyaltyProgramModel>(LoyaltyProgramModel.empty);
  bool _programLoaded = false;

  final RxBool isLoadingMembers = false.obs;
  final RxList<LoyaltyMemberModel> members = <LoyaltyMemberModel>[].obs;
  bool _membersLoaded = false;

  final RxBool isLoadingRewards = false.obs;
  final RxBool isSavingReward = false.obs;
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  bool _rewardsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerLoyaltyController: no storeId in prefs');
      isLoadingOverview.value = false;
      return;
    }
    await loadOverview();
  }

  void changeTab(LoyaltyTab value) {
    tab.value = value;
    switch (value) {
      case LoyaltyTab.overview:
        loadOverview();
        break;
      case LoyaltyTab.program:
        if (!_programLoaded) loadProgram();
        break;
      case LoyaltyTab.members:
        if (!_membersLoaded) loadMembers();
        break;
      case LoyaltyTab.rewards:
        if (!_rewardsLoaded) loadRewards();
        break;
    }
  }

  Future<void> loadOverview() async {
    if (storeId.isEmpty) return;
    isLoadingOverview.value = true;
    overview.value = await _repo.getOverview(storeId);
    isLoadingOverview.value = false;
  }

  Future<void> loadProgram() async {
    if (storeId.isEmpty) return;
    isLoadingProgram.value = true;
    program.value = await _repo.getProgram(storeId);
    _programLoaded = true;
    isLoadingProgram.value = false;
  }

  Future<void> toggleEnabled(bool value) async {
    isSavingProgram.value = true;
    final updated = await _repo.updateProgram(storeId, isEnabled: value);
    if (updated != null) program.value = updated;
    isSavingProgram.value = false;
  }

  Future<bool> updatePointsExpiry(int? months) async {
    isSavingProgram.value = true;
    final updated = await _repo.updateProgram(storeId, pointsExpiryMonths: months ?? 0);
    isSavingProgram.value = false;
    if (updated != null) {
      program.value = updated;
      return true;
    }
    return false;
  }

  Future<bool> updateEarningRules({
    required int pointsPerDollar,
    required int pointsPerReview,
    required int pointsPerReferral,
    required int birthdayBonusPoints,
  }) async {
    isSavingProgram.value = true;
    final updated = await _repo.updateEarningRules(
      storeId,
      pointsPerDollar: pointsPerDollar,
      pointsPerReview: pointsPerReview,
      pointsPerReferral: pointsPerReferral,
      birthdayBonusPoints: birthdayBonusPoints,
    );
    isSavingProgram.value = false;
    if (updated != null) {
      program.value = updated;
      return true;
    }
    return false;
  }

  Future<bool> updateTiers(List<LoyaltyTierModel> tiers) async {
    isSavingProgram.value = true;
    final updated = await _repo.updateTiers(storeId, tiers);
    isSavingProgram.value = false;
    if (updated != null) {
      program.value = updated;
      return true;
    }
    return false;
  }

  Future<void> loadMembers() async {
    if (storeId.isEmpty) return;
    isLoadingMembers.value = true;
    final result = await _repo.getMembers(storeId, limit: 100);
    members.assignAll(result.members);
    _membersLoaded = true;
    isLoadingMembers.value = false;
  }

  Future<List<LoyaltyTransactionModel>> getMemberTransactions(String memberId) {
    return _repo.getMemberTransactions(storeId, memberId);
  }

  Future<bool> awardPoints(String memberId, {required int points, required String type, required String description}) async {
    final ok = await _repo.awardPoints(storeId, memberId, points: points, type: type, description: description);
    if (ok) await loadMembers();
    return ok;
  }

  Future<void> loadRewards() async {
    if (storeId.isEmpty) return;
    isLoadingRewards.value = true;
    final result = await _repo.getRewardsForManagement(storeId);
    rewards.assignAll(result);
    _rewardsLoaded = true;
    isLoadingRewards.value = false;
  }

  Future<bool> createReward({
    required String name,
    String? description,
    required int pointsCost,
    required String type,
    double? discountValue,
    String? productId,
    int? stockLimit,
  }) async {
    isSavingReward.value = true;
    final created = await _repo.createReward(
      storeId,
      name: name,
      description: description,
      pointsCost: pointsCost,
      type: type,
      discountValue: discountValue,
      productId: productId,
      stockLimit: stockLimit,
    );
    isSavingReward.value = false;
    if (created != null) {
      rewards.insert(0, created);
      return true;
    }
    return false;
  }

  Future<bool> updateReward(
    RewardModel existing, {
    String? name,
    String? description,
    int? pointsCost,
    String? type,
    double? discountValue,
    String? productId,
    int? stockLimit,
    bool? isActive,
  }) async {
    isSavingReward.value = true;
    final updated = await _repo.updateReward(
      storeId,
      existing.id,
      name: name,
      description: description,
      pointsCost: pointsCost,
      type: type,
      discountValue: discountValue,
      productId: productId,
      stockLimit: stockLimit,
      isActive: isActive,
    );
    isSavingReward.value = false;
    if (updated != null) {
      final index = rewards.indexWhere((r) => r.id == existing.id);
      if (index != -1) rewards[index] = updated;
      return true;
    }
    return false;
  }

  Future<void> toggleRewardActive(RewardModel reward) async {
    await updateReward(reward, isActive: !reward.isActive);
  }

  Future<void> deleteReward(RewardModel reward) async {
    final ok = await _repo.deleteReward(storeId, reward.id);
    if (ok) rewards.removeWhere((r) => r.id == reward.id);
  }

  @override
  Future<void> refresh() async {
    switch (tab.value) {
      case LoyaltyTab.overview:
        await loadOverview();
        break;
      case LoyaltyTab.program:
        await loadProgram();
        break;
      case LoyaltyTab.members:
        await loadMembers();
        break;
      case LoyaltyTab.rewards:
        await loadRewards();
        break;
    }
  }
}
