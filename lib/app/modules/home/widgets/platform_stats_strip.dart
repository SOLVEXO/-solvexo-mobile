import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Compact trust-builder row — "500+ Sellers", "$12k+ in sales",
/// "4.8★ 1.2k reviews" — backed by the unauthenticated, server-cached
/// `publicPlatformStats` endpoint. Renders nothing while unloaded/on
/// failure (never a broken or zeroed strip for a guest).
class PlatformStatsStrip extends StatelessWidget {
  PlatformStatsStrip({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.platformStats.value;
      if (stats == null) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: BaseSpacing.sm,
            horizontal: BaseSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.lg),
            boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '${stats.sellersCount}+',
                  label: 'Sellers',
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatTile(
                  value: _formatGmv(stats.gmv),
                  label: 'In sales',
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatTile(
                  isIcon: true,
                  assetName: AppIcons.fillStar,
                  value: stats.avgRating.toStringAsFixed(1),
                  label: stats.ratingCount > 0
                      ? '${_formatCount(stats.ratingCount)} reviews'
                      : 'Avg rating',
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static String _formatGmv(double gmv) {
    if (gmv >= 1000000) return '\$${(gmv / 1000000).toStringAsFixed(1)}M+';
    if (gmv >= 1000) return '\$${(gmv / 1000).toStringAsFixed(0)}k+';
    return '\$${gmv.toStringAsFixed(0)}';
  }

  static String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: AppColors.lightGrey2);
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final String assetName;
  final bool isIcon;

  const _StatTile({
    required this.value,
    required this.label,
    this.isIcon = false,
    this.assetName = AppIcons.cross,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            CustomText(
              text: value,
              color: AppColors.black2,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.w800,
            ),
            isIcon
                ? SvgIcon(assetName: assetName, size: 15)
                : SizedBox.shrink(),
          ],
        ),
        SizedBox(height: BaseSpacing.xxs / 2),
        CustomText(
          text: label,
          color: AppColors.gray600,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w400,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
