import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/ai_studio/ai_tool_meta.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// One tool tile on the AI Studio hub grid.
class AiToolGridCard extends StatelessWidget {
  final AiToolMeta meta;
  final int? costCredits;
  final VoidCallback onTap;

  const AiToolGridCard({super.key, required this.meta, this.costCredits, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(BaseSpacing.sm + 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BaseSpacing.sm + 4),
        child: Container(
          padding: EdgeInsets.all(BaseSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BaseSpacing.sm + 4),
            boxShadow: BaseShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: meta.emoji, fontSize: AppFontSize.veryLarge),
              SizedBox(height: BaseSpacing.xs),
              CustomText(
                text: meta.title,
                color: AppColors.black2,
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: BaseSpacing.xxs),
              CustomText(
                text: meta.description,
                color: AppColors.gray600,
                fontSize: AppFontSize.tiny,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (costCredits != null) ...[
                SizedBox(height: BaseSpacing.xs),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(BaseSpacing.xxs),
                  ),
                  child: CustomText(
                    text: '$costCredits credits',
                    color: AppColors.primaryColor,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
