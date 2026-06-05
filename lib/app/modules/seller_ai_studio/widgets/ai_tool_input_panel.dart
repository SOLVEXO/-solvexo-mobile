import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/controllers/seller_ai_studio_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiToolInputPanel extends StatelessWidget {
  final SellerAiStudioController controller;

  const AiToolInputPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tool = controller.selectedTool.value;
      final data = controller.currentToolData;

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
            _PanelHeader(data: data),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 16),
            _toolForm(tool),
            const SizedBox(height: 20),
            _GenerateButton(controller: controller),
          ],
        ),
      );
    });
  }

  Widget _toolForm(AiTool tool) {
    switch (tool) {
      case AiTool.listingWriter:
        return _ListingWriterForm(controller: controller);
      case AiTool.priceOptimizer:
        return _PriceOptimizerForm(controller: controller);
      case AiTool.worksheetBuilder:
        return _WorksheetBuilderForm(controller: controller);
      case AiTool.seoBooster:
        return _SeoBoosterForm(controller: controller);
      case AiTool.emailCampaigns:
        return _EmailCampaignsForm(controller: controller);
      case AiTool.imageEnhancer:
        return _ImageEnhancerForm(controller: controller);
    }
  }
}

// ── Panel header ──────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  final AiToolData data;
  const _PanelHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          ),
          alignment: Alignment.center,
          child: SvgIcon(assetName: data.emoji, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: '${data.name} — Input',
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              CustomText(
                text: data.description,
                fontSize: AppFontSize.tiny,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: CustomText(
      text: label,
      fontSize: AppFontSize.verySmall,
      fontWeight: FontWeight.w600,
      color: AppColors.black2,
    ),
  );
}

