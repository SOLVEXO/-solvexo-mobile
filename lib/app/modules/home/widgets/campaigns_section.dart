import 'dart:async';

import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/marketing/public_campaign_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/home_section_header.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// "Deals & Campaigns" — one currently-active platform marketing campaign
/// shown full-width at a time, auto-advancing every 5s (same cadence/pattern
/// as the hero `BannerCarousel`), each with a live countdown to its
/// `endDate` — the flash-deal treatment used by most large marketplace apps.
/// Renders nothing while unloaded/empty (never a broken section).
class CampaignsSection extends StatefulWidget {
  const CampaignsSection({super.key});

  @override
  State<CampaignsSection> createState() => _CampaignsSectionState();
}

class _CampaignsSectionState extends State<CampaignsSection> {
  final HomeController controller = Get.find<HomeController>();
  final PageController _pageController = PageController();
  final RxInt _pageIndex = 0.obs;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Started once here (not from `build()`) and cancelled in `dispose()` —
    // same fix/reasoning as `BannerCarousel`'s auto-scroll timer: a timer
    // kicked off from `build()` restarts on every rebuild and stacks up.
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final campaigns = controller.campaigns;
      if (!_pageController.hasClients || campaigns.length < 2) return;
      final nextPage = (_pageIndex.value + 1) % campaigns.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final campaigns = controller.campaigns;
      if (campaigns.isEmpty) return const SizedBox.shrink();

      // Auto-scroll only makes sense with more than one deal; a lone
      // campaign just sits still and still shows its countdown.
      final showIndicator = campaigns.length > 1;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: BaseSpacing.sm),
          const HomeSectionHeader(title: 'Deals & Campaigns'),
          SizedBox(height: BaseSpacing.xs),
          SizedBox(
            height: 110,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => _pageIndex.value = i,
              itemCount: campaigns.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
                child: _CampaignCard(campaign: campaigns[i]),
              ),
            ),
          ),
          if (showIndicator) ...[
            SizedBox(height: BaseSpacing.xs),
            Center(
              child: Obx(
                () => SmoothIndicator(
                  offset: _pageIndex.value.toDouble(),
                  count: campaigns.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    spacing: 6,
                    activeDotColor: AppColors.primaryColor,
                    dotColor: AppColors.shimmerBase,
                  ),
                  size: Size(Get.width * 0.18, 20),
                ),
              ),
            ),
          ],
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(BaseRadius.lg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CommonImageView(
            url: campaign.bannerImage,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Bottom scrim so name/countdown stay legible over any image.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent, Colors.black87],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          if (discountLabel != null)
            Positioned(
              top: BaseSpacing.sm,
              left: BaseSpacing.sm,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(BaseRadius.sm),
                ),
                child: CustomText(
                  text: discountLabel,
                  color: AppColors.white,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          Positioned(
            left: BaseSpacing.sm,
            right: BaseSpacing.sm,
            bottom: BaseSpacing.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: campaign.name,
                  color: AppColors.white,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.w800,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (campaign.description.trim().isNotEmpty) ...[
                  SizedBox(height: 2),
                  CustomText(
                    text: campaign.description,
                    color: AppColors.white.withOpacity(0.85),
                    fontSize: AppFontSize.tiny,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: BaseSpacing.xs),
                if (campaign.endDate != null)
                  _CampaignCountdown(endDate: campaign.endDate!)
                else if (campaign.storeCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront_rounded, size: 13, color: AppColors.white),
                      SizedBox(width: 4),
                      CustomText(
                        text: '${campaign.storeCount} stores',
                        color: AppColors.white,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  )
                else
                  CustomText(
                    text: 'Limited time',
                    color: AppColors.white,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ticks once a second on its own (independent of the carousel's auto-scroll
/// timer) so only the currently-built card pays for the rebuild — PageView
/// disposes off-screen pages by default, so this timer's lifecycle is
/// naturally scoped to "this card is the visible one (or its neighbor)".
class _CampaignCountdown extends StatefulWidget {
  final DateTime endDate;
  const _CampaignCountdown({required this.endDate});

  @override
  State<_CampaignCountdown> createState() => _CampaignCountdownState();
}

class _CampaignCountdownState extends State<_CampaignCountdown> {
  Timer? _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endDate.difference(DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = widget.endDate.difference(DateTime.now());
      setState(() => _remaining = next);
      if (next.isNegative) _ticker?.cancel();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return const CustomText(
        text: 'Deal ended',
        color: AppColors.white,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 13, color: AppColors.white),
        SizedBox(width: 4),
        CustomText(
          text: 'Ends in',
          color: AppColors.white.withOpacity(0.85),
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(width: BaseSpacing.xxs),
        if (days > 0) ...[_digitBox(days), _colon()],
        _digitBox(hours),
        _colon(),
        _digitBox(minutes),
        _colon(),
        _digitBox(seconds),
      ],
    );
  }

  Widget _digitBox(int value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(BaseRadius.xs),
    ),
    child: CustomText(
      text: value.toString().padLeft(2, '0'),
      color: AppColors.white,
      fontSize: AppFontSize.tiny,
      fontWeight: FontWeight.w800,
    ),
  );

  Widget _colon() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: CustomText(
      text: ':',
      color: AppColors.white,
      fontSize: AppFontSize.tiny,
      fontWeight: FontWeight.w800,
    ),
  );
}
