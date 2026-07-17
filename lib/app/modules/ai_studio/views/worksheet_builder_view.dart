import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/worksheet_builder_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_form_widgets.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/generation_output_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorksheetBuilderView extends GetView<WorksheetBuilderController> {
  const WorksheetBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Worksheet Builder'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          const AiFieldLabel('Subject'),
          CustomTextField(controller: controller.subjectCtrl, hintText: 'e.g. Fractions'),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Grade Level'),
          CustomTextField(controller: controller.gradeLevelCtrl, hintText: 'e.g. Grade 4'),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Topics (comma separated)'),
          CustomTextField(controller: controller.topicsCtrl, hintText: 'e.g. adding fractions, simplifying', maxLines: 2),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Number of questions'),
          Obx(() => Row(
                children: [
                  _StepperButton(icon: Icons.remove, onTap: controller.decrementQuestions),
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: CustomText(
                        text: '${controller.questionCount.value}',
                        color: AppColors.black2,
                        fontSize: AppFontSize.medium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StepperButton(icon: Icons.add, onTap: controller.incrementQuestions),
                ],
              )),
          SizedBox(height: BaseSpacing.md),
          Obx(() => Row(
                children: [
                  Switch(
                    value: controller.includeAnswerKey.value,
                    onChanged: (v) => controller.includeAnswerKey.value = v,
                    activeColor: AppColors.primaryColor,
                  ),
                  CustomText(text: 'Include answer key', color: AppColors.black2, fontSize: AppFontSize.verySmall),
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
                GenerationOutputView(toolType: 'worksheet_builder', output: result.output),
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

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: AppColors.white2, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: AppColors.black2),
      ),
    );
  }
}
