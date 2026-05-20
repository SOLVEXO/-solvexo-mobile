import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryBreadcrumb extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stack = controller.navigationStack;

      // Hide when at root
      if (stack.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // ── Home chip ──────────────────────────────────────────────
              _BreadcrumbChip(
                label: 'Home',
                isHome: true,
                isActive: false,
                onTap: controller.clearSelection,
              ),

              // ── Stack items ────────────────────────────────────────────
              ...stack.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final isLast = index == stack.length - 1;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    _BreadcrumbSeparator(),
                    const SizedBox(width: 4),
                    _BreadcrumbChip(
                      label: category.name,
                      isHome: false,
                      isActive: isLast,
                      onTap: () {
                        // ── KEY LOGIC ──────────────────────────────────
                        // Tapping a previous crumb pops everything AFTER it
                        // so the stack is trimmed to that item inclusive.
                        if (!isLast) {
                          // Remove all items after this index
                          final trimmed = stack.sublist(0, index + 1);
                          controller.navigationStack.assignAll(trimmed);
                          controller.selectedCategory.value = category;
                          controller.fetchCategoryDetails(category.id);
                        }
                        // Tapping the active (last) crumb does nothing
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Breadcrumb Chip ───────────────────────────────────────────────────────

class _BreadcrumbChip extends StatelessWidget {
  final String label;
  final bool isHome;
  final bool isActive;
  final VoidCallback onTap;

  const _BreadcrumbChip({
    required this.label,
    required this.isHome,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(maxWidth: 130),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryColor
              : isHome
              ? AppColors.primaryColor.withOpacity(0.08)
              : AppColors.lightGrey.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isHome)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.home_rounded,
                  size: AppFontSize.small2,
                  color: isActive ? AppColors.white : AppColors.primaryColor,
                ),
              ),
            Flexible(
              child: CustomText(
                text: label,
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                color: isActive
                    ? AppColors.white
                    : isHome
                    ? AppColors.primaryColor
                    : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Breadcrumb Separator ──────────────────────────────────────────────────

class _BreadcrumbSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      assetName: AppIcons.chevronRight,
      size: 13,
      color: AppColors.gray600,
    );
  }
}
