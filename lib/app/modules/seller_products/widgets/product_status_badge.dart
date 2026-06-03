import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class ProductStatusBadge extends StatelessWidget {
  final ProductStatus status;

  const ProductStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomText(
        text: s.label,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: s.fg,
      ),
    );
  }

  static _Style _resolve(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return const _Style('Active', AppColors.darkGreen, AppColors.greenContainerInnerColor);
      case ProductStatus.draft:
        return const _Style('Draft', AppColors.grey, AppColors.lightGrey10);
      case ProductStatus.lowStock:
        return const _Style('Low Stock', AppColors.amberDark, AppColors.yellowBg);
      case ProductStatus.outOfStock:
        return const _Style('Out of Stock', AppColors.red, AppColors.lightRed);
      default:
        return const _Style('All', AppColors.grey, AppColors.background);
    }
  }
}

class _Style {
  final String label;
  final Color fg;
  final Color bg;
  const _Style(this.label, this.fg, this.bg);
}
