import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int level;

  const CategoryTile({super.key, required this.category, required this.level});

  // Rotating accent colours per depth level
  static const _levelColors = [
    AppColors.categoryBlue, // level 0 — primary blue
    AppColors.categoryPurple, // level 1 — purple
    AppColors.categoryTeal, // level 2 — teal
    AppColors.categoryCoral, // level 3 — coral
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
          Semantics(
            button: true,
            expanded: hasChildren ? isExpanded : null,
            label: category.name,
            child: GestureDetector(
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
                duration: BaseMotion.normal,
                constraints: const BoxConstraints(minHeight: 48),
                margin: EdgeInsets.only(bottom: BaseSpacing.xs, left: level * 14.0),
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.sm),
                decoration: BoxDecoration(
                  color: isExpanded ? _accentColor.withOpacity(0.06) : AppColors.white,
                  borderRadius: BorderRadius.circular(BaseRadius.lg),
                  border: Border.all(
                    color: isExpanded ? _accentColor.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: isExpanded
                      ? [BoxShadow(color: _accentColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]
                      : BaseShadows.forLevel(BaseElevation.level1),
                ),
                child: Row(
                  children: [
                    // Icon / image container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(BaseRadius.md - 1),
                      ),
                      child: category.image != null && category.image!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(BaseRadius.md - 1),
                              child: CommonImageView(url: category.image, width: 44, height: 44, fit: BoxFit.cover),
                            )
                          : Icon(
                              hasChildren ? Icons.folder_rounded : Icons.category_rounded,
                              color: _accentColor,
                              size: 26,
                            ),
                    ),

                    SizedBox(width: BaseSpacing.sm),

                    // Name + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: category.name,
                            color: AppColors.textPrimary,
                            fontSize: AppFontSize.small,
                            fontWeight: FontWeight.w600,
                          ),
                          if (hasChildren) ...[
                            SizedBox(height: BaseSpacing.xxs - 1),
                            CustomText(
                              text:
                                  '${category.children.length} subcategor${category.children.length == 1 ? 'y' : 'ies'}',
                              color: AppColors.gray600,
                              fontSize: AppFontSize.tiny,
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(width: BaseSpacing.xs),

                    // Trailing indicator
                    AnimatedContainer(
                      duration: BaseMotion.normal,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isExpanded ? _accentColor.withOpacity(0.12) : AppColors.background,
                        borderRadius: BorderRadius.circular(BaseRadius.xs + 2),
                      ),
                      alignment: Alignment.center,
                      child: hasChildren
                          ? AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration: BaseMotion.normal,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isExpanded ? _accentColor : AppColors.gray600,
                                size: 20,
                              ),
                            )
                          : Icon(Icons.arrow_forward_ios_rounded, color: AppColors.gray600, size: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Children with animated expand ─────────────────────────────
          AnimatedCrossFade(
            duration: BaseMotion.normal,
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.only(left: BaseSpacing.xs),
              child: Column(
                children: category.children.map((child) => CategoryTile(category: child, level: level + 1)).toList(),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}
