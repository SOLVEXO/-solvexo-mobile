import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_list_actions.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_status_badge.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_type_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:book_store_app/app/modules/seller/utils/store_currency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final SellerProduct product;
  final VoidCallback? onEdit;
  final SellerProductsController? controller;

  const ProductCard({super.key, required this.product, this.onEdit, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return _card(context, false);
    return Obx(() {
      final selected = c.selectedIds.contains(product.id);
      return GestureDetector(
        onLongPress: () => c.toggleSelect(product.id),
        onTap: c.selecting ? () => c.toggleSelect(product.id) : null,
        child: _card(context, selected),
      );
    });
  }

  Widget _card(BuildContext context, bool selected) {
    final c = controller;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        border: selected ? Border.all(color: scheme.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (selected) ...[
                Icon(Icons.check_circle_rounded, color: scheme.primary),
                const SizedBox(width: 8),
              ],
              _ProductImage(
                emoji: product.emoji,
                images: product.images,
                imageFallback: product.image,
              ),
              const SizedBox(width: 12),
              Expanded(child: _ProductInfo(product: product)),
              const SizedBox(width: 4),
              if (c == null)
                _EditButton(onTap: onEdit ?? () {})
              else
                _RowMenu(product: product, controller: c, onEdit: onEdit),
            ],
          ),
          // "Fix now" for listings sent back by Edudeen, with its note.
          if (product.needsChanges) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    product.adminNote == null ? 'Edudeen asked for changes.' : 'Edudeen: ${product.adminNote}',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
                TextButton(
                  key: const Key('fixNow'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: onEdit,
                  child: const Text('Fix now'),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({required this.product, required this.controller, this.onEdit});
  final SellerProduct product;
  final SellerProductsController controller;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.busyIds.contains(product.id)) {
        return const SizedBox(width: 48, height: 48, child: Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2)));
      }
      return PopupMenuButton<String>(
        key: Key('menu_${product.id}'),
        tooltip: 'Actions',
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
        onSelected: (v) async {
          switch (v) {
            case 'edit':
              onEdit?.call();
            case 'price':
              await InlineEditSheet.price(controller, product);
            case 'stock':
              await InlineEditSheet.stock(controller, product);
            case 'duplicate':
              await controller.duplicate(product);
            case 'activate':
            case 'deactivate':
              final skipped = await controller.setActive([product.id], active: v == 'activate');
              if (skipped.isNotEmpty) await showSkipped(skipped);
            case 'premium':
              await PremiumOfferSheet.open(controller, product);
            case 'premium_off':
              final skipped = await controller.setOffer([product.id], 'premium_off');
              if (skipped.isNotEmpty) await showSkipped(skipped);
            case 'sale':
              await Get.toNamed(Routes.sellerPlatformSales);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'price', child: Text('Edit price')),
          if (product.isPhysical && product.defaultVariantId != null && product.variantCount == 1)
            const PopupMenuItem(value: 'stock', child: Text('Edit stock')),
          const PopupMenuItem(value: 'duplicate', child: Text('Duplicate as draft')),
          if (product.canActivate) const PopupMenuItem(value: 'activate', child: Text('Activate')),
          if (product.isLive) const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
          PopupMenuItem(value: 'premium', child: Text(product.inPremium ? 'Premium offer (${product.premiumPercent}%)' : 'Add to Premium')),
          if (product.inPremium) const PopupMenuItem(value: 'premium_off', child: Text('Remove from Premium')),
          const PopupMenuItem(value: 'sale', child: Text('Platform sales')),
        ],
      );
    });
  }
}

// ── Product image box ────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String emoji;
  final List<String> images;
  final String? imageFallback;

  const _ProductImage({
    required this.emoji,
    required this.images,
    this.imageFallback,
  });

  String? get _imageUrl {
    if (images.isNotEmpty) return images.first;
    if (imageFallback != null && imageFallback!.isNotEmpty) return imageFallback;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _imageUrl;
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.languageBg,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius + 4),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              placeholder: (_, __) => const _ImagePlaceholder(),
              errorWidget: (_, __, ___) => const _ImagePlaceholder(),
            )
          : const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.languageBg,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: AppColors.lightGrey5,
      ),
    );
  }
}

// ── Product info column ──────────────────────────────────────────────────────
class _ProductInfo extends StatelessWidget {
  final SellerProduct product;

  const _ProductInfo({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: product.name,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            CustomText(
              text: product.hasPriceRange
                  ? '${StoreCurrency.format(product.minPrice)} - ${StoreCurrency.format(product.maxPrice)}'
                  : StoreCurrency.format(product.price),
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontFamily: AppTextStyles.monoFontFamily,
            ),
            const SizedBox(width: 8),
            ProductTypeBadge(type: product.type),
            const SizedBox(width: 6),
            Builder(builder: (context) {
              final raw = rawStatusLabel(product, Theme.of(context).colorScheme);
              if (raw == null) return ProductStatusBadge(status: product.status);
              return Flexible(
                child: Text(raw.$1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: raw.$2, fontSize: 11, fontWeight: FontWeight.w700)),
              );
            }),
            if (product.variantCount > 1) ...[
              const SizedBox(width: 6),
              _VariantCountBadge(count: product.variantCount),
            ],
          ],
        ),
        const SizedBox(height: 5),
        CustomText(
          text: product.status == ProductStatus.scheduled && product.scheduledAt != null
              ? 'Goes live ${DateFormat('MMM d, y · h:mm a').format(product.scheduledAt!)}'
              : '${product.sold} sold · Stock: ${product.stockLabel}',
          fontSize: AppFontSize.tiny,
          color: product.status == ProductStatus.scheduled
              ? AppColors.orange
              : AppColors.lightGrey5,
        ),
      ],
    );
  }
}

// ── Variant count badge ───────────────────────────────────────────────────────
class _VariantCountBadge extends StatelessWidget {
  final int count;
  const _VariantCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomText(
        text: '$count variants',
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
        fontFamily: AppTextStyles.monoFontFamily,
      ),
    );
  }
}

// ── Edit button ──────────────────────────────────────────────────────────────
class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.lightGrey2),
        ),
        child: const CustomText(
          text: 'Edit',
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black2,
        ),
      ),
    );
  }
}
