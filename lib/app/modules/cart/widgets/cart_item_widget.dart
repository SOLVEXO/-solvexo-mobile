import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/icon_with_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';
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
                materialTapTargetSize: MaterialTapTargetSize.padded,
                value: item.isSelected,
                onChanged: (v) => controller.toggleItemSelection(item, v!),
              ),

              /// Product Image
              SvgIcon(assetName: item.product.image, size: 60),

              const SizedBox(width: 10),

              /// Product Info
              Expanded(
                child: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: item.product.name,
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
                    CustomText(
                      text: "\$${item.product.price}",
                      fontSize: AppFontSize.regular,
                      fontWeight: FontWeight.bold,
                    ),

                    /// Quantity
                  ],
                ),
              ),

              /// Delete
              CustomIconButton(
                assetName: AppIcons.deleteIcon,
                size: 35,
                isPadding: true,
                onPressed: () {
                  controller.showDeleteConfirmation(
                    () => controller.removeItem(item),
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
                onTap: () => controller.showWishListConformation(),
              ),
              IconWithText(
                iconName: AppIcons.deleteIcon,
                text: "Delete",
                onTap: () => controller.showDeleteConfirmation(
                  () => controller.removeItem(item),
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
