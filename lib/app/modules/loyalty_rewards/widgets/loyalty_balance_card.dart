import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/loyalty/my_loyalty_balance_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// Hero card at the top of the buyer's rewards screen — current balance,
/// tier badge, and progress toward the next tier (if the store has one).
class LoyaltyBalanceCard extends StatelessWidget {
  final MyLoyaltyBalanceModel balance;
  const LoyaltyBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final next = balance.nextTier;
    // Progress toward the next tier — approximated from lifetime points
    // since the backend only returns "points needed", not the lower bound.
    final progress = next == null
        ? 1.0
        : (1 - (next.pointsNeeded / (balance.lifetimePoints + next.pointsNeeded))).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.appbarGradient,
        borderRadius: BorderRadius.circular(BaseRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: 'Your Points Balance', color: AppColors.white.withOpacity(0.85), fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                    SizedBox(height: BaseSpacing.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomText(text: '${balance.pointsBalance}', color: AppColors.white, fontSize: 30, fontWeight: FontWeight.w800),
                        SizedBox(width: BaseSpacing.xxs),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: CustomText(text: 'points', color: AppColors.white.withOpacity(0.85), fontSize: AppFontSize.tiny, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (balance.currentTier != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xxs + 1),
                  decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(BaseRadius.pill)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 14, color: AppColors.white),
                      SizedBox(width: BaseSpacing.xxs),
                      CustomText(text: balance.currentTier!, color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                    ],
                  ),
                ),
            ],
          ),
          if (next != null) ...[
            SizedBox(height: BaseSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(BaseRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation(AppColors.white),
              ),
            ),
            SizedBox(height: BaseSpacing.xxs + 1),
            CustomText(
              text: '${next.pointsNeeded} points to ${next.name}',
              color: AppColors.white.withOpacity(0.9),
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          ],
        ],
      ),
    );
  }
}
