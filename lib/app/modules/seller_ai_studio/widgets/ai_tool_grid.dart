import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/controllers/seller_ai_studio_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiToolGrid extends StatelessWidget {
  final SellerAiStudioController controller;

  const AiToolGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: kAiTools
            .map(
              (t) => _ToolCard(
                data: t,
                isSelected: controller.selectedTool.value == t.tool,
                onTap: () => controller.selectTool(t.tool),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final AiToolData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolCard({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.06)
              : AppColors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgIcon(assetName: data.emoji, size: 22),
                _CreditChip(cost: data.creditCost, isSelected: isSelected),
              ],
            ),
            const SizedBox(height: 10),
            CustomText(
              text: data.name,
              fontSize: AppFontSize.extraSmall,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryColor : AppColors.black,
            ),
            const SizedBox(height: 3),
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

class _CreditChip extends StatelessWidget {
  final int cost;
  final bool isSelected;

  const _CreditChip({required this.cost, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.12)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomText(
        text: '$cost cr',
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: isSelected ? AppColors.primaryColor : AppColors.lightGrey5,
      ),
    );
  }
}
