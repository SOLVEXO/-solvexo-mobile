import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w700,
            color: AppColors.black2,
          ),
          if (viewMore)
            GestureDetector(
              onTap: onViewMore ?? () {},
              child: const CustomText(
                text: 'See All',
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
