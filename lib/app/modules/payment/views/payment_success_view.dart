import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    // Present only for a split (mixed digital+physical) order — the amount
    // the courier will collect in cash for the physical items on delivery.
    final codAmountDue = Get.arguments is double ? Get.arguments as double : null;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: BaseMotion.slow,
                curve: Curves.easeOutBack,
                builder: (_, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(Icons.check_circle, color: AppColors.seaGreen, size: 120),
                  );
                },
              ),
              SizedBox(height: BaseSpacing.xl),
              CustomText(
                text: "Payment Successful",
                color: AppColors.black,
                fontSize: AppFontSize.medium,
                fontWeight: FontWeight.w600,
              ),
              if (codAmountDue != null) ...[
                SizedBox(height: BaseSpacing.sm),
                CustomText(
                  text: "Pay \$${codAmountDue.toStringAsFixed(2)} in cash when your physical order is delivered.",
                  color: AppColors.gray600,
                  fontSize: AppFontSize.verySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: BaseSpacing.sm),
              PrimaryButton(
                onPressed: () => Get.offAllNamed(Routes.mainHome),
                label: "Continue Shopping",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
