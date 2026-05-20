import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartIconWithCount extends StatelessWidget {
  CartIconWithCount({super.key});
  final BottomNavController bottombarcontroller = Get.put(
    BottomNavController(),
  );
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomIconButton(
          onPressed: () => Get.toNamed(Routes.cartView),
          isPadding: false,
          assetName: AppIcons.cartIcon,
          size: 22,
        ),
        Positioned(
          top: -6,
          right: -4,
          child: Obx(() {
            final count = bottombarcontroller.cartController.cartItems.length;

            if (count == 0) return const SizedBox();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: count > 9 ? "9+" : count.toString(),
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ),
      ],
    );
  }
}
