import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_onboarding/controllers/seller_onboarding_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step4WhatYouSellGrid extends StatelessWidget {
  final SellerOnboardingController controller;

  const Step4WhatYouSellGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const CustomText(
            text: 'What will you sell?',
            fontSize: AppFontSize.veryLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const CustomText(
            text: 'Select all that apply — we\'ll activate the right tools for you.',
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Obx(
            () => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: kWhatYouSell
                  .map(
                    (d) => _SellCard(
                      data: d,
                      isSelected: controller.whatYouSell.contains(d.option),
                      onTap: () => controller.toggleWhatYouSell(d.option),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final tools = controller.activatedTools;
            if (tools.isEmpty) return const SizedBox.shrink();
            return _ToolsPanel(tools: tools);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SellCard extends StatelessWidget {
  final WhatYouSellData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _SellCard({required this.data, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.emoji, style: const TextStyle(fontSize: 30)),
                _CheckBadge(isSelected: isSelected),
              ],
            ),
            const SizedBox(height: 10),
            CustomText(
              text: data.name,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryColor : AppColors.black,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: data.description,
              fontSize: AppFontSize.verySmall,
              color: AppColors.grey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckBadge extends StatelessWidget {
  final bool isSelected;
  const _CheckBadge({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primaryColor : AppColors.white,
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 12, color: AppColors.white)
          : null,
    );
  }
}

// ── Tools activated panel ─────────────────────────────────────────────────────

class _ToolsPanel extends StatelessWidget {
  final List<ActivatedTool> tools;
  const _ToolsPanel({required this.tools});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.languageBg,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('✨', style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
                CustomText(
                  text: "We'll activate these tools for you:",
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tools
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: t.bgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomText(
                        text: t.name,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                        color: t.textColor,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
