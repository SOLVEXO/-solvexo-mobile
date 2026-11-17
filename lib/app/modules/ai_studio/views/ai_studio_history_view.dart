import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/ai_studio/ai_generation_model.dart';
import 'package:book_store_app/app/modules/ai_studio/ai_tool_meta.dart';
import 'package:book_store_app/app/modules/ai_studio/controllers/ai_studio_history_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AiStudioHistoryView extends GetView<AiStudioHistoryController> {
  const AiStudioHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Generation History'),
      body: Column(
        children: [
          SizedBox(height: BaseSpacing.sm),
          _FilterChips(),
          SizedBox(height: BaseSpacing.xs),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
              }
              if (controller.items.isEmpty) {
                return Center(
                  child: CustomText(
                    text: 'No generations yet',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.small2,
                  ),
                );
              }
              return ListView.separated(
                controller: controller.scrollController,
                padding: EdgeInsets.fromLTRB(BaseSpacing.md, 0, BaseSpacing.md, BaseSpacing.xxl),
                itemCount: controller.items.length + (controller.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.xs),
                itemBuilder: (_, index) {
                  if (index >= controller.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                    );
                  }
                  final generation = controller.items[index];
                  return _GenerationTile(
                    generation: generation,
                    onTap: () => controller.openDetail(generation),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends GetView<AiStudioHistoryController> {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final selected = controller.filterToolType.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
          itemCount: controller.filterOptions.length,
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.xs),
          itemBuilder: (_, index) {
            final meta = controller.filterOptions[index];
            final isSelected = selected == meta?.toolType;
            return GestureDetector(
              onTap: () => controller.setFilter(meta?.toolType),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xxs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.white,
                  borderRadius: BorderRadius.circular(BaseSpacing.lg),
                  border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2),
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: meta == null ? 'All' : '${meta.emoji} ${meta.title}',
                  color: isSelected ? AppColors.white : AppColors.black2,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _GenerationTile extends StatelessWidget {
  final AiGenerationModel generation;
  final VoidCallback onTap;

  const _GenerationTile({required this.generation, required this.onTap});

  Color _statusColor() {
    switch (generation.status) {
      case 'succeeded':
        return AppColors.secondryColor;
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = AiToolMeta.byToolType(generation.toolType);
    final date = generation.createdAt;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(BaseSpacing.xs + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BaseSpacing.xs + 2),
        child: Padding(
          padding: EdgeInsets.all(BaseSpacing.sm),
          child: Row(
            children: [
              CustomText(text: meta.emoji, fontSize: AppFontSize.veryLarge),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: meta.title,
                      color: AppColors.black2,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 2),
                    CustomText(
                      text: date != null ? DateFormat('MMM d, y • h:mm a').format(date) : '',
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor().withOpacity(0.12),
                      borderRadius: BorderRadius.circular(BaseSpacing.xxs),
                    ),
                    child: CustomText(
                      text: generation.status,
                      color: _statusColor(),
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (generation.creditsCharged > 0) ...[
                    SizedBox(height: 4),
                    CustomText(
                      text: '-${generation.creditsCharged} cr',
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
