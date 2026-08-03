import 'dart:io';

import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_price_breakdown_model.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_request_model.dart';
import 'package:book_store_app/app/modules/seller_promotions/controllers/promotion_create_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const Map<String, String> _kLinkTypeLabels = {
  'product': 'Product',
  'category': 'Category',
  'external': 'External URL',
  'collection': 'Collection',
};

/// Dedicated pushed screen (not a bottom sheet, given the field count) for
/// submitting a new promotion request. Pushed via a plain `Get.to`, no named
/// route — the caller ([SellerPromotionsView]) awaits the popped `bool` and
/// refreshes its list on success.
class PromotionCreateView extends StatelessWidget {
  // Per-screen controller — intentionally re-put like ProductDetail/Checkout.
  final PromotionCreateController c = Get.put(PromotionCreateController());

  PromotionCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'New Promotion'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          _SectionLabel('Placement'),
          SizedBox(height: BaseSpacing.xs),
          Obx(
            () => _ChipSelector(
              value: c.placement.value,
              options: kPromotionPlacementLabels,
              onChanged: c.setPlacement,
            ),
          ),
          SizedBox(height: BaseSpacing.lg),
          _SectionLabel('Schedule'),
          SizedBox(height: BaseSpacing.xs),
          Obx(
            () => _DateTimeField(
              label: 'Starts',
              value: c.startAt.value,
              onPicked: c.setStartAt,
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          Obx(
            () => _DateTimeField(
              label: 'Ends',
              value: c.endAt.value,
              onPicked: c.setEndAt,
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          Obx(
            () => _SwitchRow(
              label: 'Peak/holiday pricing',
              value: c.isPeak.value,
              onChanged: c.togglePeak,
            ),
          ),
          SizedBox(height: BaseSpacing.md),
          Obx(() => _PricePreview(isLoading: c.isPreviewing.value, breakdown: c.priceBreakdown.value)),
          SizedBox(height: BaseSpacing.lg),
          _SectionLabel('Creative'),
          SizedBox(height: BaseSpacing.xs),
          Obx(
            () => _ImageSlot(
              label: 'Main creative (required)',
              file: c.mainFile.value,
              onTap: () => AppImagePicker.show(
                title: 'Promotion Creative',
                onPicked: c.setMainFile,
                canRemove: c.mainFile.value != null,
                onRemove: c.clearMainFile,
              ),
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          Obx(
            () => _ImageSlot(
              label: 'Mobile-optimized creative (optional)',
              file: c.mobileFile.value,
              onTap: () => AppImagePicker.show(
                title: 'Mobile Creative',
                onPicked: c.setMobileFile,
                canRemove: c.mobileFile.value != null,
                onRemove: c.clearMobileFile,
              ),
            ),
          ),
          SizedBox(height: BaseSpacing.lg),
          _SectionLabel('Call to Action'),
          SizedBox(height: BaseSpacing.xs),
          CustomTextField(controller: c.ctaLabelCtrl, hintText: 'e.g. Shop Now', isborder: true),
          SizedBox(height: BaseSpacing.sm),
          Obx(
            () => _ChipSelector(
              value: c.linkType.value,
              options: _kLinkTypeLabels,
              onChanged: c.setLinkType,
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          CustomTextField(
            controller: c.linkTargetCtrl,
            hintText: 'Link target (product/category id or URL)',
            isborder: true,
          ),
          SizedBox(height: BaseSpacing.lg),
          _SectionLabel('Note to Reviewer (optional)'),
          SizedBox(height: BaseSpacing.xs),
          CustomTextField(
            controller: c.messageCtrl,
            hintText: 'Anything the admin reviewing this should know',
            isborder: true,
            maxLines: 3,
            maxLength: 500,
          ),
          SizedBox(height: BaseSpacing.xl),
          Obx(
            () => PrimaryButton(
              label: 'Submit for Review',
              isLoading: c.isSubmitting.value,
              onPressed: c.isSubmitting.value
                  ? null
                  : () async {
                      final ok = await c.submit();
                      if (ok) Get.back(result: true);
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return CustomText(text: text, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w700, color: AppColors.black2);
  }
}

class _ChipSelector extends StatelessWidget {
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;
  const _ChipSelector({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: BaseSpacing.xs,
      runSpacing: BaseSpacing.xs,
      children: options.entries.map((entry) {
        final active = entry.key == value;
        return GestureDetector(
          onTap: () => onChanged(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryColor : AppColors.white,
              borderRadius: BorderRadius.circular(BaseRadius.pill),
              border: Border.all(color: active ? AppColors.primaryColor : AppColors.lightGrey11),
            ),
            child: CustomText(
              text: entry.value,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.white : AppColors.gray600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  const _DateTimeField({required this.label, required this.value, required this.onPicked});

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: value != null ? TimeOfDay.fromDateTime(value!) : TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.md),
          border: Border.all(color: AppColors.lightGrey11),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.gray600),
            SizedBox(width: BaseSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: label, fontSize: AppFontSize.tiny, color: AppColors.gray600),
                  CustomText(
                    text: value != null ? DateFormat('MMM d, yyyy · h:mm a').format(value!) : 'Select date & time',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.md),
        border: Border.all(color: AppColors.lightGrey11),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomText(text: label, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600, color: AppColors.black2),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primaryColor),
        ],
      ),
    );
  }
}

class _PricePreview extends StatelessWidget {
  final bool isLoading;
  final PromotionPriceBreakdownModel? breakdown;
  const _PricePreview({required this.isLoading, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final bd = breakdown;
    if (bd == null) {
      if (!isLoading) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(BaseSpacing.sm),
        decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.md)),
        child: const Center(
          child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryColor, AppColors.primaryColorLight]),
        borderRadius: BorderRadius.circular(BaseRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: 'Estimated Price',
                  color: AppColors.white.withOpacity(0.85),
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
                if (bd.festivalName != null && bd.festivalName!.isNotEmpty)
                  CustomText(
                    text: bd.festivalName!,
                    color: AppColors.white.withOpacity(0.85),
                    fontSize: AppFontSize.tiny,
                  )
                else if (bd.peakMultiplierApplied > 1)
                  CustomText(
                    text: 'Peak pricing applied',
                    color: AppColors.white.withOpacity(0.85),
                    fontSize: AppFontSize.tiny,
                  ),
              ],
            ),
          ),
          CustomText(
            text: '\$${bd.priceUSD.toStringAsFixed(2)}',
            color: AppColors.white,
            fontSize: AppFontSize.large,
            fontWeight: FontWeight.bold,
            fontFamily: AppTextStyles.monoFontFamily,
          ),
        ],
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;
  const _ImageSlot({required this.label, required this.file, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(BaseSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.md),
          border: Border.all(color: AppColors.lightGrey11),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(BaseRadius.sm),
              child: file != null
                  ? CommonImageView(file: file, height: 56, width: 56, fit: BoxFit.cover)
                  : Container(
                      height: 56,
                      width: 56,
                      color: AppColors.lightGrey10,
                      child: const Icon(Icons.image_outlined, color: AppColors.gray600),
                    ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: CustomText(text: label, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600, color: AppColors.black2),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gray600),
          ],
        ),
      ),
    );
  }
}
