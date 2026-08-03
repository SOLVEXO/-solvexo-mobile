import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final bool viewMore;
  final VoidCallback? onViewMore;

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.viewMore = false,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 0, AppDimen.allPadding, BaseSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            color: AppColors.black2,
            fontFamily: AppTextStyles.headingFontFamily,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w700,
          ),
          if (viewMore)
            GestureDetector(
              onTap: onViewMore ?? () {},
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                alignment: Alignment.center,
                child: CustomText(
                  text: 'See All',
                  color: AppColors.primaryColor,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
