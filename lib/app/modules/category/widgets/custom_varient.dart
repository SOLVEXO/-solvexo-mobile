import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomVarient extends StatelessWidget {
  CustomVarient({super.key});

  final controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = controller.selectedProduct.value;
      if (product == null || product.variants.isEmpty) {
        return const SizedBox.shrink();
      }

      final colors = product.availableColors;
      final sizes = product.availableSizes;

      if (colors.isEmpty && sizes.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colors ──────────────────────────────────────────────────
          if (colors.isNotEmpty) ...[
            _VariantSectionLabel(text: 'Color'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                final isSelected =
                    controller.selectedVariantIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.selectVariant(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.lightGrey,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: CustomText(
                      text: color,
                      fontSize: AppFontSize.small2,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (sizes.isNotEmpty) const SizedBox(height: 18),
          ],

          // ── Sizes ────────────────────────────────────────────────────
          if (sizes.isNotEmpty) ...[
            _VariantSectionLabel(text: 'Size'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sizes.asMap().entries.map((entry) {
                // final index = entry.key;
                final size = entry.value;

                // Find variant index matching this size
                final variantIndex = product.variants.indexWhere(
                  (v) => v.size == size,
                );
                final isSelected =
                    controller.selectedVariantIndex.value == variantIndex;

                // Check stock for this size
                final outOfStock = variantIndex != -1
                    ? !product.variants[variantIndex].isInStock
                    : true;

                return GestureDetector(
                  onTap: outOfStock
                      ? null
                      : () => controller.selectVariant(variantIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: outOfStock
                          ? AppColors.lightGrey.withOpacity(0.3)
                          : isSelected
                          ? AppColors.primaryColor
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: outOfStock
                            ? AppColors.lightGrey
                            : isSelected
                            ? AppColors.primaryColor
                            : AppColors.lightGrey,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomText(
                          text: size,
                          fontSize: AppFontSize.small2,
                          fontWeight: FontWeight.w600,
                          color: outOfStock
                              ? AppColors.gray600
                              : isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                        // Strikethrough line for out-of-stock sizes
                        if (outOfStock)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _StrikethroughPainter(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Selected variant price hint ───────────────────────────────
          Obx(() {
            final idx = controller.selectedVariantIndex.value;
            if (idx < 0 || idx >= product.variants.length) {
              return const SizedBox.shrink();
            }
            final variant = product.variants[idx];
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: 'SKU: ${variant.sku}',
                      fontSize: AppFontSize.small,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: variant.isInStock
                          ? AppColors.green2.withOpacity(0.10)
                          : AppColors.red.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: variant.isUnlimited
                          ? '∞ Unlimited'
                          : variant.isInStock
                          ? '${variant.stock} in stock'
                          : 'Out of stock',
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w600,
                      color: variant.isInStock
                          ? AppColors.green2
                          : AppColors.red,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    });
  }
}

// ─── Section label ─────────────────────────────────────────────────────────

class _VariantSectionLabel extends StatelessWidget {
  final String text;
  const _VariantSectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        CustomText(
          text: text,
          fontSize: AppFontSize.regular,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

// ─── Strikethrough painter for out-of-stock sizes ──────────────────────────

class _StrikethroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.greySwatch400
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
