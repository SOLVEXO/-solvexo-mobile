import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 20,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey10,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: IconButton(
              onPressed: () => controller.decreaseQty(item),
              icon: const Icon(Icons.remove, color: AppColors.grey),
            ),
          ),
          CustomText(
            text: item.quantity.toString(),
            fontSize: AppFontSize.medium,
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: IconButton(
              onPressed: () => controller.increaseQty(item),
              icon: const Icon(Icons.add, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
