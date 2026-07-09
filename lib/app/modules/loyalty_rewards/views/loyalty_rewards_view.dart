import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/data/models/loyalty/reward_model.dart';
import 'package:book_store_app/app/modules/loyalty_rewards/controllers/loyalty_rewards_controller.dart';
import 'package:book_store_app/app/modules/loyalty_rewards/widgets/buyer_reward_tile.dart';
import 'package:book_store_app/app/modules/loyalty_rewards/widgets/loyalty_balance_card.dart';
import 'package:book_store_app/app/modules/loyalty_rewards/widgets/loyalty_rewards_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoyaltyRewardsView extends StatelessWidget {
  LoyaltyRewardsView({super.key});

  final LoyaltyRewardsController controller = Get.put(LoyaltyRewardsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Rewards · ${controller.storeName}'),
      body: Obx(() {
        if (controller.isLoading.value) return const LoyaltyRewardsShimmer();

        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.all(BaseSpacing.md),
            children: [
              LoyaltyBalanceCard(balance: controller.balance.value),
              SizedBox(height: BaseSpacing.lg),
              Row(
                children: [
                  Container(width: 4, height: 16, decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(4))),
                  SizedBox(width: BaseSpacing.xs),
                  Text('Redeem Your Points', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: BaseSpacing.sm),
              if (controller.rewards.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.card_giftcard_outlined, size: 44, color: AppColors.lightGrey),
                        SizedBox(height: BaseSpacing.sm),
                        Text('No rewards available yet', style: BaseTypography.bodySmall(color: AppColors.gray600)),
                      ],
                    ),
                  ),
                )
              else
                ...controller.rewards.map((reward) => Padding(
                      padding: EdgeInsets.only(bottom: BaseSpacing.sm),
                      child: BuyerRewardTile(
                        reward: reward,
                        canAfford: controller.canAfford(reward),
                        isRedeeming: controller.redeemingId.value == reward.id,
                        onRedeem: () => _confirmRedeem(context, reward),
                      ),
                    )),
              SizedBox(height: BaseSpacing.xxl),
            ],
          ),
        );
      }),
    );
  }

  void _confirmRedeem(BuildContext context, RewardModel reward) {
    CustomConfirmDialog.show(
      context,
      title: 'Redeem "${reward.name}"?',
      message: 'This will use ${reward.pointsCost} points from your balance. This cannot be undone.',
      confirmLabel: 'Redeem',
      onConfirm: () => controller.redeem(reward),
    );
  }
}
