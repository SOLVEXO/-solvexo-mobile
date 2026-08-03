import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Checkbox picker + simple reorder (up/down, no drag-and-drop) for the
/// storefront's pinned products — fetches a single, reasonably large page of
/// the seller's own inventory via [SellerProductRepository.fetchStoreInventory]
/// rather than building full pagination into this picker.
class StorePinnedProductsSheet extends StatefulWidget {
  final SellerStoreProfileController controller;

  const StorePinnedProductsSheet({super.key, required this.controller});

  static void show(BuildContext context, SellerStoreProfileController controller) {
    Get.bottomSheet(
      StorePinnedProductsSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<StorePinnedProductsSheet> createState() => _StorePinnedProductsSheetState();
}

class _StorePinnedProductsSheetState extends State<StorePinnedProductsSheet> {
  final _repo = SellerProductRepository();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasMore = false;
  List<Map<String, dynamic>> _products = const [];
  List<String> _selected = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storeId = widget.controller.store.value?.id ?? '';
    if (storeId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    final result = await _repo.fetchStoreInventory(storeId: storeId, limit: 100);
    final pinned = widget.controller.store.value?.pinnedProductIds ?? const [];
    setState(() {
      _products = result.products;
      _hasMore = result.hasMore;
      _selected = pinned.where((id) => _products.any((p) => p['productId'] == id)).toList();
      _isLoading = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _moveUp(int selectedIndex) {
    if (selectedIndex <= 0) return;
    setState(() {
      final item = _selected.removeAt(selectedIndex);
      _selected.insert(selectedIndex - 1, item);
    });
  }

  void _moveDown(int selectedIndex) {
    if (selectedIndex >= _selected.length - 1) return;
    setState(() {
      final item = _selected.removeAt(selectedIndex);
      _selected.insert(selectedIndex + 1, item);
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final ok = await widget.controller.savePinnedProducts(_selected);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // Selected items shown first, in selection order; the rest follow.
    final ordered = [
      ..._selected.map((id) => _products.firstWhere((p) => p['productId'] == id, orElse: () => {'productId': id, 'name': 'Product'})),
      ..._products.where((p) => !_selected.contains(p['productId'])),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: BaseSpacing.sm),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.md, BaseSpacing.lg, BaseSpacing.xxs),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomText(text: 'Pinned Products', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                      ),
                      CustomText(text: '${_selected.length} selected', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                    ],
                  ),
                ),
                if (_hasMore)
                  Padding(
                    padding: EdgeInsets.fromLTRB(BaseSpacing.lg, 0, BaseSpacing.lg, BaseSpacing.xs),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: 'Showing your first 100 products.',
                        color: AppColors.lightGrey7,
                        fontSize: AppFontSize.tiny,
                      ),
                    ),
                  ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                      : ordered.isEmpty
                          ? Center(
                              child: CustomText(text: 'No products yet.', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(BaseSpacing.lg, 0, BaseSpacing.lg, BaseSpacing.lg),
                              itemCount: ordered.length,
                              separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.xs),
                              itemBuilder: (_, i) {
                                final product = ordered[i];
                                final id = product['productId'] as String? ?? '';
                                final isSelected = _selected.contains(id);
                                final selectedIndex = isSelected ? _selected.indexOf(id) : -1;
                                return _ProductRow(
                                  name: product['name'] as String? ?? 'Product',
                                  image: product['image'] as String?,
                                  price: (product['price'] as num?)?.toDouble(),
                                  isSelected: isSelected,
                                  onToggle: () => _toggle(id),
                                  onMoveUp: isSelected && selectedIndex > 0 ? () => _moveUp(selectedIndex) : null,
                                  onMoveDown: isSelected && selectedIndex < _selected.length - 1 ? () => _moveDown(selectedIndex) : null,
                                );
                              },
                            ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.xs, BaseSpacing.lg, BaseSpacing.lg),
                  child: GestureDetector(
                    onTap: _isSaving ? null : _save,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 50),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(BaseRadius.md)),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                          : CustomText(text: 'Save', color: AppColors.white, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String name;
  final String? image;
  final double? price;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _ProductRow({
    required this.name,
    required this.image,
    required this.price,
    required this.isSelected,
    required this.onToggle,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor.withOpacity(0.06) : AppColors.background,
        borderRadius: BorderRadius.circular(BaseRadius.md),
      ),
      child: Row(
        children: [
          Checkbox(value: isSelected, onChanged: (_) => onToggle(), activeColor: AppColors.primaryColor),
          ClipRRect(
            borderRadius: BorderRadius.circular(BaseRadius.sm),
            child: CommonImageView(url: image, height: 40, width: 40, fit: BoxFit.cover),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: name, color: AppColors.black2, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (price != null)
                  CustomText(text: '\$${price!.toStringAsFixed(2)}', color: AppColors.gray600, fontSize: 10.5, fontWeight: FontWeight.w600),
              ],
            ),
          ),
          if (isSelected) ...[
            GestureDetector(
              onTap: onMoveUp,
              child: Icon(Icons.keyboard_arrow_up_rounded, size: 22, color: onMoveUp != null ? AppColors.black2 : AppColors.lightGrey7),
            ),
            GestureDetector(
              onTap: onMoveDown,
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: onMoveDown != null ? AppColors.black2 : AppColors.lightGrey7),
            ),
          ],
        ],
      ),
    );
  }
}
