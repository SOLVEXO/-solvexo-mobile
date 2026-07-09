import 'package:book_store_app/app/data/models/loyalty/my_loyalty_balance_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
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
                    Text('Your Points Balance', style: BaseTypography.labelSmall(color: AppColors.white.withOpacity(0.85))),
                    SizedBox(height: BaseSpacing.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${balance.pointsBalance}', style: BaseTypography.titleLarge(color: AppColors.white).copyWith(fontWeight: FontWeight.w800, fontSize: 30)),
                        SizedBox(width: BaseSpacing.xxs),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('points', style: BaseTypography.bodySmall(color: AppColors.white.withOpacity(0.85))),
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
                      Text(balance.currentTier!, style: BaseTypography.labelSmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
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
            Text(
              '${next.pointsNeeded} points to ${next.name}',
              style: BaseTypography.labelSmall(color: AppColors.white.withOpacity(0.9)).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
