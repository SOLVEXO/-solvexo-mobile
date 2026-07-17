import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/ai_studio/ai_tool_meta.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_generation_detail_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/generation_output_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiGenerationDetailView extends GetView<AiGenerationDetailController> {
  const AiGenerationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Generation'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }
        final generation = controller.generation.value;
        if (generation == null) {
          return Center(
            child: CustomText(text: 'Generation not found', color: AppColors.gray600, fontSize: AppFontSize.small2),
          );
        }
        final meta = AiToolMeta.byToolType(generation.toolType);
        final canApplyToProduct = generation.toolType == 'listing_writer' || generation.toolType == 'seo_booster';

        return ListView(
          padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
          children: [
            Row(
              children: [
                CustomText(text: meta.emoji, fontSize: AppFontSize.veryLarge2),
                SizedBox(width: BaseSpacing.sm),
                Expanded(
                  child: CustomText(
                    text: meta.title,
                    color: AppColors.black2,
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: BaseSpacing.sm),
            if (generation.isFailed)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(BaseSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(BaseSpacing.xs + 2),
                ),
                child: CustomText(
                  text: generation.errorMessage ?? 'This generation failed. Credits were not charged.',
                  color: Colors.redAccent,
                  fontSize: AppFontSize.verySmall,
                ),
              )
            else if (generation.isProcessing)
              CustomText(text: 'Still processing…', color: AppColors.gray600, fontSize: AppFontSize.verySmall)
            else if (generation.output != null)
              GenerationOutputView(toolType: generation.toolType, output: generation.output!),
            SizedBox(height: BaseSpacing.lg),
            if (generation.isSucceeded && !generation.accepted) ...[
              PrimaryButton(
                label: 'Use This',
                isLoading: controller.isAccepting.value,
                onPressed: () => controller.accept(),
              ),
              if (canApplyToProduct && generation.productId != null) ...[
                SizedBox(height: BaseSpacing.xs),
                OutlineButton(
                  label: 'Use This & Apply to Product',
                  isLoading: controller.isAccepting.value,
                  onPressed: () => controller.accept(applyToProduct: true),
                ),
              ],
            ] else if (generation.accepted)
              Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.secondryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(BaseSpacing.xs + 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.secondryColor, size: 18),
                    SizedBox(width: BaseSpacing.xxs),
                    CustomText(
                      text: generation.appliedToProduct ? 'Accepted & applied to product' : 'Accepted',
                      color: AppColors.secondryColor,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}
