import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class AddProductTypeGrid extends StatelessWidget {
  final AddSellerProductController controller;

  const AddProductTypeGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Product type',
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingTypes.value) {
              return const _TypeGridShimmer();
            }
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: controller.availableTypes
                  .map(
                    (t) => _TypeCard(
                      data: t,
                      isSelected: controller.selectedType.value == t.type,
                      onTap: () => controller.selectType(t.type),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// ── Shimmer skeleton for the type grid ───────────────────────────────────────

class _TypeGridShimmer extends StatelessWidget {
  const _TypeGridShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
        children: List.generate(4, (_) => const _ShimmerTypeCard()),
      ),
    );
  }
}

class _ShimmerTypeCard extends StatelessWidget {
  const _ShimmerTypeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Skeleton(height: 40, width: 40, cornerRadius: 8),
          SizedBox(height: 10),
          Skeleton(height: 14, width: 70),
          SizedBox(height: 6),
          Skeleton(height: 11, width: 90),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final ProductTypeData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
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
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(data.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            CustomText(
              text: data.name,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryColor : AppColors.black,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: data.subtitle,
              fontSize: AppFontSize.tiny,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
