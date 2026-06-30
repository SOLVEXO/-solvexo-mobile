import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_status_badge.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_type_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
              text: '\$${product.price.toStringAsFixed(2)}',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            ProductTypeBadge(type: product.type),
            const SizedBox(width: 6),
            ProductStatusBadge(status: product.status),
          ],
        ),
        const SizedBox(height: 5),
        CustomText(
          text:
              '${product.sold} sold · Stock: ${product.stockLabel}',
          fontSize: AppFontSize.tiny,
          color: AppColors.lightGrey5,
        ),
      ],
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
