import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/listing_writer_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_form_widgets.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/generation_output_view.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/simple_picker_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListingWriterView extends GetView<ListingWriterController> {
  const ListingWriterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Listing Writer'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          const AiFieldLabel('Product Type'),
          CustomTextField(controller: controller.productTypeCtrl, hintText: 'e.g. Wireless Headphones'),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Keywords (comma separated)'),
          CustomTextField(
            controller: controller.keywordsCtrl,
            hintText: 'e.g. noise cancelling, bluetooth, travel',
            maxLines: 2,
          ),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Tone'),
          Obx(() => ChoiceChipGroup<String>(
                options: ListingWriterController.tones,
                selected: controller.tone.value,
                labelBuilder: (t) => t[0].toUpperCase() + t.substring(1),
                onSelected: (t) => controller.tone.value = t,
              )),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Attach to a product (optional)'),
          Obx(() => AiPickerTile(
                placeholder: 'Not attached to a product',
                value: controller.selectedProduct.value?['name'] as String?,
                onClear: controller.clearProduct,
                onTap: () async {
                  final picked = await SimplePickerSheet.show<Map<String, dynamic>>(
                    context,
                    title: 'Select a product',
                    items: controller.products,
                    itemLabel: (p) => (p['name'] ?? '').toString(),
                  );
                  if (picked != null) controller.pickProduct(picked);
                },
              )),
          SizedBox(height: BaseSpacing.lg),
          Obx(() => PrimaryButton(
                label: 'Generate with AI',
                isLoading: controller.isGenerating.value,
                onPressed: controller.generate,
              )),
          SizedBox(height: BaseSpacing.lg),
          Obx(() {
            final result = controller.result.value;
            if (result == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Result', color: AppColors.black2, fontWeight: FontWeight.w700, fontSize: AppFontSize.small2),
                SizedBox(height: BaseSpacing.sm),
                GenerationOutputView(toolType: 'listing_writer', output: result.output),
                SizedBox(height: BaseSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        label: 'Regenerate',
                        isLoading: controller.isGenerating.value,
                        onPressed: controller.regenerate,
                        compact: true,
                      ),
                    ),
                    SizedBox(width: BaseSpacing.sm),
                    Expanded(
                      child: controller.accepted.value
                          ? const AiAcceptedBadge()
                          : PrimaryButton(
                              label: 'Use This',
                              isLoading: controller.isAccepting.value,
                              onPressed: () => controller.accept(applyToProduct: controller.selectedProduct.value != null),
                              compact: true,
                            ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
