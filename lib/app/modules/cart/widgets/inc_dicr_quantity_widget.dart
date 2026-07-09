import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncDicrQuantityWidget extends StatelessWidget {
  final CartItem item;
  IncDicrQuantityWidget({super.key, required this.item});

  final controller = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs, horizontal: BaseSpacing.xxs + 1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(BaseRadius.xl),
      ),
      child: Row(
        children: [
          /// DECREASE
          Expanded(
            flex: 2,
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(
                color: AppColors.lightGrey10,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BaseRadius.xl),
                  bottomLeft: Radius.circular(BaseRadius.xl),
                ),
              ),
              child: InkWell(
                onTap: () => controller.decreaseQuantity(item.productId, item.productVariantId),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
                  child: Icon(Icons.remove, color: AppColors.grey, size: 18),
                ),
              ),
            ),
          ),

          /// QUANTITY
          Expanded(
            flex: 2,
            child: Center(
              child: Text(item.quantity.toString(), style: BaseTypography.titleMedium(color: AppColors.black)),
            ),
          ),

          /// INCREASE
          Expanded(
            flex: 2,
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(BaseRadius.xl),
                  bottomRight: Radius.circular(BaseRadius.xl),
                ),
              ),
              child: InkWell(
                onTap: () => controller.increaseQuantity(item.productId, item.productVariantId),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs),
                  child: Icon(Icons.add, color: AppColors.primaryColor, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
