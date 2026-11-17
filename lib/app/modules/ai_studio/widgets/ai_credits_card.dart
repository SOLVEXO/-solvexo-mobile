import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/ai_studio/ai_credits_overview_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// Balance summary shown at the top of the AI Studio hub.
class AiCreditsCard extends StatelessWidget {
  final AiCreditsOverviewModel credits;
  final VoidCallback onBuyCredits;
  final VoidCallback onViewHistory;

  const AiCreditsCard({
    super.key,
    required this.credits,
    required this.onBuyCredits,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final allowance = credits.monthlyAllowance;
    final progress = allowance > 0 ? (credits.balance / allowance).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.all(BaseSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.appbarGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: BaseShadows.md,
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
                    CustomText(
                      text: 'AI credits remaining',
                      color: AppColors.white.withOpacity(0.85),
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: BaseSpacing.xxs),
                    CustomText(
                      text: '${credits.balance}',
                      color: AppColors.white,
                      fontSize: AppFontSize.veryLarge2,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onViewHistory,
                child: CustomText(
                  text: 'History',
                  color: AppColors.white,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  textDecoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          if (allowance > 0) ...[
            SizedBox(height: BaseSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(BaseSpacing.xxs),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation(AppColors.white),
              ),
            ),
            SizedBox(height: BaseSpacing.xxs),
            CustomText(
              text: 'of $allowance monthly allowance',
              color: AppColors.white.withOpacity(0.85),
              fontSize: AppFontSize.tiny,
            ),
          ],
          SizedBox(height: BaseSpacing.md),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBuyCredits,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white.withOpacity(0.6), width: 1.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: 'Buy Credits',
                  color: AppColors.white,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
