import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyCartText extends StatelessWidget {
  const EmptyCartText({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(assetName: AppIcons.emptyCart, size: 100),
          CustomText(
            text: "Your Shopping cart is empty",
            fontWeight: FontWeight.w700,
            fontSize: AppFontSize.large,
          ),
          AppButton(
            label: "Start Shopping",
            onPressed: () {
              Get.toNamed(Routes.categoryView);
            },
          ),
          SizedBox(height: size.height / 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Featured Items you may like",
                fontSize: AppFontSize.regular,
                fontWeight: FontWeight.w600,
              ),
              RecommendedProductList(),
            ],
          ),
        ],
      ),
    );
  }
}
