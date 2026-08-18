import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import '../models/faq_model.dart';

class FaqTile extends StatelessWidget {
  final FaqModel faq;
  final VoidCallback onTap;

  const FaqTile({super.key, required this.faq, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.sm),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(BaseSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.lg),
            boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgIcon(assetName: AppIcons.faqIcon, size: 16, color: AppColors.primaryColor),
              ),
              SizedBox(width: BaseSpacing.sm + 2),
              Expanded(
                child: CustomText(
                  text: faq.question,
                  color: AppColors.black,
                  fontSize: AppFontSize.extraSmall,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: BaseSpacing.xs),
              SvgIcon(assetName: AppIcons.chevronRight, size: 20, color: AppColors.lightGrey),
            ],
          ),
        ),
      ),
    );
  }
}
