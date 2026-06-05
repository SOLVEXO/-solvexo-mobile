import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/controllers/seller_ai_studio_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiCreditsBanner extends StatelessWidget {
  final SellerAiStudioController controller;

  const AiCreditsBanner({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(
          AppDimen.serviceCountTileRadius + 4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _LeftContent()),
          SizedBox(width: Get.width / 4),
          _RightCredits(controller: controller),
        ],
      ),
    );
  }
}

class _LeftContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            SvgIcon(
              assetName: AppIcons.aiBeautyIcon,
              color: AppColors.yellow,
              size: 22,
            ),
            SizedBox(width: 6),
            CustomText(
              text: 'AI Studio',
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const CustomText(
          text: 'Your intelligent co-pilot for\nlistings, pricing & content.',
          fontSize: AppFontSize.tiny,
          color: AppColors.iosGrey,
        ),
        const SizedBox(height: 14),
        AppButton(
          label: "Buy Credits",
          iconWidget: SvgIcon(
            assetName: AppIcons.aiStudioIcon,
            color: AppColors.yellow,
          ),
          onPressed: () {},
          isOutlined: true,
          height: 35,
        ),
      ],
    );
  }
}

class _RightCredits extends StatelessWidget {
  final SellerAiStudioController controller;
  const _RightCredits({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(
          () => CustomText(
            text: '${controller.credits.value}',
            fontSize: AppFontSize.veryLarge3,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const CustomText(
          text: 'AI credits left',
          fontSize: AppFontSize.tiny,
          color: AppColors.iosGrey,
        ),
        const SizedBox(height: 8),
        _CreditsBar(controller: controller),
      ],
    );
  }
}

class _CreditsBar extends StatelessWidget {
  final SellerAiStudioController controller;
  const _CreditsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: 90,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: controller.creditsProgress,
                backgroundColor: AppColors.darkDivider,
                color: AppColors.primaryColor,
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 4),
            CustomText(
              text: '${controller.credits.value} / $kMonthlyCredits this month',
              fontSize: 8,
              color: AppColors.inactiveGrey,
            ),
          ],
        ),
      ),
    );
  }
}
