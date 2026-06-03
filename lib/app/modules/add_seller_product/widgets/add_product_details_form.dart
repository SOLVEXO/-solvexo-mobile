import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductDetailsForm extends StatelessWidget {
  final AddSellerProductController controller;

  const AddProductDetailsForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TypePreviewBadge(controller: controller),
          const SizedBox(height: 20),
          _FormSection(
            label: 'Product Name',
            required: true,
            child: CustomTextField(
              controller: controller.nameCtrl,
              onChanged: (v) => controller.productName.value = v,
              hintText: 'e.g. Grade 5 Math Bundle',
              isborder: true,
              fillColor: AppColors.textfldFillColor,
            ),
          ),
          const SizedBox(height: 16),
          _FormSection(
            label: 'Description',
            child: CustomTextField(
              controller: controller.descCtrl,
              onChanged: (v) => controller.description.value = v,
              hintText: 'Describe your product...',
              isborder: true,
              fillColor: AppColors.textfldFillColor,
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 16),
          _FormSection(
            label: 'Price',
            required: true,
            child: CustomTextField(
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
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (!controller.isPhysical) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FormSection(
                  label: 'Stock Count',
                  child: controller.unlimitedStock.value
                      ? _UnlimitedStockPlaceholder()
                      : CustomTextField(
                          controller: controller.stockCtrl,
                          onChanged: (v) => controller.stock.value = v,
                          hintText: '0',
                          isborder: true,
                          fillColor: AppColors.textfldFillColor,
                          keyboardType: TextInputType.number,
                        ),
                ),
                const SizedBox(height: 10),
                _UnlimitedToggle(controller: controller),
                const SizedBox(height: 16),
              ],
            );
          }),
          _DraftToggle(controller: controller),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Section label wrapper ─────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;

  const _FormSection({
    required this.label,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ── Type badge shown at top of form ──────────────────────────────────────────

class _TypePreviewBadge extends StatelessWidget {
  final AddSellerProductController controller;

  const _TypePreviewBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            ),
            child: Text(
              controller.selectedTypeEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'Product Details',
                fontSize: AppFontSize.medium,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              CustomText(
                text: '${controller.selectedTypeName} product',
                fontSize: AppFontSize.verySmall,
                color: AppColors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Unlimited stock toggle ────────────────────────────────────────────────────

class _UnlimitedStockPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
  final AddSellerProductController controller;

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

// ── Save as draft toggle ──────────────────────────────────────────────────────

class _DraftToggle extends StatelessWidget {
  final AddSellerProductController controller;

  const _DraftToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: Obx(
        () => Row(
          children: [
            const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.grey),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Save as draft',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                  CustomText(
                    text: 'Publish later from Products',
                    fontSize: AppFontSize.tiny,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
            Switch(
              value: controller.saveAsDraft.value,
              onChanged: (_) => controller.saveAsDraft.toggle(),
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
