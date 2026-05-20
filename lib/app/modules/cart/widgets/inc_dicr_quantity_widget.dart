import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncDicrQuantityWidget extends StatelessWidget {
  final CartItem item;
  IncDicrQuantityWidget({super.key, required this.item});

  final controller = Get.find<CartController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          /// 🔻 DECREASE
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGrey10,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: InkWell(
                onTap: () => controller.decreaseQuantity(
                  item.productId,
                  item.productVariantId,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Icon(Icons.remove, color: AppColors.grey, size: 18),
                ),
              ),
            ),
          ),

          /// 🔹 QUANTITY
          Expanded(
            flex: 2,
            child: Center(
              child: CustomText(
                text: item.quantity.toString(),
                fontSize: AppFontSize.medium,
              ),
            ),
          ),

          /// 🔺 INCREASE
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: InkWell(
                onTap: () => controller.increaseQuantity(
                  item.productId,
                  item.productVariantId,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Icon(
                    Icons.add,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
