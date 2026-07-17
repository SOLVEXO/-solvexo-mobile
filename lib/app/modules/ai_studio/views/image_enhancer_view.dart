import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/image_enhancer_controller.dart';
import 'package:book_store_app/app/modules/ai_studio/widgets/ai_form_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageEnhancerView extends GetView<ImageEnhancerController> {
  const ImageEnhancerView({super.key});

  String _typeLabel(String t) => t.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  void _showSourceSheet() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
                title: CustomText(text: 'Choose from gallery', fontSize: AppFontSize.verySmall),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primaryColor),
                title: CustomText(text: 'Take a photo', fontSize: AppFontSize.verySmall),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Image Enhancer'),
      body: ListView(
        padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
        children: [
          const AiFieldLabel('Product Photo'),
          GestureDetector(
            onTap: _showSourceSheet,
            child: Obx(() {
              final local = controller.localImage.value;
              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white2,
                  borderRadius: BorderRadius.circular(BaseSpacing.sm),
                  border: Border.all(color: AppColors.lightGrey2),
                ),
                clipBehavior: Clip.antiAlias,
                child: local == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.grey),
                          SizedBox(height: BaseSpacing.xs),
                          CustomText(text: 'Tap to select a photo', color: AppColors.grey, fontSize: AppFontSize.tiny),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          CommonImageView(file: local, fit: BoxFit.cover),
                          if (controller.isUploading.value)
                            Container(
                              color: Colors.black45,
                              child: const Center(child: CircularProgressIndicator(color: AppColors.white)),
                            ),
                        ],
                      ),
              );
            }),
          ),
          SizedBox(height: BaseSpacing.md),
          const AiFieldLabel('Enhancement Type'),
          Obx(() => ChoiceChipGroup<String>(
                options: ImageEnhancerController.enhancementTypes,
                selected: controller.enhancementType.value,
                labelBuilder: _typeLabel,
                onSelected: (t) => controller.enhancementType.value = t,
              )),
          SizedBox(height: BaseSpacing.lg),
          Obx(() => PrimaryButton(
                label: 'Generate with AI',
                isLoading: controller.isGenerating.value,
                onPressed: controller.uploadedImageUrl.value.isEmpty ? null : controller.generate,
              )),
          SizedBox(height: BaseSpacing.lg),
          Obx(() {
            final job = controller.job.value;
            if (job == null) return const SizedBox.shrink();

            if (job.isProcessing) {
              return Row(
                children: [
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
                  SizedBox(width: BaseSpacing.sm),
                  CustomText(text: 'Enhancing your photo…', color: AppColors.gray600, fontSize: AppFontSize.verySmall),
                ],
              );
            }

            if (job.isFailed) {
              return Container(
                padding: EdgeInsets.all(BaseSpacing.sm),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(BaseSpacing.xs + 2)),
                child: CustomText(
                  text: job.errorMessage ?? 'Enhancement failed. Credits were not charged.',
                  color: Colors.redAccent,
                  fontSize: AppFontSize.verySmall,
                ),
              );
            }

            // succeeded
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: 'Before / After', color: AppColors.black2, fontWeight: FontWeight.w700, fontSize: AppFontSize.small2),
                SizedBox(height: BaseSpacing.sm),
                Row(
                  children: [
                    Expanded(child: _LabeledImage(label: 'Original', url: job.originalImageUrl)),
                    SizedBox(width: BaseSpacing.sm),
                    Expanded(child: _LabeledImage(label: 'Enhanced', url: job.enhancedImageUrl)),
                  ],
                ),
                if (job.note != null) ...[
                  SizedBox(height: BaseSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
                    decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(BaseSpacing.xs + 2)),
                    child: CustomText(text: job.note!, color: const Color(0xFF8A6D3B), fontSize: AppFontSize.tiny),
                  ),
                ],
                SizedBox(height: BaseSpacing.sm),
                controller.accepted.value
                    ? const AiAcceptedBadge()
                    : PrimaryButton(
                        label: 'Use This',
                        isLoading: controller.isAccepting.value,
                        onPressed: controller.accept,
                        compact: true,
                      ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LabeledImage extends StatelessWidget {
  final String label;
  final String? url;
  const _LabeledImage({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
        SizedBox(height: BaseSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(BaseSpacing.xs + 2),
          child: AspectRatio(
            aspectRatio: 1,
            child: url != null ? CommonImageView(url: url, fit: BoxFit.cover) : Container(color: AppColors.white2),
          ),
        ),
      ],
    );
  }
}
