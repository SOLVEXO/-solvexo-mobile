import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProductForm extends StatelessWidget {
  final EditSellerProductController controller;

  const EditProductForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: 'Product Name', required: true),
          const SizedBox(height: 6),
          CustomTextField(
            controller: controller.nameCtrl,
            onChanged: (v) => controller.name.value = v,
            hintText: 'e.g. Grade 5 Math Bundle',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Description', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            controller: controller.descCtrl,
            onChanged: (v) => controller.description.value = v,
            hintText: 'Describe your product...',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _FieldLabel(label: 'Price', required: true),
          const SizedBox(height: 6),
          CustomTextField(
            controller: controller.priceCtrl,
            onChanged: (v) => controller.price.value = v,
            hintText: '0.00',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 6),
              child: CustomText(
                text: '\$',
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ),
          if (controller.isPhysical) ...[
            const SizedBox(height: 16),
            _StockSection(controller: controller),
          ],
        ],
      ),
    );
  }
}

// ── Stock section (Physical only) ─────────────────────────────────────────────

class _StockSection extends StatelessWidget {
  final EditSellerProductController controller;
  const _StockSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel(label: 'Stock Count'),
          const SizedBox(height: 6),
          controller.unlimitedStock.value
              ? _UnlimitedPlaceholder()
              : CustomTextField(
                  controller: controller.stockCtrl,
                  onChanged: (v) => controller.stock.value = v,
                  hintText: '0',
                  isborder: true,
                  fillColor: AppColors.textfldFillColor,
                  keyboardType: TextInputType.number,
                ),
          const SizedBox(height: 10),
          _UnlimitedToggle(controller: controller),
        ],
      ),
    );
  }
}

class _UnlimitedPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.greenContainerInnerColor,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        border: Border.all(color: AppColors.darkGreen.withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.all_inclusive_rounded, size: 18, color: AppColors.darkGreen),
          SizedBox(width: 8),
          CustomText(
            text: 'Unlimited stock',
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
          ),
        ],
      ),
    );
  }
}

class _UnlimitedToggle extends StatelessWidget {
  final EditSellerProductController controller;
  const _UnlimitedToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.unlimitedStock.toggle(),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: controller.unlimitedStock.value
                    ? AppColors.primaryColor
                    : AppColors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: controller.unlimitedStock.value
                      ? AppColors.primaryColor
                      : AppColors.lightGrey2,
                ),
              ),
              alignment: Alignment.center,
              child: controller.unlimitedStock.value
                  ? const Icon(Icons.check_rounded, size: 13, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'Unlimited stock',
              fontSize: AppFontSize.verySmall,
              color: AppColors.black2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final bool optional;

  const _FieldLabel({
    required this.label,
    this.required = false,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(
          text: label,
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black2,
        ),
        if (required)
          const CustomText(
            text: ' *',
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w600,
            color: AppColors.red,
          ),
        if (optional)
          const CustomText(
            text: ' (optional)',
            fontSize: AppFontSize.tiny,
            color: AppColors.grey,
          ),
      ],
    );
  }
}
