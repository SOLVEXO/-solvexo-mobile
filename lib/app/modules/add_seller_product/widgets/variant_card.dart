import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/common_models/variant_entry.dart';
import 'package:book_store_app/app/modules/add_seller_product/widgets/shared_form_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One variant's editable fields — reused by both the Add Product and Edit
/// Product screens so variant authoring stays identical in both places.
class VariantCard extends StatelessWidget {
  final int index;
  final VariantEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onSetDefault;
  final VoidCallback onAddImage;
  final void Function(int imageIndex) onRemoveImage;

  const VariantCard({
    super.key,
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onRemove,
    required this.onSetDefault,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: title, default chip, delete ─────────────────────
          Row(
            children: [
              CustomText(
                text: 'Variant ${index + 1}',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w700,
                color: AppColors.black2,
              ),
              const SizedBox(width: 10),
              Obx(() => GestureDetector(
                    onTap: entry.isDefault.value ? null : onSetDefault,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: entry.isDefault.value
                            ? AppColors.primaryColor
                            : AppColors.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                      ),
                      child: CustomText(
                        text: entry.isDefault.value ? 'Default' : 'Set as default',
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                        color: entry.isDefault.value ? AppColors.white : AppColors.primaryColor,
                      ),
                    ),
                  )),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 22),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Price + Compare At Price ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: FormFieldSection(
                  label: 'Price',
                  required: true,
                  child: CustomTextField(
                    controller: entry.priceCtrl,
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormFieldSection(
                  label: 'Compare At',
                  child: CustomTextField(
                    controller: entry.compareAtPriceCtrl,
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
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Stock + Unlimited ─────────────────────────────────────────
          Obx(() => FormFieldSection(
                label: 'Stock',
                child: entry.unlimitedStock.value
                    ? const UnlimitedStockPlaceholder()
                    : CustomTextField(
                        controller: entry.stockCtrl,
                        hintText: '0',
                        isborder: true,
                        fillColor: AppColors.textfldFillColor,
                        keyboardType: TextInputType.number,
                      ),
              )),
          const SizedBox(height: 8),
          UnlimitedStockToggle(value: entry.unlimitedStock),
          const SizedBox(height: 12),

          // ── Shipping Weight ───────────────────────────────────────────
          FormFieldSection(
            label: 'Shipping Weight',
            hint: 'e.g. 0.3kg',
            child: CustomTextField(
              controller: entry.shippingWeightCtrl,
              hintText: 'e.g. 0.3kg',
              isborder: true,
              fillColor: AppColors.textfldFillColor,
            ),
          ),
          const SizedBox(height: 12),

          // ── Variant images ────────────────────────────────────────────
          ImagesSection(
            label: 'Variant Images',
            hint: 'Up to 5 — falls back to the product photos if left empty',
            images: entry.images,
            isUploading: entry.isUploadingImage,
            onAdd: onAddImage,
            onRemove: onRemoveImage,
          ),
          const SizedBox(height: 12),

          // ── Attribute rows (e.g. Color: Red) ─────────────────────────
          FormFieldSection(
            label: 'Attributes',
            hint: 'e.g. Color / Red — leave empty for a single, option-less variant',
            child: Obx(() => Column(
                  children: [
                    ...List.generate(entry.options.length, (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: entry.options[i].nameCtrl,
                                  hintText: 'Name (e.g. Color)',
                                  isborder: true,
                                  fillColor: AppColors.textfldFillColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomTextField(
                                  controller: entry.options[i].valueCtrl,
                                  hintText: 'Value (e.g. Red)',
                                  isborder: true,
                                  fillColor: AppColors.textfldFillColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => entry.removeOption(i),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.close_rounded, size: 18, color: AppColors.red),
                                ),
                              ),
                            ],
                          ),
                        )),
                    GestureDetector(
                      onTap: entry.addOption,
                      child: Row(
                        children: const [
                          Icon(Icons.add_rounded, size: 16, color: AppColors.primaryColor),
                          SizedBox(width: 4),
                          CustomText(
                            text: 'Add attribute',
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
