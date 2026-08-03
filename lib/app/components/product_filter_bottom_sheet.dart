import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Staged filter/sort selection produced when "Apply" is tapped — the caller
/// decides what to do with it (persist into its own controller state, refetch
/// from the server, etc.). This widget never talks to a controller directly,
/// which is what lets the same sheet back Home and Subcategory browsing.
class ProductFilterResult {
  final double minPrice;
  final double maxPrice;
  final double rating;
  final String sort;
  final String? educationLevel;
  final String? normalizedCustomLevel;

  const ProductFilterResult({
    required this.minPrice,
    required this.maxPrice,
    required this.rating,
    required this.sort,
    this.educationLevel,
    this.normalizedCustomLevel,
  });
}

class _SortOption {
  final String value;
  final String label;
  const _SortOption(this.value, this.label);
}

const List<_SortOption> _sortOptions = [
  _SortOption('newest', 'Newest'),
  _SortOption('price_asc', 'Price: Low to High'),
  _SortOption('price_desc', 'Price: High to Low'),
  _SortOption('rating', 'Top Rated'),
];

/// Product price/rating/sort filter sheet, shared by Home and Subcategory
/// browsing. Every value is passed in and every change is reported back via
/// [onApply]/[onReset] — this widget holds no product-fetching state of its
/// own, so any screen with a price range + rating + sort can reuse it.
class ProductFilterBottomSheet extends StatefulWidget {
  final double minBound;
  final double maxBound;
  final double initialMinPrice;
  final double initialMaxPrice;
  final double initialRating;
  final String initialSort;

  /// Null hides the "Education Level" section entirely (e.g. on Home).
  final EducationFacetsResult? educationFacets;
  final String? initialEducationLevel;
  final String? initialNormalizedCustomLevel;

  final ValueChanged<ProductFilterResult> onApply;
  final VoidCallback onReset;

