import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/price_optimizer_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_form_widgets.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/generation_output_view.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/simple_picker_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceOptimizerView extends GetView<PriceOptimizerController> {
  const PriceOptimizerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Price Optimizer'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          Obx(() => ChoiceChipGroup<bool>(
                options: const [true, false],
                selected: controller.fromProduct.value,
                labelBuilder: (v) => v ? 'Existing product' : 'By category',
                onSelected: controller.setMode,
              )),
          SizedBox(height: BaseSpacing.md),
          Obx(() {
            if (controller.fromProduct.value) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AiFieldLabel('Product'),
                  AiPickerTile(
                    placeholder: 'Select a product',
                    value: controller.selectedProduct.value?['name'] as String?,
                    onTap: () async {
                      final picked = await SimplePickerSheet.show<Map<String, dynamic>>(
                        context,
                        title: 'Select a product',
                        items: controller.products,
                        itemLabel: (p) => (p['name'] ?? '').toString(),
                      );
                      if (picked != null) controller.pickProduct(picked);
                    },
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AiFieldLabel('Category'),
                AiPickerTile(
                  placeholder: 'Select a category',
                  value: controller.selectedCategory.value?.name,
                  onTap: () async {
                    final picked = await SimplePickerSheet.show(
                      context,
                      title: 'Select a category',
                      items: controller.categories,
                      itemLabel: (c) => c.name,
                    );
                    if (picked != null) controller.pickCategory(picked);
                  },
                ),
                SizedBox(height: BaseSpacing.md),
                const AiFieldLabel('Attributes (optional)'),
                CustomTextField(controller: controller.attributesCtrl, hintText: 'e.g. leather, medium size, waterproof'),
              ],
            );
          }),
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
                GenerationOutputView(toolType: 'price_optimizer', output: result.output),
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
                              onPressed: controller.accept,
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
