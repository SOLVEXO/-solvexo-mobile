import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/digital_file_upload_tile.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          _FormSection(
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

          // ── Product Images ──────────────────────────────────────────
          _ProductImagesSection(controller: controller),
          const SizedBox(height: 16),

          // ── Price ───────────────────────────────────────────────────
          _FormSection(
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

          // ── Physical-product-only fields ────────────────────────────
          Obx(() {
            if (!controller.isPhysical) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compare At Price
                _FormSection(
                  label: 'Compare At Price',
                  hint: 'Original / crossed-out price',
                  child: CustomTextField(
                    controller: controller.compareAtPriceCtrl,
                    onChanged: (v) => controller.compareAtPrice.value = v,
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

                // Stock Count
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
                const SizedBox(height: 8),
                _UnlimitedToggle(controller: controller),
                const SizedBox(height: 16),

                // Size & Color in a row
                Row(
                  children: [
                    Expanded(
                      child: _FormSection(
                        label: 'Size',
                        hint: 'e.g. L, XL',
                        child: CustomTextField(
                          controller: controller.sizeCtrl,
                          onChanged: (v) => controller.size.value = v,
                          hintText: 'e.g. L',
                          isborder: true,
                          fillColor: AppColors.textfldFillColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormSection(
                        label: 'Color',
                        hint: 'e.g. Red',
                        child: CustomTextField(
                          controller: controller.colorCtrl,
                          onChanged: (v) => controller.color.value = v,
                          hintText: 'e.g. Red',
                          isborder: true,
                          fillColor: AppColors.textfldFillColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Shipping Weight
                _FormSection(
                  label: 'Shipping Weight',
                  hint: 'e.g. 0.3kg',
                  child: CustomTextField(
                    controller: controller.shippingWeightCtrl,
                    onChanged: (v) => controller.shippingWeight.value = v,
                    hintText: 'e.g. 0.3kg',
                    isborder: true,
                    fillColor: AppColors.textfldFillColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Tags
                _FormSection(
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

                // List on Solvexo Marketplace toggle
                _ListedToggle(controller: controller),
                const SizedBox(height: 16),
              ],
            );
          }),

          // ── Digital-product-only fields ─────────────────────────────
          Obx(() {
            if (!controller.isDigital) return const SizedBox.shrink();
            return _DigitalFields(controller: controller);
          }),

          // ── Save as Draft ───────────────────────────────────────────
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
  final String? hint;
  final Widget child;
  final bool required;

  const _FormSection({
    required this.label,
    required this.child,
    this.hint,
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
        if (hint != null) ...[
          const SizedBox(height: 2),
          CustomText(
            text: hint!,
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
          ),
        ],
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ── Product images section ────────────────────────────────────────────────────

class _ProductImagesSection extends StatelessWidget {
  final AddSellerProductController controller;
  const _ProductImagesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _FormSection(
      label: 'Product Images',
      hint: 'Up to 5 images',
      child: Obx(() {
        final images = controller.productImages;
        final isUploading = controller.isUploadingImage.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(images.length, (i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _ImageThumbnail(
                      url: images[i],
                      onRemove: () => controller.removeImage(i),
                    ),
                  )),
              if (isUploading)
                const _LoadingThumbnail()
              else if (images.length < 5)
                _AddImageButton(onTap: controller.pickAndUploadImage),
            ],
          ),
        );
      }),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  const _ImageThumbnail({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 80,
              height: 80,
              color: AppColors.textfldFillColor,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: AppColors.textfldFillColor,
              child: const Icon(Icons.broken_image_rounded,
                  color: AppColors.grey, size: 28),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 12, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingThumbnail extends StatelessWidget {
  const _LoadingThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.textfldFillColor,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.4),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                size: 26, color: AppColors.primaryColor),
            SizedBox(height: 4),
            CustomText(
              text: 'Add',
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
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

// ── Unlimited stock placeholder ───────────────────────────────────────────────

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
          Icon(
            Icons.all_inclusive_rounded,
            size: 18,
            color: AppColors.darkGreen,
          ),
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

// ── Unlimited stock toggle ────────────────────────────────────────────────────

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
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.white,
                    )
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

// ── List on Solvexo toggle ────────────────────────────────────────────────────

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
        // Compare At Price
        _FormSection(
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
        _FormSection(
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
        _FormSection(
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
        _FormSection(
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
              child: _FormSection(
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

        // List on Solvexo toggle (shared)
        _ListedToggle(controller: controller),
        const SizedBox(height: 16),

        // Tags
        _FormSection(
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
        _FormSection(
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
          ),
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
            const Icon(
              Icons.edit_note_rounded,
              size: 20,
              color: AppColors.grey,
            ),
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
