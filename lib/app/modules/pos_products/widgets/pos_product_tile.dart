import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_products/controllers/pos_products_controller.dart';
import 'package:book_store_app/app/modules/pos_products/widgets/pos_stock_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class PosProductTile extends StatelessWidget {
  final PosProductItem product;

  const PosProductTile({super.key, required this.product});

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
        children: [
          _emojiBox(),
          const SizedBox(width: 12),
          Expanded(child: _productInfo()),
          const SizedBox(width: 12),
          PosStockBadge(stockCount: product.stockCount),
        ],
      ),
    );
  }

  Widget _emojiBox() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      ),
      alignment: Alignment.center,
      child: Text(
        product.emoji,
        style: const TextStyle(fontSize: 26),
      ),
    );
  }

  Widget _productInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: product.name,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 3),
        CustomText(
          text: '${product.sku} · ${product.category}',
          fontSize: AppFontSize.tiny,
          color: AppColors.grey,
        ),
        const SizedBox(height: 5),
        CustomText(
          text: '\$${product.price.toStringAsFixed(2)}',
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
      ],
    );
  }
}
