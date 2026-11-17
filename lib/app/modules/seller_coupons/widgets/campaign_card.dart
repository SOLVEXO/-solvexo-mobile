import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/marketing/campaign_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final bool isProcessing;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.isProcessing,
    required this.onJoin,
    required this.onLeave,
  });

  String get _endLabel {
    final end = campaign.endDate;
    if (end == null) return '';
    if (campaign.isEnded) return 'Campaign ended';
    final days = end.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Ends today';
    if (days == 1) return 'Ends tomorrow';
    if (days <= 30) return 'Ends in $days days';
    return 'Ends ${DateFormat('MMM d, yyyy').format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          border: Border.all(
            color: campaign.isJoined ? AppColors.primaryColor.withOpacity(0.15) : AppColors.transparent,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CommonImageView(
                  url: campaign.bannerImage,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (campaign.isJoined)
                  Positioned(
                    top: BaseSpacing.xs,
                    right: BaseSpacing.xs,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.greenSuccess,
                        borderRadius: BorderRadius.circular(BaseRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded, size: 12, color: AppColors.white),
                          const SizedBox(width: 3),
                          CustomText(
                            text: 'Joined',
                            color: AppColors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTextStyles.monoFontFamily,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(BaseSpacing.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: campaign.name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w700,
                  ),
                  if (campaign.description != null && campaign.description!.trim().isNotEmpty) ...[
                    SizedBox(height: BaseSpacing.xxs),
                    CustomText(
                      text: campaign.description!,
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w400,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: BaseSpacing.sm),
                  Wrap(
                    spacing: BaseSpacing.sm,
                    runSpacing: BaseSpacing.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (campaign.hasDiscount) _DiscountBadge(label: campaign.discountLabel),
                      if (_endLabel.isNotEmpty)
                        _InfoChip(icon: Icons.event_outlined, label: _endLabel, warn: campaign.isEnded),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: campaign.isPlatformSponsored
                        // Platform-sponsored campaigns auto-apply to every
                        // store — join/leave are rejected server-side, so
                        // there's nothing actionable to show here.
                        ? _InfoChip(
                            icon: Icons.storefront_rounded,
                            label: 'Platform sale · auto-included',
                          )
                        : campaign.isJoined
                        ? DangerButton(
                            label: 'Leave',
                            onPressed: isProcessing ? null : onLeave,
                            isLoading: isProcessing,
                            expand: false,
                            compact: true,
                          )
                        : PrimaryButton(
                            label: 'Join',
                            onPressed: isProcessing ? null : onJoin,
                            isLoading: isProcessing,
                            expand: false,
                            compact: true,
                          ),
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

class _DiscountBadge extends StatelessWidget {
  final String label;
  const _DiscountBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(BaseRadius.sm),
      ),
      child: CustomText(
        text: label,
        color: AppColors.primaryColor,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
        fontFamily: AppTextStyles.monoFontFamily,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool warn;
  const _InfoChip({required this.icon, required this.label, this.warn = false});

  @override
  Widget build(BuildContext context) {
    final color = warn ? AppColors.red : AppColors.gray600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        SizedBox(width: BaseSpacing.xxs / 2),
        CustomText(
          text: label,
          color: color,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.monoFontFamily,
        ),
      ],
    );
  }
}
