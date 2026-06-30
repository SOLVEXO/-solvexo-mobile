import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/icon_with_text.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/app/modules/cart/widgets/inc_dicr_quantity_widget.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  CartItemWidget({super.key, required this.item});

  final controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                activeColor: AppColors.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                value: item.isSelected,
                onChanged: (v) => controller.toggleItemSelection(item, v!),
              ),

              /// Product Image
              CommonImageView(
                url: item.displayImage,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(10),
              ),

              const SizedBox(width: 10),

              /// Product Info
              Expanded(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // item.name directly (no product wrapper)
                    CustomText(
                      text: item.name,
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      text: "Color : White",
                      color: AppColors.gray600,
                      fontSize: AppFontSize.small,
                    ),
                    CustomText(
                      text: "${item.quantity} Item",
                      color: AppColors.gray600,
                      fontSize: AppFontSize.small,
                    ),
                    // unitPrice via actualPrice getter
                    CustomText(
                      text: "\$${item.actualPrice.toStringAsFixed(2)}",
                      fontSize: AppFontSize.regular,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),

              /// Delete — productId is now non-nullable
              CustomIconButton(
                assetName: AppIcons.deleteIcon,
                size: 30,
                isPadding: true,
                onPressed: () {
                  controller.showDeleteConfirmation(
                    onLeftButtonTap: () => controller.showWishListConformation(
                      onRightButtonTap: () => controller.moveToWishlist(item),
                    ),
                    onRightButtonTap: () => controller.removeFromCart(
                      item.productId,
                      item.productVariantId,
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            spacing: 20,
            children: [
              IconWithText(
                iconName: AppIcons.heartIcon,
                text: "WishList",
                onTap: () => controller.showWishListConformation(
                  onRightButtonTap: () => controller.moveToWishlist(item),
                ),
              ),
              IconWithText(
                iconName: AppIcons.deleteIcon,
                text: "Delete",
                onTap: () => controller.showDeleteConfirmation(
                  onLeftButtonTap: () => controller.showWishListConformation(
                    onRightButtonTap: () => controller.moveToWishlist(item),
                  ),
                  onRightButtonTap: () => controller.removeFromCart(
                    item.productId,
                    item.productVariantId,
                  ),
                ),
              ),
              Expanded(child: IncDicrQuantityWidget(item: item)),
            ],
          ),
        ],
      ),
    );
  }
}