  const ProductFilterBottomSheet({
    super.key,
    this.minBound = 0,
    this.maxBound = 1000,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    required this.initialRating,
    required this.initialSort,
    this.educationFacets,
    this.initialEducationLevel,
    this.initialNormalizedCustomLevel,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late double _rating;
  late String _sort;
  String? _educationLevel;
  String? _normalizedCustomLevel;

  static const List<double> _ratings = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _rating = widget.initialRating;
    _sort = widget.initialSort;
    _educationLevel = widget.initialEducationLevel;
    _normalizedCustomLevel = widget.initialNormalizedCustomLevel;
  }

  int get _activeCount {
    int count = 0;
    if (_rating > 0) count++;
    if (_minPrice > widget.minBound || _maxPrice < widget.maxBound) count++;
    if (_educationLevel != null) count++;
    return count;
  }

  void _reset() {
    widget.onReset();
    Get.back();
  }

  void _apply() {
    widget.onApply(
      ProductFilterResult(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        rating: _rating,
        sort: _sort,
        educationLevel: _educationLevel,
        normalizedCustomLevel: _normalizedCustomLevel,
      ),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // Callers gate this by passing `null` when their current result set has
    // no educational products at all (e.g. Home, or a non-educational
    // subcategory) — facet counts are global, not scoped to the category.
    final facets = widget.educationFacets;
    final showEducationSection = facets != null;

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
                CustomText(text: 'Filters', color: AppColors.textPrimary, fontFamily: AppTextStyles.headingFontFamily, fontSize: AppFontSize.medium, fontWeight: FontWeight.w600),
                SizedBox(width: BaseSpacing.xs),
                if (_activeCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xxs / 2),
                    decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.pill)),
                    child: CustomText(text: '$_activeCount', color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
                  ),
                const Spacer(),
                GhostButton(
                  label: 'Reset all',
                  onPressed: _activeCount > 0 ? _reset : null,
                ),
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
                  // ── Sort By ───────────────────────────────────────
                  _SectionTitle(title: 'Sort By'),
                  SizedBox(height: BaseSpacing.sm),
                  Wrap(
                    spacing: BaseSpacing.xs,
                    runSpacing: BaseSpacing.xs,
                    children: _sortOptions
                        .map(
                          (opt) => _SelectableChip(
                            label: opt.label,
                            isSelected: _sort == opt.value,
                            onTap: () => setState(() => _sort = opt.value),
                          ),
                        )
                        .toList(),
                  ),

                  SizedBox(height: BaseSpacing.xl),

                  // ── Price Range ─────────────────────────────────
                  _SectionTitle(title: 'Price Range'),
                  SizedBox(height: BaseSpacing.sm + 2),

                  Row(
                    children: [
                      _PriceTag(label: 'Min', value: '\$${_minPrice.toInt()}'),
                      Expanded(
                        child: Center(child: Container(height: 1.5, color: AppColors.lightGrey)),
                      ),
                      _PriceTag(label: 'Max', value: '\$${_maxPrice.toInt()}'),
                    ],
                  ),

                  SizedBox(height: BaseSpacing.xs),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryColor,
                      inactiveTrackColor: AppColors.lightGrey.withOpacity(0.5),
                      thumbColor: AppColors.primaryColor,
                      overlayColor: AppColors.primaryColor.withOpacity(0.12),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    ),
                    child: RangeSlider(
                      min: widget.minBound,
                      max: widget.maxBound,
                      values: RangeValues(_minPrice, _maxPrice),
                      onChanged: (v) => setState(() {
                        _minPrice = v.start;
                        _maxPrice = v.end;
                      }),
                    ),
                  ),

                  SizedBox(height: BaseSpacing.xl),

                  // ── Customer Rating ──────────────────────────────
                  _SectionTitle(title: 'Customer Rating'),
                  SizedBox(height: BaseSpacing.sm),

                  Wrap(
                    spacing: BaseSpacing.xs,
                    runSpacing: BaseSpacing.xs,
                    children: [
                      _RatingChip(
                        label: 'Any',
                        stars: 0,
                        isSelected: _rating == 0,
                        onTap: () => setState(() => _rating = 0),
                      ),
                      ..._ratings.map(
                        (r) => _RatingChip(
                          label: '${r.toInt()}★+',
                          stars: r.toInt(),
                          isSelected: _rating == r,
                          onTap: () => setState(() => _rating = r),
                        ),
                      ),
                    ],
                  ),

                  // ── Education Level ──────────────────────────────
                  if (showEducationSection) ...[
                    SizedBox(height: BaseSpacing.xl),
                    _SectionTitle(title: 'Education Level'),
                    SizedBox(height: BaseSpacing.sm),
                    Wrap(
                      spacing: BaseSpacing.xs,
                      runSpacing: BaseSpacing.xs,
                      children: [
                        _SelectableChip(
                          label: 'All',
                          isSelected: _educationLevel == null,
                          onTap: () => setState(() {
                            _educationLevel = null;
                            _normalizedCustomLevel = null;
                          }),
                        ),
                        for (final level in kEducationLevels)
                          if (level.value == 'other' || facets.levels.any((l) => l.level == level.value))
                            _SelectableChip(
                              label: level.value == 'other'
                                  ? 'Other'
                                  : '${level.label} (${facets.levels.firstWhere((l) => l.level == level.value).count})',
                              isSelected: _educationLevel == level.value,
                              onTap: () => setState(() {
                                _educationLevel = level.value;
                                if (level.value != 'other') _normalizedCustomLevel = null;
                              }),
                            ),
                      ],
                    ),
                    if (_educationLevel == 'other' && facets.otherLevels.isNotEmpty) ...[
                      SizedBox(height: BaseSpacing.sm),
                      Wrap(
                        spacing: BaseSpacing.xs,
                        runSpacing: BaseSpacing.xs,
                        children: facets.otherLevels
                            .map(
                              (o) => _SelectableChip(
                                label: '${o.displayName} (${o.count})',
                                isSelected: _normalizedCustomLevel == o.slug,
                                onTap: () => setState(() => _normalizedCustomLevel = o.slug),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],

                  SizedBox(height: BaseSpacing.xl),
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
            child: PrimaryButton(
              label: _activeCount > 0 ? 'Apply Filters ($_activeCount)' : 'Apply Filters',
              onPressed: _apply,
            ),
          ),
        ],
      ),
    );
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
        CustomText(text: title, color: AppColors.textPrimary, fontFamily: AppTextStyles.headingFontFamily, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
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
          CustomText(
            text: value,
            color: AppColors.primaryColor,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w700,
            fontFamily: AppTextStyles.monoFontFamily,
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
                fontFamily: AppTextStyles.monoFontFamily,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Selectable Chip (Sort / Education Level) ───────────────────────────────

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
            fontFamily: AppTextStyles.monoFontFamily,
          ),
        ),
      ),
    );
  }
}
