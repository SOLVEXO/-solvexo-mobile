import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosProductCard extends StatelessWidget {
  final PosHomeController c;
  final PosProduct product;
  const PosProductCard({super.key, required this.c, required this.product});

  static const Map<String, Color> _bgColors = {
    'Ceramics':   Color(0xFFFFF3E0),
    'Accessories': Color(0xFFE8F5E9),
    'Prints':     Color(0xFFE3F2FD),
    'Candles':    Color(0xFFFCE4EC),
    'Stationery': Color(0xFFF3E5F5),
  };

  Color get _cardBg => _bgColors[product.category] ?? const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty   = c.cartQtyFor(product);
      final inCart = qty > 0;
      final isOut  = product.isOutOfStock;

      return GestureDetector(
        onTap: isOut ? null : () => c.addToCart(product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: inCart ? AppColors.primaryColor : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: inCart
                    ? AppColors.primaryColor.withOpacity(0.18)
                    : AppColors.black.withOpacity(0.06),
                blurRadius: inCart ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(children: [
              // ── Coloured emoji area ───────────────────────────────
              Expanded(
                flex: 11,
                child: Container(
                  width: double.infinity,
                  color: isOut ? const Color(0xFFF0F0F0) : _cardBg,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Emoji
                      Text(
                        product.emoji,
                        style: TextStyle(
                          fontSize: 32,
                          color: isOut ? AppColors.black.withOpacity(0.12) : null,
                        ),
                      ),
                      // Cart qty badge
                      if (inCart)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: CustomText(
                              text: '$qty',
                              color: AppColors.white,
                              fontSize: AppFontSize.tiny,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // Low-stock badge
                      if (product.isLowStock && !isOut)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: CustomText(
                              text: '${product.stock} left',
                              fontSize: AppFontSize.tiny,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // ── Info area ─────────────────────────────────────────
              Expanded(
                flex: 9,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
                  color: inCart ? AppColors.primaryColor.withOpacity(0.04) : AppColors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: product.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                        color: isOut ? AppColors.lightGrey : AppColors.black2,
                      ),
                      const SizedBox(height: 4),
                      if (isOut)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const CustomText(
                            text: 'Out of Stock',
                            fontSize: AppFontSize.tiny,
                            color: AppColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        CustomText(
                          text: '\$${product.price.toStringAsFixed(2)}',
                          fontSize: AppFontSize.verySmall,
                          fontWeight: FontWeight.bold,
                          color: inCart ? AppColors.primaryColor : AppColors.black2,
                        ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
