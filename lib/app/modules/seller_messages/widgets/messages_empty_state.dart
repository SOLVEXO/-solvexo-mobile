import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';

class MessagesEmptyState extends StatelessWidget {
  final bool isArchived;
  const MessagesEmptyState({super.key, this.isArchived = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor.withOpacity(0.12), AppColors.accentColor.withOpacity(0.06)],
              ),
              borderRadius: BorderRadius.circular(BaseRadius.xxl),
            ),
            alignment: Alignment.center,
            child: SvgIcon(
              assetName: isArchived ? AppIcons.reportIcon : AppIcons.messageIcon,
              size: 34,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: BaseSpacing.md),
          Text(
            isArchived ? 'No archived conversations' : 'No messages yet',
            style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: BaseSpacing.xxs + 2),
          Text(
            isArchived ? 'Conversations you archive will show up here.' : 'Buyer messages will show up here.',
            style: BaseTypography.bodySmall(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
