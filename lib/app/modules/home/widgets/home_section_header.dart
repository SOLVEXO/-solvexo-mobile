import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
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
          Text(title, style: BaseTypography.bodyLarge(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
          if (viewMore)
            GestureDetector(
              onTap: onViewMore ?? () {},
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                alignment: Alignment.center,
                child: Text(
                  'See All',
                  style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
