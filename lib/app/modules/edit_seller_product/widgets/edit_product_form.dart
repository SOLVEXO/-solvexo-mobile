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
            const SizedBox(height: 16),
            _PhysicalExtraFields(controller: controller),
          ],
          if (controller.isDigital) ...[
            const SizedBox(height: 16),
            _DigitalExtraFields(controller: controller),
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

// ── Physical extra fields (compareAtPrice, size, color, weight, tags) ────────

class _PhysicalExtraFields extends StatelessWidget {
  final EditSellerProductController controller;
  const _PhysicalExtraFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compare At Price
        const _FieldLabel(label: 'Compare At Price', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller.compareAtPriceCtrl,
          onChanged: (v) => controller.compareAtPrice.value = v,
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
        const SizedBox(height: 16),

        // Size & Color row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: 'Size', optional: true),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: controller.sizeCtrl,
                    onChanged: (v) => controller.size.value = v,
                    hintText: 'e.g. L',
                    isborder: true,
                    fillColor: AppColors.textfldFillColor,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: 'Color', optional: true),
                  const SizedBox(height: 6),
                  CustomTextField(
                    controller: controller.colorCtrl,
                    onChanged: (v) => controller.color.value = v,
                    hintText: 'e.g. Red',
                    isborder: true,
                    fillColor: AppColors.textfldFillColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Shipping Weight
        const _FieldLabel(label: 'Shipping Weight', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller.shippingWeightCtrl,
          onChanged: (v) => controller.shippingWeight.value = v,
          hintText: 'e.g. 0.3kg',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
        const SizedBox(height: 16),

        // Tags
        const _FieldLabel(label: 'Tags', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller.tagsCtrl,
          onChanged: (v) => controller.tags.value = v,
          hintText: 'clothing, cotton, summer',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
      ],
    );
  }
}

// ── Digital extra fields ──────────────────────────────────────────────────────

class _DigitalExtraFields extends StatelessWidget {
  final EditSellerProductController controller;
  const _DigitalExtraFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compare At Price
        const _FieldLabel(label: 'Compare At Price', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller.compareAtPriceCtrl,
          onChanged: (v) => controller.compareAtPrice.value = v,
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
        const SizedBox(height: 16),

        // Downloadable Files
        const _FieldLabel(label: 'Downloadable Files', optional: true),
        const SizedBox(height: 6),
        Obx(() => Column(
              children: [
                ...List.generate(controller.digitalFiles.length, (i) {
                  final entry = controller.digitalFiles[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: entry.urlCtrl,
                                hintText: 'File URL',
                                isborder: true,
                                fillColor: AppColors.textfldFillColor,
                              ),
                              const SizedBox(height: 6),
                              CustomTextField(
                                controller: entry.nameCtrl,
                                hintText: 'File name (e.g. guide.pdf)',
                                isborder: true,
                                fillColor: AppColors.textfldFillColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => controller.removeDigitalFile(i),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove_rounded,
                              size: 18,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                GestureDetector(
                  onTap: controller.addDigitalFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                      color: AppColors.primaryColor.withOpacity(0.04),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded,
                            size: 18, color: AppColors.primaryColor),
                        SizedBox(width: 6),
                        CustomText(
                          text: 'Add File',
                          fontSize: AppFontSize.verySmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 16),

        // Download Limit
        const _FieldLabel(label: 'Download Limit'),
        const SizedBox(height: 6),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!controller.unlimitedDownload.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CustomTextField(
                      controller: controller.downloadLimitCountCtrl,
                      onChanged: (v) => controller.downloadLimitCount.value = v,
                      hintText: 'e.g. 5',
                      isborder: true,
                      fillColor: AppColors.textfldFillColor,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                GestureDetector(
                  onTap: () => controller.unlimitedDownload.toggle(),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: controller.unlimitedDownload.value
                              ? AppColors.primaryColor
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: controller.unlimitedDownload.value
                                ? AppColors.primaryColor
                                : AppColors.lightGrey2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: controller.unlimitedDownload.value
                            ? const Icon(Icons.check_rounded,
                                size: 13, color: AppColors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const CustomText(
                        text: 'Unlimited downloads',
                        fontSize: AppFontSize.verySmall,
                        color: AppColors.black2,
                      ),
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(height: 16),

        // Link Expiry Days
        const _FieldLabel(label: 'Link Expiry Days', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller.linkExpiryDaysCtrl,
          onChanged: (v) => controller.linkExpiryDays.value = v,
          hintText: 'e.g. 30',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // License Type
        const _FieldLabel(label: 'License Type'),
        const SizedBox(height: 6),
        Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey2),
                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                color: AppColors.textfldFillColor,
              ),
              child: Row(
                children: [
                  _LicenseChip(
                    label: 'Personal',
                    selected: controller.licenseType.value == 'personal',
                    onTap: () => controller.licenseType.value = 'personal',
                  ),
                  _LicenseChip(
                    label: 'Commercial',
                    selected: controller.licenseType.value == 'commercial',
                    onTap: () => controller.licenseType.value = 'commercial',
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),

        // PDF Stamping toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
            border: Border.all(color: AppColors.lightGrey2),
          ),
          child: Obx(() => Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      size: 20, color: AppColors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'PDF Stamping',
                          fontSize: AppFontSize.verySmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black2,
                        ),
                        CustomText(
                          text: "Stamp buyer's name/email on each page",
                          fontSize: AppFontSize.tiny,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.pdfStampingEnabled.value,
                    onChanged: (_) => controller.pdfStampingEnabled.toggle(),
                    activeColor: AppColors.primaryColor,
                  ),
                ],
              )),
        ),
        const SizedBox(height: 16),

        // Buyer Delivery Message
        const _FieldLabel(label: 'Buyer Delivery Message', optional: true),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller.buyerDeliveryMsgCtrl,
          onChanged: (v) => controller.buyerDeliveryMessage.value = v,
          hintText: 'Thank you! Here are your download instructions...',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          maxLines: 3,
        ),
      ],
    );
  }
}

class _LicenseChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LicenseChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.grey,
          ),
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
