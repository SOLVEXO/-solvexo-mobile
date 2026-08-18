import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_center_controller.dart';

String faqCategoryLabel(String value) {
  if (value.isEmpty) return value;
  if (value == 'all') return 'All Topics';
  return value
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Horizontal pill row for filtering FAQs by category — backed by
/// [FaqController.categories]/[FaqController.selectedCategory], which
/// already existed on the controller but had no UI wired to them.
class FaqCategoryChips extends StatelessWidget {
  const FaqCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();
    return Obx(() {
      if (controller.categories.length <= 1) return const SizedBox.shrink();
      return SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.xs),
          itemBuilder: (_, i) {
            final category = controller.categories[i];
            final isSelected = controller.selectedCategory.value == category;
            return PressableScale(
              onTap: () => controller.filterByCategory(category),
              child: AnimatedContainer(
                duration: BaseMotion.fast,
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.xs),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.white,
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2,
                  ),
                ),
                alignment: Alignment.center,
                child: CustomText(
                  text: faqCategoryLabel(category),
                  color: isSelected ? AppColors.white : AppColors.black2,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
