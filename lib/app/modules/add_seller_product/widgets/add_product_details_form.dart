import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/digital_file_upload_tile.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/education_level_picker_sheet.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/product_publish_mode_selector.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/shared_form_widgets.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/subcategory_picker_sheet.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/variant_card.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
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

          // ── Product Name ────────────────────────────────────────────
          FormFieldSection(
            label: 'Product Name',
            required: true,
            child: CustomTextField(
              controller: controller.nameCtrl,
              onChanged: (v) => controller.productName.value = v,
              hintText: 'e.g. Cotton T-Shirt',
              isborder: true,
              fillColor: AppColors.textfldFillColor,
            ),
          ),
          const SizedBox(height: 16),

          // ── Description ─────────────────────────────────────────────
          FormFieldSection(
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

          // ── Product Images ──────────────────────────────────────────
          ImagesSection(
            label: 'Product Images',
            hint: 'Up to 5 images — shared gallery for the product',
            images: controller.productImages,
            isUploading: controller.isUploadingImage,
            onAdd: controller.pickAndUploadImage,
            onRemove: controller.removeImage,
          ),
          const SizedBox(height: 16),

          // ── Price (digital/educational only — physical prices live per-variant) ──
          Obx(() {
            if (controller.isPhysical) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormFieldSection(
                  label: 'Price',
                  required: true,
                  child: CustomTextField(
                    controller: controller.priceCtrl,
                    onChanged: (v) => controller.price.value = v,
                    hintText: '0.00',
                    isborder: true,
                    fillColor: AppColors.textfldFillColor,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
              ],
            );
          }),

          // ── Physical-product-only fields ────────────────────────────
          Obx(() {
            if (!controller.isPhysical) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variants (each carries its own price/stock/attributes/images)
                FormFieldSection(
                  label: 'Variants',
                  required: true,
                  hint: 'Add one card per option combination (e.g. color/size)',
                  child: Obx(() => Column(
                        children: [
                          ...List.generate(controller.variants.length, (i) => VariantCard(
                                key: ValueKey(i),
                                index: i,
                                entry: controller.variants[i],
                                canRemove: controller.variants.length > 1,
                                onRemove: () => controller.removeVariant(i),
                                onSetDefault: () => controller.setDefaultVariant(i),
                                onAddImage: () => controller.pickAndUploadVariantImage(i),
                                onRemoveImage: (imgIdx) => controller.removeVariantImage(i, imgIdx),
                              )),
                          GestureDetector(
                            onTap: controller.addVariant,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryColor.withOpacity(0.4),
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                                color: AppColors.primaryColor.withOpacity(0.04),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 18,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(width: 6),
                                  CustomText(
                                    text: 'Add Variant',
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
                ),
                const SizedBox(height: 16),

                // Tags
                FormFieldSection(
                  label: 'Tags',
                  hint: 'Comma-separated, e.g. clothing, cotton',
                  child: CustomTextField(
                    controller: controller.tagsCtrl,
                    onChanged: (v) => controller.tags.value = v,
                    hintText: 'clothing, cotton, summer',
                    isborder: true,
                    fillColor: AppColors.textfldFillColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Subcategory (optional)
                _SubcategoryField(controller: controller),
                const SizedBox(height: 16),

                // List on Solvexo Marketplace toggle
                _ListedToggle(controller: controller),
                const SizedBox(height: 16),
              ],
            );
          }),

          // ── Digital / Educational-product-only fields ───────────────
          // Educational resources reuse the digital delivery mechanism
          // (files, license, download limits) plus an education-level tag.
          Obx(() {
            if (!controller.isDigital && !controller.isEducational) {
              return const SizedBox.shrink();
            }
            return _DigitalFields(controller: controller);
          }),

          // ── Availability (publish now / schedule / draft) ───────────
          Obx(() => ProductPublishModeSelector(
                mode: controller.publishMode.value,
                onModeChanged: (m) => controller.publishMode.value = m,
                scheduledAt: controller.scheduledAt.value,
                onScheduledAtChanged: (dt) => controller.scheduledAt.value = dt,
              )),
          const SizedBox(height: 8),
        ],
      ),
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
            child: CustomText(
              text: controller.selectedTypeEmoji,
              fontSize: 24,
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

// ── List on Solvexo toggle ────────────────────────────────────────────────────

class _SubcategoryField extends StatelessWidget {
  final AddSellerProductController controller;
  const _SubcategoryField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormFieldSection(
      label: 'Subcategory',
      hint: 'Optional — helps buyers find this product more precisely',
      child: Obx(
        () => GestureDetector(
          onTap: () => SubcategoryPickerSheet.show(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.textfldFillColor,
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              border: Border.all(color: AppColors.lightGrey, width: 0.3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: controller.selectedSubCategoryName.value.isEmpty
                        ? 'None selected'
                        : controller.selectedSubCategoryName.value,
                    fontSize: AppFontSize.verySmall,
                    color: controller.selectedSubCategoryName.value.isEmpty
                        ? AppColors.grey
                        : AppColors.black,
                  ),
                ),
                controller.isLoadingSubcategories.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                      )
                    : const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Education level field (educational products only) ────────────────────────

class _EducationLevelField extends StatelessWidget {
  final AddSellerProductController controller;
  const _EducationLevelField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormFieldSection(
      label: 'Education Level',
      required: true,
      child: Obx(
        () => GestureDetector(
          onTap: () => EducationLevelPickerSheet.show(context, controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.textfldFillColor,
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              border: Border.all(color: AppColors.lightGrey, width: 0.3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: controller.educationLevel.value == null
                        ? 'Select a level'
                        : educationLevelLabel(controller.educationLevel.value),
                    fontSize: AppFontSize.verySmall,
                    color: controller.educationLevel.value == null
                        ? AppColors.grey
                        : AppColors.black,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom level field + autocomplete (only when level == 'other') ───────────

class _CustomLevelField extends StatelessWidget {
  final AddSellerProductController controller;
  const _CustomLevelField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormFieldSection(
      label: 'Custom Level',
      required: true,
      hint: 'e.g. "Grade 5", "O-Level", "Hifz"',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller.customLevelCtrl,
            onChanged: controller.onCustomLevelChanged,
            hintText: 'Enter a custom level',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
          ),
          Obx(() {
            if (controller.customLevelSuggestions.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.customLevelSuggestions
                    .map((s) => GestureDetector(
                          onTap: () => controller.selectCustomLevelSuggestion(s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                            ),
                            child: CustomText(
                              text: s,
                              fontSize: AppFontSize.tiny,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ListedToggle extends StatelessWidget {
  final AddSellerProductController controller;
  const _ListedToggle({required this.controller});

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
            const Icon(
              Icons.store_rounded,
              size: 20,
              color: AppColors.grey,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'List on Solvexo Marketplace',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                  CustomText(
                    text: 'Make visible to all marketplace buyers',
                    fontSize: AppFontSize.tiny,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
            Switch(
              value: controller.isListedOnSolvexo.value,
              onChanged: (_) => controller.isListedOnSolvexo.toggle(),
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Digital-only fields ───────────────────────────────────────────────────────

class _DigitalFields extends StatelessWidget {
  final AddSellerProductController controller;
  const _DigitalFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Education Level (educational products only)
        Obx(() {
          if (!controller.isEducational) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EducationLevelField(controller: controller),
              const SizedBox(height: 16),
              if (controller.needsCustomLevel) ...[
                _CustomLevelField(controller: controller),
                const SizedBox(height: 16),
              ],
            ],
          );
        }),

        // Compare At Price
        FormFieldSection(
          label: 'Compare At Price',
          hint: 'Original / crossed-out price',
          child: CustomTextField(
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
        ),
        const SizedBox(height: 16),

        // Downloadable Files
        FormFieldSection(
          label: 'Downloadable Files',
          hint: 'Add file URL and display name',
          child: Obx(() => Column(
                children: [
                  ...List.generate(controller.digitalFiles.length, (i) {
                    return DigitalFileUploadTile(
                      key: ValueKey(i),
                      entry: controller.digitalFiles[i],
                      onPickFile: () => controller.pickAndUploadDigitalFile(i),
                      onRemove: () => controller.removeDigitalFile(i),
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
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                        color: AppColors.primaryColor.withOpacity(0.04),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: AppColors.primaryColor,
                          ),
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
        ),
        const SizedBox(height: 16),

        // Download Limit
        FormFieldSection(
          label: 'Download Limit',
          hint: 'How many times the buyer can download',
          child: Obx(() => Column(
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
                              ? const Icon(Icons.check_rounded, size: 13, color: AppColors.white)
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
        ),
        const SizedBox(height: 16),

        // Link Expiry Days
        FormFieldSection(
          label: 'Link Expiry Days',
          hint: 'Leave empty for no expiry',
          child: CustomTextField(
            controller: controller.linkExpiryDaysCtrl,
            onChanged: (v) => controller.linkExpiryDays.value = v,
            hintText: 'e.g. 30',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 16),

        // PDF Stamping + License Type row
        Row(
          children: [
            Expanded(
              child: FormFieldSection(
                label: 'License Type',
                child: Obx(() => Container(
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
              ),
            ),
          ],
        ),
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
                  const Icon(Icons.picture_as_pdf_rounded, size: 20, color: AppColors.grey),
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

        // Buyer preview toggle — lets buyers view a watermarked/trimmed
        // sample (first pages/seconds) before purchasing, using the first
        // uploaded file as the source. Never exposes the original file.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
            border: Border.all(color: AppColors.lightGrey2),
          ),
          child: Obx(() => Row(
                children: [
                  const Icon(Icons.visibility_outlined, size: 20, color: AppColors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Let buyers preview before buying',
                          fontSize: AppFontSize.verySmall,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black2,
                        ),
                        CustomText(
                          text: 'Shows a watermarked sample of your first file',
                          fontSize: AppFontSize.tiny,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.previewEnabled.value,
                    onChanged: (_) => controller.previewEnabled.toggle(),
                    activeColor: AppColors.primaryColor,
                  ),
                ],
              )),
        ),
        const SizedBox(height: 16),

        // Subcategory (optional)
        _SubcategoryField(controller: controller),
        const SizedBox(height: 16),

        // List on Solvexo toggle (shared)
        _ListedToggle(controller: controller),
        const SizedBox(height: 16),

        // Tags
        FormFieldSection(
          label: 'Tags',
          hint: 'Comma-separated, e.g. ebook, design',
          child: CustomTextField(
            controller: controller.tagsCtrl,
            onChanged: (v) => controller.tags.value = v,
            hintText: 'ebook, design, template',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
          ),
        ),
        const SizedBox(height: 16),

        // Buyer Delivery Message
        FormFieldSection(
          label: 'Buyer Delivery Message',
          hint: 'Optional note shown to buyer after purchase',
          child: CustomTextField(
            controller: controller.buyerDeliveryMsgCtrl,
            onChanged: (v) => controller.buyerDeliveryMessage.value = v,
            hintText: 'Thank you! Here are your download instructions...',
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LicenseChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LicenseChip({required this.label, required this.selected, required this.onTap});

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
            fontFamily: AppTextStyles.monoFontFamily,
          ),
        ),
      ),
    );
  }
}

