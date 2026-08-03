import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/app/modules/product_details/widgets/product_section_title.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One chip row per seller-defined attribute (e.g. Color, Size, Material)
/// plus the selected variant's SKU + stock badge.
class ProductVariantSelector extends StatelessWidget {
  final ProductDetailController controller;
  final ProductModel product;

  const ProductVariantSelector({
    super.key,
    required this.controller,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final variants = controller.variants;
      if (variants.isEmpty) return const SizedBox.shrink();

      final optionValues = product.availableOptionValues;
      if (optionValues.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in optionValues.entries) ...[
            ProductSectionTitle(entry.key),
            SizedBox(height: BaseSpacing.xs),
            _OptionChipWrap(
              controller: controller,
              name: entry.key,
              values: entry.value,
            ),
            SizedBox(height: BaseSpacing.sm),
          ],
          _SelectedVariantBadgeRow(controller: controller),
        ],
      );
    });
  }
}

// ─── Attribute value chip wrap ──────────────────────────────────────────────

class _OptionChipWrap extends StatelessWidget {
  final ProductDetailController controller;
  final String name;
  final List<String> values;

  const _OptionChipWrap({
    required this.controller,
    required this.name,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedValue = controller.selectedOptions[name];
      return Wrap(
        spacing: BaseSpacing.xs,
        runSpacing: BaseSpacing.xs,
        children: values.map((value) {
          final isSelected = selectedValue == value;
          final available = controller.isOptionValueAvailable(name, value);
          return Semantics(
            button: true,
            selected: isSelected,
            enabled: available,
            label: available ? '$name $value' : '$name $value, unavailable',
            child: GestureDetector(
              onTap: available
                  ? () => controller.selectOption(name, value)
                  : null,
              child: AnimatedContainer(
                duration: BaseMotion.normal,
                constraints: const BoxConstraints(minHeight: 40),
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSpacing.xs + 2,
                  vertical: BaseSpacing.xxs + 1,
                ),
                decoration: BoxDecoration(
                  color: !available
                      ? AppColors.lightGrey.withOpacity(0.3)
                      : isSelected
                      ? AppColors.primaryColor
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(BaseRadius.sm),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: value,
                  color: !available
                      ? AppColors.gray600
                      : isSelected
                      ? AppColors.white
                      : AppColors.textPrimary,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

// ─── Selected variant SKU + stock badge ─────────────────────────────────────

class _SelectedVariantBadgeRow extends StatelessWidget {
  final ProductDetailController controller;
  const _SelectedVariantBadgeRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final v = controller.selectedVariant.value;
      if (v == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: BaseSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: BaseSpacing.xs + 2,
                vertical: BaseSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(BaseRadius.pill),
              ),
              child: CustomText(
                text: 'SKU: ${v.sku}',
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (controller.isLoadingVariant.value)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSpacing.xs + 2,
                  vertical: BaseSpacing.xxs + 1,
                ),
                decoration: BoxDecoration(
                  color: v.isInStock
                      ? AppColors.green2.withOpacity(0.10)
                      : AppColors.red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                child: CustomText(
                  text: v.isUnlimited
                      ? '∞ Unlimited'
                      : v.isInStock
                      ? '${v.stock} in stock'
                      : 'Out of stock',
                  color: v.isInStock ? AppColors.green2 : AppColors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      );
    });
  }
}
