import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

Color _statusColor(String status) {
  switch (status) {
    case 'active':
      return AppColors.greenSuccess;
    case 'scheduled':
      return AppColors.blue;
    case 'paused':
      return AppColors.orange;
    case 'expired':
      return AppColors.gray600;
    default:
      return AppColors.lightGrey7;
  }
}

class StoreBannerCard extends StatelessWidget {
  final StoreBannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onTimeline;

  const StoreBannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
    required this.onPause,
    required this.onResume,
    required this.onTimeline,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(banner.status);
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(BaseRadius.md),
              child: CommonImageView(
                url: banner.imageUrl,
                height: 64,
                width: 64,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: banner.type[0].toUpperCase() + banner.type.substring(1),
                          color: AppColors.black2,
                          fontSize: AppFontSize.extraSmall,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(BaseRadius.pill),
                        ),
                        child: CustomText(
                          text: storeBannerStatusLabel(banner.status),
                          color: color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (banner.ctaLabel != null && banner.ctaLabel!.isNotEmpty) ...[
                    SizedBox(height: BaseSpacing.xxs),
                    CustomText(
                      text: '"${banner.ctaLabel}" → ${banner.linkType}',
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: BaseSpacing.xxs),
                  Row(
                    children: [
                      Icon(Icons.low_priority_rounded, size: 13, color: AppColors.gray600),
                      SizedBox(width: BaseSpacing.xxs / 2),
                      CustomText(
                        text: 'Order ${banner.order} · Priority ${banner.priority}',
                        color: AppColors.gray600,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.xs),
                  Row(
                    children: [
                      _ActionIcon(icon: Icons.history_rounded, onTap: onTimeline),
                      SizedBox(width: BaseSpacing.xs),
                      if (banner.isActive)
                        _ActionIcon(icon: Icons.pause_circle_outline_rounded, onTap: onPause)
                      else if (banner.canResume)
                        _ActionIcon(icon: Icons.play_circle_outline_rounded, onTap: onResume, color: AppColors.greenSuccess),
                      SizedBox(width: BaseSpacing.xs),
                      _ActionIcon(icon: Icons.delete_outline_rounded, onTap: onDelete, color: AppColors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _ActionIcon({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 19, color: color ?? AppColors.gray600),
    );
  }
}
