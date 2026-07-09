import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/sub_category/controller/sub_category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheetSubCategory extends StatelessWidget {
  FilterBottomSheetSubCategory({super.key});

  final SubCategoryController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Max 85% of screen height — scrollable when content overflows
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(BaseRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: BaseSpacing.xs + 2, bottom: BaseSpacing.md),
            decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(BaseRadius.xs)),
          ),

          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
            child: Row(
              children: [
                CustomText(text: 'Filters', color: AppColors.textPrimary, fontSize: AppFontSize.medium, fontWeight: FontWeight.w600),
                SizedBox(width: BaseSpacing.xs),
                // Active filter count badge
                Obx(() {
                  final count = _activeCount(c);
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xxs / 2),
                    decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.pill)),
                    child: CustomText(text: '$count', color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                  );
                }),
                const Spacer(),
                // Reset button
                Obx(() {
                  final hasAny = _activeCount(c) > 0;
                  return GhostButton(
                    label: 'Reset all',
                    onPressed: hasAny
                        ? () {
                            c.resetFilters();
                            Get.back();
                          }
                        : null,
                  );
                }),
              ],
            ),
          ),

          SizedBox(height: BaseSpacing.xxs),
          Divider(color: AppColors.lightGrey.withOpacity(0.5), height: 1),

          // ── Scrollable content ────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(BaseSpacing.xl, BaseSpacing.xl, BaseSpacing.xl, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Price Range ─────────────────────────────────
                  _SectionTitle(title: 'Price Range'),
                  SizedBox(height: BaseSpacing.sm + 2),

                  Obx(
                    () => Row(
                      children: [
                        _PriceTag(label: 'Min', value: '\$${c.currentMinFilter.value.toInt()}'),
                        Expanded(
                          child: Center(child: Container(height: 1.5, color: AppColors.lightGrey)),
                        ),
                        _PriceTag(label: 'Max', value: '\$${c.currentMaxFilter.value.toInt()}'),
                      ],
                    ),
                  ),

                  SizedBox(height: BaseSpacing.xs),

                  Obx(
                    () => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryColor,
                        inactiveTrackColor: AppColors.lightGrey.withOpacity(0.5),
                        thumbColor: AppColors.primaryColor,
                        overlayColor: AppColors.primaryColor.withOpacity(0.12),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: RangeSlider(
                        min: 0,
                        max: 1000,
                        values: RangeValues(c.currentMinFilter.value, c.currentMaxFilter.value),
                        onChanged: (v) {
                          c.minPrice.value = v.start;
                          c.maxPrice.value = v.end;
                          c.currentMinFilter.value = v.start;
                          c.currentMaxFilter.value = v.end;
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: BaseSpacing.xl),

                  // ── Customer Rating ──────────────────────────────
                  _SectionTitle(title: 'Customer Rating'),
                  SizedBox(height: BaseSpacing.sm),

                  Obx(
                    () => Wrap(
                      spacing: BaseSpacing.xs,
                      runSpacing: BaseSpacing.xs,
                      children: [
                        _RatingChip(
                          label: 'Any',
                          stars: 0,
                          isSelected: c.selectedRating.value == 0,
                          onTap: () => c.selectedRating.value = 0,
                        ),
                        ...c.ratings.map(
                          (r) => _RatingChip(
                            label: '${r.toInt()}★+',
                            stars: r.toInt(),
                            isSelected: c.selectedRating.value == r,
                            onTap: () => c.selectedRating.value = r,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: BaseSpacing.xl),

                  // ── Brand ────────────────────────────────────────
                  Obx(() {
                    final brands = c.brands;
                    if (brands.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(title: 'Brand'),
                        SizedBox(height: BaseSpacing.sm),
                        Wrap(
                          spacing: BaseSpacing.xs,
                          runSpacing: BaseSpacing.xs,
                          children: [
                            // "All" chip
                            _SelectableChip(
                              label: 'All',
                              isSelected: c.selectedBrand.value.isEmpty,
                              onTap: () => c.selectedBrand.value = '',
                            ),
                            ...brands.map(
                              (b) => _SelectableChip(
                                label: b,
                                isSelected: c.selectedBrand.value == b,
                                onTap: () => c.selectedBrand.value = b,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: BaseSpacing.xl),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Apply button (pinned to bottom) ───────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              BaseSpacing.xl,
              BaseSpacing.sm,
              BaseSpacing.xl,
              MediaQuery.of(context).padding.bottom + BaseSpacing.xl,
            ),
            child: Obx(() {
              final activeCount = _activeCount(c);
              return PrimaryButton(
                label: activeCount > 0 ? 'Apply Filters ($activeCount)' : 'Apply Filters',
                onPressed: () {
                  c.applyFilters();
                  Get.back();
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  int _activeCount(SubCategoryController c) {
    int count = 0;
    if (c.selectedBrand.value.isNotEmpty) count++;
    if (c.selectedRating.value > 0) count++;
    if (c.currentMinFilter.value > 0 || c.currentMaxFilter.value < 1000) {
      count++;
    }
    return count;
  }
}

// ─── Section Title ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.xs)),
        ),
        SizedBox(width: BaseSpacing.xs),
        CustomText(text: title, color: AppColors.textPrimary, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
      ],
    );
  }
}

// ─── Price Tag ─────────────────────────────────────────────────────────────

class _PriceTag extends StatelessWidget {
  final String label;
  final String value;
  const _PriceTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.xs),
      decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.07), borderRadius: BorderRadius.circular(BaseRadius.sm)),
      child: Column(
        children: [
          CustomText(text: label, color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w500),
          SizedBox(height: BaseSpacing.xxs / 2),
          CustomText(text: value, color: AppColors.primaryColor, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}

// ─── Rating Chip ───────────────────────────────────────────────────────────

class _RatingChip extends StatelessWidget {
  final String label;
  final int stars;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatingChip({required this.label, required this.stars, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: BaseMotion.normal,
          constraints: const BoxConstraints(minHeight: 40),
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : AppColors.background,
            borderRadius: BorderRadius.circular(BaseRadius.pill),
            border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.lightGrey, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (stars > 0) ...[
                SvgIcon(assetName: AppIcons.fillStar, size: 14),
                SizedBox(width: BaseSpacing.xxs),
              ],
              CustomText(
                text: label,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selectable Chip (Brand) ───────────────────────────────────────────────

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: BaseMotion.normal,
          constraints: const BoxConstraints(minHeight: 40),
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : AppColors.background,
            borderRadius: BorderRadius.circular(BaseRadius.pill),
            border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.lightGrey, width: 1.5),
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
