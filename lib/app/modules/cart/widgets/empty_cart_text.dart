import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl, vertical: BaseSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: BaseSpacing.xl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcon(assetName: AppIcons.emptyCart, size: 100, color: AppColors.gray600.withOpacity(0.3)),
                  CustomText(
                    text: "Your Shopping cart is empty",
                    color: AppColors.gray600.withOpacity(0.3),
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                  ),
                  PrimaryButton(
                    label: "Start Shopping",
                    onPressed: () => Get.toNamed(Routes.categoryView),
                  ),
                  SizedBox(height: size.height / 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Featured Items you may like",
                        color: AppColors.black,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w600,
                      ),
                      RecommendedProductList(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
