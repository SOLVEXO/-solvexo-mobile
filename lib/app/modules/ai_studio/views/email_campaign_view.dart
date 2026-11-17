import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/email_campaign_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_form_widgets.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/generation_output_view.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/simple_picker_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailCampaignView extends GetView<EmailCampaignController> {
  const EmailCampaignView({super.key});

  String _goalLabel(String g) => g.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Email Campaigns'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          const AiFieldLabel('Campaign Goal'),
          Obx(() => ChoiceChipGroup<String>(
                options: EmailCampaignController.goals,
                selected: controller.campaignGoal.value,
                labelBuilder: _goalLabel,
                onSelected: (g) => controller.campaignGoal.value = g,
              )),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Tone'),
          Obx(() => ChoiceChipGroup<String>(
                options: EmailCampaignController.tones,
                selected: controller.tone.value,
                labelBuilder: (t) => t[0].toUpperCase() + t.substring(1),
                onSelected: (t) => controller.tone.value = t,
              )),
          SizedBox(height: BaseSpacing.md),
          AiFieldLabel('Featured products (optional, up to ${EmailCampaignController.maxProducts})'),
          Obx(() => Wrap(
                spacing: BaseSpacing.xs,
                runSpacing: BaseSpacing.xs,
                children: [
                  ...controller.selectedProducts.map(
                    (p) => Chip(
                      label: CustomText(text: (p['name'] ?? '').toString(), fontSize: AppFontSize.tiny),
                      onDeleted: () => controller.removeProduct(p),
                      backgroundColor: AppColors.white2,
                    ),
                  ),
                  ActionChip(
                    label: CustomText(text: '+ Add product', color: AppColors.primaryColor, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                    backgroundColor: AppColors.white,
                    side: BorderSide(color: AppColors.primaryColor.withOpacity(0.4)),
                    onPressed: () async {
                      final picked = await SimplePickerSheet.show<Map<String, dynamic>>(
                        context,
                        title: 'Add a product',
                        items: controller.pickableProducts,
                        itemLabel: (p) => (p['name'] ?? '').toString(),
                      );
                      if (picked != null) controller.addProduct(picked);
                    },
                  ),
                ],
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
                GenerationOutputView(toolType: 'email_campaigns', output: result.output),
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
