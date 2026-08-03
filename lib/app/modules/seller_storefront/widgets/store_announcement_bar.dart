import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/store/store_announcement_bar_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A thin colored strip for a seller's storefront announcement
/// (`StorefrontModel.announcementBar`) — sale/coupon/shipping/etc. Shown
/// only while `isCurrentlyVisible` (active + within its scheduling window)
/// and not locally dismissed for this screen session.
class StoreAnnouncementBar extends StatelessWidget {
  final StoreAnnouncementBarModel announcementBar;
  final VoidCallback onDismiss;

  const StoreAnnouncementBar({
    super.key,
    required this.announcementBar,
    required this.onDismiss,
  });

  Color get _backgroundColor {
    switch (announcementBar.type) {
      case 'sale':
        return AppColors.primaryColor;
      case 'warning':
        return AppColors.amberDark;
      case 'coupon':
        return AppColors.purpleColor;
      case 'shipping':
        return AppColors.blue;
      case 'holiday':
        return AppColors.darkGreen;
      case 'info':
      default:
        return AppColors.gray600;
    }
  }

  Future<void> _openCtaLink() async {
    final link = announcementBar.ctaLink;
    if (link == null || link.trim().isEmpty) return;
    final uri = Uri.tryParse(link.trim());
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) ToastUtil.showToast('Could not open this link.');
  }

  @override
  Widget build(BuildContext context) {
    if (!announcementBar.isCurrentlyVisible) return const SizedBox.shrink();

    final hasCta = (announcementBar.ctaLabel?.trim().isNotEmpty ?? false) &&
        (announcementBar.ctaLink?.trim().isNotEmpty ?? false);

    return Container(
      width: double.infinity,
      color: _backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: BaseSpacing.md,
        vertical: BaseSpacing.xs + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              text: announcementBar.message ?? '',
              color: AppColors.white,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasCta) ...[
            SizedBox(width: BaseSpacing.xs),
            GestureDetector(
              onTap: _openCtaLink,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSpacing.xs + 2,
                  vertical: BaseSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                child: CustomText(
                  text: announcementBar.ctaLabel!,
                  color: AppColors.white,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(width: BaseSpacing.xs),
          GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: Icon(Icons.close_rounded, size: 16, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
