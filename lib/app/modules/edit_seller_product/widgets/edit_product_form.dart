import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/digital_file_upload_tile.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/product_publish_mode_selector.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/shared_form_widgets.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/variant_card.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/app/modules/seller/widgets/publish_fields_section.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
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
          ImagesSection(
            label: 'Product Images',
            hint: 'Up to 5 images — shared gallery for the product',
            images: controller.productImages,
            isUploading: controller.isUploadingImage,
            onAdd: controller.pickAndUploadImage,
            onRemove: controller.removeImage,
          ),
          const SizedBox(height: 16),
          _PublishFields(controller: controller),
          const SizedBox(height: 16),
          if (!controller.isPhysical) ...[
            FormFieldSection(
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
          ],
          if (controller.isPhysical) ...[
            _VariantsSection(controller: controller),
            const SizedBox(height: 16),
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
          if (controller.isDigital) ...[
            const SizedBox(height: 16),
            _DigitalExtraFields(controller: controller),
          ],
          const SizedBox(height: 16),
          Obx(() => ProductPublishModeSelector(
                mode: controller.publishMode.value,
                onModeChanged: (m) => controller.publishMode.value = m,
                scheduledAt: controller.scheduledAt.value,
                onScheduledAtChanged: (dt) => controller.scheduledAt.value = dt,
              )),
        ],
      ),
    );
  }
}

// ── Variants section (Physical only) ──────────────────────────────────────────

class _VariantsSection extends StatelessWidget {
  final EditSellerProductController controller;
  const _VariantsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return FormFieldSection(
      label: 'Variants',
      required: true,
      hint: 'Add one card per option combination (e.g. color/size)',
      child: Obx(() {
        if (controller.isLoadingVariants.value) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        return Column(
          children: [
            ...List.generate(controller.variants.length, (i) => VariantCard(
                  key: ValueKey(controller.variants[i].remoteId ?? 'new_$i'),
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
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                  color: AppColors.primaryColor.withOpacity(0.04),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: AppColors.primaryColor),
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
        );
      }),
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
                  const Icon(Icons.visibility_outlined,
                      size: 20, color: AppColors.grey),
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
            fontFamily: AppTextStyles.monoFontFamily,
          ),
        ),
      ),
    );
  }
}

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


/// Card style + class range, loaded from the full product (skeleton while
/// loading, error + Retry if the product could not be read).
class _PublishFields extends StatelessWidget {
  final EditSellerProductController controller;
  const _PublishFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.isLoadingDetails.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final h in const [18.0, 48.0, 18.0, 48.0]) ...[
              Container(
                height: h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      }
      if (controller.detailsLoadFailed.value) {
        return Row(
          children: [
            Expanded(
              child: Text('Could not load card style and class range.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error)),
            ),
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
              onPressed: controller.loadDetails,
              child: const Text('Retry'),
            ),
          ],
        );
      }
      return PublishFieldsSection(
        coverStyle: controller.coverStyle.value,
        classFrom: controller.classFrom.value,
        classTo: controller.classTo.value,
        onCoverStyleChanged: controller.setCoverStyle,
        onClassFromChanged: controller.setClassFrom,
        onClassToChanged: controller.setClassTo,
        classRangeRequired: !controller.isPhysical,
        errorText: controller.publishFieldsError.value,
      );
    });
  }
}
