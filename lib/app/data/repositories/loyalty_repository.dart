import 'package:book_store_app/app/data/models/loyalty/loyalty_member_model.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_overview_model.dart';
import 'package:book_store_app/app/data/models/loyalty/loyalty_program_model.dart';
import 'package:book_store_app/app/data/models/loyalty/my_loyalty_balance_model.dart';
import 'package:book_store_app/app/data/models/loyalty/reward_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoyaltyRepository {
  final BaseClient _client = BaseClient();

  Future<LoyaltyOverviewModel> getOverview(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.loyaltyOverview(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return LoyaltyOverviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return LoyaltyOverviewModel.empty;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return LoyaltyOverviewModel.empty;
    } catch (e) {
      debugPrint('❌ getOverview error: $e');
      ToastUtil.showToast('Failed to load loyalty overview.');
      return LoyaltyOverviewModel.empty;
    }
  }

  Future<LoyaltyProgramModel> getProgram(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.loyaltyProgram(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return LoyaltyProgramModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return LoyaltyProgramModel.empty;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return LoyaltyProgramModel.empty;
    } catch (e) {
      debugPrint('❌ getProgram error: $e');
      ToastUtil.showToast('Failed to load loyalty program.');
      return LoyaltyProgramModel.empty;
    }
  }

  Future<LoyaltyProgramModel?> updateProgram(String storeId, {bool? isEnabled, int? pointsExpiryMonths}) async {
    try {
      final response = await _client.patch(
        ApiConstants.loyaltyProgram(storeId),
        data: {
          if (isEnabled != null) 'isEnabled': isEnabled,
          if (pointsExpiryMonths != null) 'pointsExpiryMonths': pointsExpiryMonths,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Program updated');
        return LoyaltyProgramModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateProgram error: $e');
      ToastUtil.showToast('Failed to update program.');
      return null;
    }
  }

  Future<LoyaltyProgramModel?> updateEarningRules(
    String storeId, {
    int? pointsPerDollar,
    int? pointsPerReview,
    int? pointsPerReferral,
    int? birthdayBonusPoints,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.loyaltyEarningRules(storeId),
        data: {
          if (pointsPerDollar != null) 'pointsPerDollar': pointsPerDollar,
          if (pointsPerReview != null) 'pointsPerReview': pointsPerReview,
          if (pointsPerReferral != null) 'pointsPerReferral': pointsPerReferral,
          if (birthdayBonusPoints != null) 'birthdayBonusPoints': birthdayBonusPoints,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Earning rules updated');
        return LoyaltyProgramModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateEarningRules error: $e');
      ToastUtil.showToast('Failed to update earning rules.');
      return null;
    }
  }

  Future<LoyaltyProgramModel?> updateTiers(String storeId, List<LoyaltyTierModel> tiers) async {
    try {
      final response = await _client.put(
        ApiConstants.loyaltyTiers(storeId),
        data: {'tiers': tiers.map((t) => t.toJson()).toList()},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Tiers updated');
        return LoyaltyProgramModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateTiers error: $e');
      ToastUtil.showToast('Failed to update tiers.');
      return null;
    }
  }

  Future<({List<LoyaltyMemberModel> members, int total, int totalPages})> getMembers(
    String storeId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.loyaltyMembers(storeId),
        queryParameters: {'page': page, 'limit': limit},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final members = (data['members'] as List).cast<Map<String, dynamic>>().map(LoyaltyMemberModel.fromJson).toList();
        return (members: members, total: pagination['total'] as int? ?? 0, totalPages: pagination['totalPages'] as int? ?? 1);
      }
      return (members: <LoyaltyMemberModel>[], total: 0, totalPages: 1);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (members: <LoyaltyMemberModel>[], total: 0, totalPages: 1);
    } catch (e) {
      debugPrint('❌ getMembers error: $e');
      ToastUtil.showToast('Failed to load members.');
      return (members: <LoyaltyMemberModel>[], total: 0, totalPages: 1);
    }
  }

  Future<List<LoyaltyTransactionModel>> getMemberTransactions(String storeId, String memberId) async {
    try {
      final response = await _client.get(
        ApiConstants.loyaltyMemberTransactions(storeId, memberId),
        queryParameters: {'page': 1, 'limit': 50},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (data['transactions'] as List).cast<Map<String, dynamic>>().map(LoyaltyTransactionModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getMemberTransactions error: $e');
      ToastUtil.showToast('Failed to load transaction history.');
      return [];
    }
  }

  Future<bool> awardPoints(
    String storeId,
    String memberId, {
    required int points,
    required String type,
    required String description,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.loyaltyAwardPoints(storeId, memberId),
        data: {'points': points, 'type': type, 'description': description},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Points awarded');
        return true;
      }
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ awardPoints error: $e');
      ToastUtil.showToast('Failed to award points.');
      return false;
    }
  }

  /// Seller's own management list — includes inactive rewards so they can be re-enabled.
  Future<List<RewardModel>> getRewardsForManagement(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.loyaltyRewardsManage(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return (response.data['data'] as List).cast<Map<String, dynamic>>().map(RewardModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getRewardsForManagement error: $e');
      ToastUtil.showToast('Failed to load rewards.');
      return [];
    }
  }

  Future<RewardModel?> createReward(
    String storeId, {
    required String name,
    String? description,
    required int pointsCost,
    required String type,
    double? discountValue,
    String? productId,
    int? stockLimit,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.loyaltyRewards(storeId),
        data: {
          'name': name,
          if (description != null) 'description': description,
          'pointsCost': pointsCost,
          'type': type,
          if (discountValue != null) 'discountValue': discountValue,
          if (productId != null) 'productId': productId,
          if (stockLimit != null) 'stockLimit': stockLimit,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Reward created');
        return RewardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to create reward');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ createReward error: $e');
      ToastUtil.showToast('Failed to create reward.');
      return null;
    }
  }

  Future<RewardModel?> updateReward(
    String storeId,
    String rewardId, {
    String? name,
    String? description,
    int? pointsCost,
    String? type,
    double? discountValue,
    String? productId,
    int? stockLimit,
    bool? isActive,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.loyaltyRewardById(storeId, rewardId),
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (pointsCost != null) 'pointsCost': pointsCost,
          if (type != null) 'type': type,
          if (discountValue != null) 'discountValue': discountValue,
          if (productId != null) 'productId': productId,
          if (stockLimit != null) 'stockLimit': stockLimit,
          if (isActive != null) 'isActive': isActive,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Reward updated');
        return RewardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to update reward');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateReward error: $e');
      ToastUtil.showToast('Failed to update reward.');
      return null;
    }
  }

  Future<bool> deleteReward(String storeId, String rewardId) async {
    try {
      final response = await _client.delete(ApiConstants.loyaltyRewardById(storeId, rewardId), requiresAuth: true);
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Reward deleted');
        return true;
      }
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteReward error: $e');
      ToastUtil.showToast('Failed to delete reward.');
      return false;
    }
  }

  // ── Buyer-facing ─────────────────────────────────────────────────────────

  /// Public catalog — active rewards only.
  Future<List<RewardModel>> getPublicRewards(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.loyaltyRewards(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return (response.data['data'] as List).cast<Map<String, dynamic>>().map(RewardModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getPublicRewards error: $e');
      ToastUtil.showToast('Failed to load rewards.');
      return [];
    }
  }

  Future<MyLoyaltyBalanceModel> getMyBalance(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.loyaltyMyBalance(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return MyLoyaltyBalanceModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return MyLoyaltyBalanceModel.empty;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return MyLoyaltyBalanceModel.empty;
    } catch (e) {
      debugPrint('❌ getMyBalance error: $e');
      return MyLoyaltyBalanceModel.empty;
    }
  }

  /// Returns the remaining points balance on success, or null on failure
  /// (insufficient points / out of stock — backend message is toasted).
  Future<int?> redeemReward(String storeId, String rewardId) async {
    try {
      final response = await _client.post(
        ApiConstants.loyaltyRedeem(storeId),
        data: {'rewardId': rewardId},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Reward redeemed');
        final data = response.data['data'] as Map<String, dynamic>;
        return data['remainingBalance'] as int?;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to redeem reward');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ redeemReward error: $e');
      ToastUtil.showToast('Failed to redeem reward.');
      return null;
    }
  }
}
