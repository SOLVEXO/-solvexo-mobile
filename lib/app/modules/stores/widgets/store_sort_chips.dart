import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/stores/controllers/stores_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Sort pills for the Stores browse screen — same selected/unselected pill
/// look as Home's `TabHeader`.
class StoreSortChips extends StatelessWidget {
  StoreSortChips({super.key});

  final StoresController controller = Get.find();

  static const _options = [
    ('followers', 'Followers'),
    ('rating', 'Top Rated'),
    ('newest', 'Newest'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
        itemCount: _options.length,
        separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.sm),
        itemBuilder: (_, i) {
          final (value, label) = _options[i];
          return Obx(() {
            final selected = controller.sort.value == value;
            return GestureDetector(
              onTap: () => controller.changeSort(value),
              child: AnimatedContainer(
                duration: BaseMotion.normal,
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                  color: selected ? AppColors.primaryColor : AppColors.white,
                  border: Border.all(
                    width: 0.3,
                    color: selected ? AppColors.primaryColor : AppColors.textPrimary,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs, horizontal: BaseSpacing.sm),
                alignment: Alignment.center,
                child: CustomText(
                  text: label,
                  color: selected ? AppColors.white : AppColors.textPrimary,
                  fontSize: AppFontSize.tiny,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
