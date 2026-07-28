import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/marketing/public_campaign_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/home_section_header.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// "Deals & Campaigns" — a horizontally-scrolling row of currently-active
/// platform marketing campaigns, sitting right after the promo banner
/// carousel. Renders nothing while unloaded/empty (never a broken section).
class CampaignsSection extends StatelessWidget {
  CampaignsSection({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final campaigns = controller.campaigns;
      if (campaigns.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: BaseSpacing.sm),
          const HomeSectionHeader(title: 'Deals & Campaigns'),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
              itemCount: campaigns.length,
              separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.sm),
              itemBuilder: (_, i) => _CampaignCard(campaign: campaigns[i]),
            ),
          ),
        ],
      );
    });
  }
}

class _CampaignCard extends StatelessWidget {
  final PublicCampaignModel campaign;
  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final discountLabel = campaign.discountLabel;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CommonImageView(
                url: campaign.bannerImage,
                height: 88,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              if (discountLabel != null)
                Positioned(
                  top: BaseSpacing.xs,
                  left: BaseSpacing.xs,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: BaseSpacing.xs,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(BaseRadius.sm),
                    ),
                    child: CustomText(
                      text: discountLabel,
                      color: AppColors.white,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(BaseSpacing.xs + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: campaign.name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  CustomText(
                    text: campaign.description,
                    color: AppColors.gray600,
                    fontSize: AppFontSize.tiny,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_rounded,
                        size: 12,
                        color: AppColors.gray600,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: CustomText(
                          text: campaign.storeCount > 0
                              ? '${campaign.storeCount} stores${_endsLabel(campaign.endDate)}'
                              : _endsLabel(campaign.endDate).trim().isEmpty
                              ? 'Limited time'
                              : _endsLabel(campaign.endDate).replaceFirst(' · ', ''),
                          color: AppColors.gray600,
                          fontSize: AppFontSize.tiny,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _endsLabel(DateTime? endDate) {
    if (endDate == null) return '';
    return ' · ends ${DateFormat('MMM d').format(endDate)}';
  }
}
