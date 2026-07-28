import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom-of-home promo card that opens the free, unauthenticated AI
/// Worksheet Builder trial — a taste of AI Studio for guests/buyers, who
/// have no access to the full seller-only tool.
class WorksheetTrialPromoCard extends StatelessWidget {
  const WorksheetTrialPromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.worksheetTrial),
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(BaseRadius.xl),
          boxShadow: BaseShadows.forLevel(BaseElevation.level2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(BaseRadius.md),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Try our free AI Worksheet Builder',
                    color: AppColors.white,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: BaseSpacing.xxs / 2),
                  CustomText(
                    text: 'Generate a custom worksheet in seconds — no sign-up needed',
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: AppFontSize.tiny,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: BaseSpacing.xs),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
