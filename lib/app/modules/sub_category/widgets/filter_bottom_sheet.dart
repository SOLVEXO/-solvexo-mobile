import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/sub_category/controller/sub_category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CustomText(
                  text: 'Filters',
                  fontSize: AppFontSize.large,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 8),
                // Active filter count badge
                Obx(() {
                  final count = _activeCount(c);
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CustomText(
                      text: '$count',
                      fontSize: AppFontSize.small2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  );
                }),
                const Spacer(),
                // Reset button
                Obx(() {
                  final hasAny = _activeCount(c) > 0;
                  return GestureDetector(
                    onTap: hasAny
                        ? () {
                            c.resetFilters();
                            Get.back();
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: hasAny
                            ? AppColors.red.withOpacity(0.08)
                            : AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomText(
                        text: 'Reset all',
                        fontSize: AppFontSize.small2,
                        fontWeight: FontWeight.w600,
                        color: hasAny ? AppColors.red : AppColors.gray600,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Divider(color: AppColors.lightGrey.withOpacity(0.5), height: 1),

          // ── Scrollable content ────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Price Range ─────────────────────────────────
                  _SectionTitle(title: 'Price Range'),
                  const SizedBox(height: 14),

                  Obx(
                    () => Row(
                      children: [
                        _PriceTag(
                          label: 'Min',
                          value: '\$${c.currentMinFilter.value.toInt()}',
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              height: 1.5,
                              color: AppColors.lightGrey,
                            ),
                          ),
                        ),
                        _PriceTag(
                          label: 'Max',
                          value: '\$${c.currentMaxFilter.value.toInt()}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Obx(
                    () => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryColor,
                        inactiveTrackColor: AppColors.lightGrey.withOpacity(
                          0.5,
                        ),
                        thumbColor: AppColors.primaryColor,
                        overlayColor: AppColors.primaryColor.withOpacity(0.12),
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                      ),
                      child: RangeSlider(
                        min: 0,
                        max: 1000,
                        values: RangeValues(
                          c.currentMinFilter.value,
                          c.currentMaxFilter.value,
                        ),
                        onChanged: (v) {
                          c.minPrice.value = v.start;
                          c.maxPrice.value = v.end;
                          c.currentMinFilter.value = v.start;
                          c.currentMaxFilter.value = v.end;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Customer Rating ──────────────────────────────
                  _SectionTitle(title: 'Customer Rating'),
                  const SizedBox(height: 12),

                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
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

                  const SizedBox(height: 24),

                  // ── Brand ────────────────────────────────────────
                  Obx(() {
                    final brands = c.brands;
                    if (brands.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(title: 'Brand'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                        const SizedBox(height: 24),
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
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: Obx(
                () => ElevatedButton(
                  onPressed: () {
                    c.applyFilters();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'Apply Filters',
                        fontSize: AppFontSize.regular,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                      if (_activeCount(c) > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CustomText(
                            text: '${_activeCount(c)}',
                            fontSize: AppFontSize.small2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
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
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        CustomText(
          text: title,
          fontSize: AppFontSize.regular,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          CustomText(
            text: label,
            fontSize: AppFontSize.small,
            color: AppColors.gray600,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: value,
            fontSize: AppFontSize.regular,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
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

  const _RatingChip({
    required this.label,
    required this.stars,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stars > 0) ...[
              SvgIcon(assetName: AppIcons.fillStar, size: 14),
              const SizedBox(width: 4),
            ],
            CustomText(
              text: label,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
          ],
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

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
            width: 1.5,
          ),
        ),
        child: CustomText(
          text: label,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}
