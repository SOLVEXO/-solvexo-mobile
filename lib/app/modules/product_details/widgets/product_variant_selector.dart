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

/// Color/size variant chips plus the selected variant's SKU + stock badge.
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.availableColors.isNotEmpty) ...[
            const ProductSectionTitle('Color'),
            SizedBox(height: BaseSpacing.xs),
            _VariantChipWrap(
              controller: controller,
              variants: variants.where((v) => v.color != null && v.color!.isNotEmpty),
              labelOf: (v) => v.color!,
              semanticsLabelOf: (v) => 'Color ${v.color}',
            ),
          ],
          if (product.availableSizes.isNotEmpty) ...[
            SizedBox(height: BaseSpacing.sm),
            const ProductSectionTitle('Size'),
            SizedBox(height: BaseSpacing.xs),
            _VariantChipWrap(
              controller: controller,
              variants: variants.where((v) => v.size != null && v.size!.isNotEmpty),
              labelOf: (v) => v.size!,
              semanticsLabelOf: (v) => v.isInStock ? 'Size ${v.size}' : 'Size ${v.size}, out of stock',
              disabledIf: (v) => !v.isInStock,
            ),
          ],
          _SelectedVariantBadgeRow(controller: controller),
        ],
      );
    });
  }
}

// ─── Color/Size chip wrap ───────────────────────────────────────────────────

class _VariantChipWrap extends StatelessWidget {
  final ProductDetailController controller;
  final Iterable<ProductVariant> variants;
  final String Function(ProductVariant) labelOf;
  final String Function(ProductVariant) semanticsLabelOf;
  final bool Function(ProductVariant) disabledIf;

  const _VariantChipWrap({
    required this.controller,
    required this.variants,
    required this.labelOf,
    required this.semanticsLabelOf,
    this.disabledIf = _neverDisabled,
  });

  static bool _neverDisabled(ProductVariant v) => false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BaseSpacing.xs,
      runSpacing: BaseSpacing.xs,
      children: variants.map((v) {
        final isSelected = controller.selectedVariant.value?.id == v.id;
        final disabled = disabledIf(v);
        return Semantics(
          button: true,
          selected: isSelected,
          enabled: !disabled,
          label: semanticsLabelOf(v),
          child: GestureDetector(
            onTap: disabled ? null : () => controller.selectVariant(v),
            child: AnimatedContainer(
              duration: BaseMotion.normal,
              constraints: const BoxConstraints(minHeight: 40),
              padding: EdgeInsets.symmetric(
                horizontal: BaseSpacing.xs + 2,
                vertical: BaseSpacing.xxs + 1,
              ),
              decoration: BoxDecoration(
                color: disabled
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
                text: labelOf(v),
                color: disabled
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
