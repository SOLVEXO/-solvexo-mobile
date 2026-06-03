import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int level;

  const CategoryTile({super.key, required this.category, required this.level});

  // Rotating accent colours per depth level
  static const _levelColors = [
    AppColors.categoryBlue,   // level 0 — primary blue
    AppColors.categoryPurple, // level 1 — purple
    AppColors.categoryTeal,   // level 2 — teal
    AppColors.categoryCoral,  // level 3 — coral
  ];

  Color get _accentColor => _levelColors[level.clamp(0, 3)];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final hasChildren = category.hasChildren;

    return Obx(() {
      final isExpanded = controller.isExpanded(category.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tile card ────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              if (hasChildren) {
                controller.toggleExpand(category.id);
              } else {
                Get.toNamed(
                  Routes.subCategoryView,
                  arguments: {
                    'categoryId': category.id,
                    'categoryName': category.name,
                  },
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.only(bottom: 8, left: level * 14.0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isExpanded
                    ? _accentColor.withOpacity(0.06)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isExpanded
                      ? _accentColor.withOpacity(0.3)
                      : AppColors.lightGrey.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: isExpanded
                    ? [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  // Icon / image container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: category.image != null && category.image!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CommonImageView(
                              url: category.image,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            hasChildren
                                ? Icons.folder_rounded
                                : Icons.category_rounded,
                            color: _accentColor,
                            size: AppFontSize.large,
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Name + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: category.name,
                          fontSize: AppFontSize.regular,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        if (hasChildren) ...[
                          const SizedBox(height: 3),
                          CustomText(
                            text:
                                '${category.children.length} subcategor${category.children.length == 1 ? 'y' : 'ies'}',
                            fontSize: AppFontSize.small,
                            color: AppColors.gray600,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Trailing indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? _accentColor.withOpacity(0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: hasChildren
                        ? AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isExpanded
                                  ? _accentColor
                                  : AppColors.gray600,
                              size: AppFontSize.medium,
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.gray600,
                            size: AppFontSize.small2,
                          ),
                  ),
                ],
              ),
            ),
          ),

          // ── Children with animated expand ─────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                children: category.children
                    .map(
                      (child) =>
                          CategoryTile(category: child, level: level + 1),
                    )
                    .toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}
