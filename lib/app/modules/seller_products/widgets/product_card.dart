import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_status_badge.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_type_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final SellerProduct product;
  final VoidCallback? onEdit;

  const ProductCard({super.key, required this.product, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProductImage(
            emoji: product.emoji,
            images: product.images,
            imageFallback: product.image,
          ),
          const SizedBox(width: 12),
          Expanded(child: _ProductInfo(product: product)),
          const SizedBox(width: 10),
          _EditButton(onTap: onEdit ?? () {}),
        ],
      ),
    );
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
                  ? '\$${product.minPrice!.toStringAsFixed(2)} - \$${product.maxPrice!.toStringAsFixed(2)}'
                  : '\$${product.price.toStringAsFixed(2)}',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              fontFamily: AppTextStyles.monoFontFamily,
            ),
            const SizedBox(width: 8),
            ProductTypeBadge(type: product.type),
            const SizedBox(width: 6),
            ProductStatusBadge(status: product.status),
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