class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelect;

  const _DropdownField({
    required this.value,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 16,
                      color: AppColors.lightGrey2,
                    ),
                    itemBuilder: (_, i) => ListTile(
                      title: Text(
                        options[i],
                        style: TextStyle(
                          fontSize: 14,
                          color: options[i] == value
                              ? AppColors.primaryColor
                              : AppColors.black,
                          fontWeight: options[i] == value
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: options[i] == value
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primaryColor,
                              size: 16,
                            )
                          : null,
                      onTap: () {
                        onSelect(options[i]);
                        Get.back();
                      },
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.textfldFillColor,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.lightGrey, width: 0.3),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomText(
                text: value,
                fontSize: AppFontSize.verySmall,
                color: AppColors.black,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isActive = o == selected;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(
                AppDimen.draggableBorderRadius,
              ),
              border: Border.all(
                color: isActive ? AppColors.primaryColor : AppColors.lightGrey2,
              ),
            ),
            child: CustomText(
              text: label(o),
              fontSize: AppFontSize.verySmall,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.primaryColor : AppColors.black2,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tool 1: Listing Writer ────────────────────────────────────────────────────

class _ListingWriterForm extends StatelessWidget {
  final SellerAiStudioController controller;
  const _ListingWriterForm({required this.controller});

  static const _productTypes = [
    'Educational Resource',
    'Physical Product',
    'Digital Download',
    'Service / Booking',
    'Subscription',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Product Type'),
        Obx(
          () => _DropdownField(
            value: controller.lwProductType.value,
            options: _productTypes,
            onSelect: (v) => controller.lwProductType.value = v,
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Product Keywords / Topic'),
        CustomTextField(
          controller: controller.lwKeywordsCtrl,
          onChanged: (v) => controller.lwKeywords.value = v,
          hintText:
              'e.g. Grade 5 math, fractions, common core, printable worksheets',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Tone'),
        Obx(
          () => _ChipSelector<WritingTone>(
            options: WritingTone.values,
            selected: controller.lwTone.value,
            label: (t) => t.name[0].toUpperCase() + t.name.substring(1),
            onSelect: (t) => controller.lwTone.value = t,
          ),
        ),
      ],
    );
  }
}

// ── Tool 2: Price Optimizer ───────────────────────────────────────────────────

class _PriceOptimizerForm extends StatelessWidget {
  final SellerAiStudioController controller;
  const _PriceOptimizerForm({required this.controller});

  static const _categories = [
    'Education & Learning',
    'Arts & Crafts',
    'Fashion & Apparel',
    'Electronics',
    'Health & Beauty',
    'Home & Garden',
    'Sports & Outdoors',
    'Books & Media',
    'Services',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Product Name'),
        CustomTextField(
          controller: controller.poProductNameCtrl,
          onChanged: (v) => controller.poProductName.value = v,
          hintText: 'e.g. Grade 5 Math Mastery Bundle',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Current Price'),
        CustomTextField(
          controller: controller.poCurrentPriceCtrl,
          onChanged: (v) => controller.poCurrentPrice.value = v,
          hintText: '0.00',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: CustomText(
              text: '\$',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Category'),
        Obx(
          () => _DropdownField(
            value: controller.poCategory.value,
            options: _categories,
            onSelect: (v) => controller.poCategory.value = v,
          ),
        ),
      ],
    );
  }
}

// ── Tool 3: Worksheet Builder ─────────────────────────────────────────────────

class _WorksheetBuilderForm extends StatelessWidget {
  final SellerAiStudioController controller;
  const _WorksheetBuilderForm({required this.controller});

  static const _subjects = [
    'Math',
    'English',
    'Science',
    'Social Studies',
    'Art',
    'History',
    'Geography',
  ];
  static const _grades = [
    'K–Grade 1',
    'Grade 2–3',
    'Grade 4–5',
    'Grade 6–8',
    'Grade 9–12',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: 'Subject'),
                  Obx(
                    () => _DropdownField(
                      value: controller.wbSubject.value,
                      options: _subjects,
                      onSelect: (v) => controller.wbSubject.value = v,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FieldLabel(label: 'Grade Level'),
                  Obx(
                    () => _DropdownField(
                      value: controller.wbGrade.value,
                      options: _grades,
                      onSelect: (v) => controller.wbGrade.value = v,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Topic / Focus'),
        CustomTextField(
          controller: controller.wbTopicCtrl,
          onChanged: (v) => controller.wbTopic.value = v,
          hintText: 'e.g. Adding fractions with unlike denominators',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Worksheet Type'),
        Obx(
          () => _ChipSelector<WorksheetType>(
            options: WorksheetType.values,
            selected: controller.wbType.value,
            label: (t) => t.name[0].toUpperCase() + t.name.substring(1),
            onSelect: (t) => controller.wbType.value = t,
          ),
        ),
      ],
    );
  }
}

// ── Tool 4: SEO Booster ───────────────────────────────────────────────────────

class _SeoBoosterForm extends StatelessWidget {
  final SellerAiStudioController controller;
  const _SeoBoosterForm({required this.controller});

  static const _categories = [
    'Education & Learning',
    'Arts & Crafts',
    'Fashion & Apparel',
    'Electronics',
    'Health & Beauty',
    'Home & Garden',
    'Books & Media',
    'Services',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Current Product Title'),
        CustomTextField(
          controller: controller.seoTitleCtrl,
          onChanged: (v) => controller.seoTitle.value = v,
          hintText: 'e.g. Grade 5 Math Bundle',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Category'),
        Obx(
          () => _DropdownField(
            value: controller.seoCategory.value,
            options: _categories,
            onSelect: (v) => controller.seoCategory.value = v,
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Target Keywords'),
        CustomTextField(
          controller: controller.seoKeywordsCtrl,
          onChanged: (v) => controller.seoKeywords.value = v,
          hintText: 'e.g. math worksheets, common core, printable',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          maxLines: 2,
        ),
      ],
    );
  }
}

// ── Tool 5: Email Campaigns ───────────────────────────────────────────────────

class _EmailCampaignsForm extends StatelessWidget {
  final SellerAiStudioController controller;
  const _EmailCampaignsForm({required this.controller});

  static const _campaignLabels = {
    CampaignType.promotional: 'Promotional',
    CampaignType.welcome: 'Welcome',
    CampaignType.reEngagement: 'Re-engagement',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Campaign Type'),
        Obx(
          () => _ChipSelector<CampaignType>(
            options: CampaignType.values,
            selected: controller.ecType.value,
            label: (t) => _campaignLabels[t]!,
            onSelect: (t) => controller.ecType.value = t,
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Target Audience'),
        CustomTextField(
          controller: controller.ecAudienceCtrl,
          onChanged: (v) => controller.ecAudience.value = v,
          hintText: 'e.g. Teachers, homeschool parents, 5th grade educators',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Key Message'),
        CustomTextField(
          controller: controller.ecMessageCtrl,
          onChanged: (v) => controller.ecMessage.value = v,
          hintText: 'e.g. 20% discount this week, launch new math bundle',
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          maxLines: 3,
        ),
      ],
    );
  }
}

// ── Tool 6: Image Enhancer ────────────────────────────────────────────────────

class _ImageEnhancerForm extends StatelessWidget {
  final SellerAiStudioController controller;
  const _ImageEnhancerForm({required this.controller});

  static const _enhancementLabels = {
    ImageEnhancement.autoEnhance: 'Auto-enhance',
    ImageEnhancement.bgRemove: 'Remove BG',
    ImageEnhancement.brightness: 'Brightness',
    ImageEnhancement.sharpen: 'Sharpen',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Product Image'),
        Obx(
          () => GestureDetector(
            onTap: controller.pickImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 120,
              decoration: BoxDecoration(
                color: controller.ieHasImage.value
                    ? AppColors.greenContainerInnerColor
                    : AppColors.background,
                borderRadius: BorderRadius.circular(
                  AppDimen.serviceCountTileRadius,
                ),
                border: Border.all(
                  color: controller.ieHasImage.value
                      ? AppColors.darkGreen
                      : AppColors.lightGrey2,
                  width: controller.ieHasImage.value ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.ieHasImage.value
                        ? Icons.check_circle_rounded
                        : Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: controller.ieHasImage.value
                        ? AppColors.darkGreen
                        : AppColors.lightGrey,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    text: controller.ieHasImage.value
                        ? 'Image ready — tap to change'
                        : 'Tap to upload product image',
                    fontSize: AppFontSize.verySmall,
                    color: controller.ieHasImage.value
                        ? AppColors.darkGreen
                        : AppColors.grey,
                  ),
                  if (!controller.ieHasImage.value)
                    const CustomText(
                      text: 'PNG or JPG, min 500×500px',
                      fontSize: AppFontSize.tiny,
                      color: AppColors.lightGrey5,
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _FieldLabel(label: 'Enhancement Type'),
        Obx(
          () => _ChipSelector<ImageEnhancement>(
            options: ImageEnhancement.values,
            selected: controller.ieType.value,
            label: (t) => _enhancementLabels[t]!,
            onSelect: (t) => controller.ieType.value = t,
          ),
        ),
      ],
    );
  }
}

// ── Generate button ───────────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  final SellerAiStudioController controller;
  const _GenerateButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canGen = controller.canGenerate;
      final isGen = controller.isGenerating.value;
      final cost = controller.currentToolData.creditCost;
      return AppButton(
        label: "Generate with AI ($cost credits)",
        iconWidget: SvgIcon(
          assetName: AppIcons.aiStudioIcon,
          size: 22,
          color: AppColors.yellow,
        ),
        onPressed: canGen && !isGen ? controller.generate : null,
      );
    });
  }
}
