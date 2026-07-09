import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
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
              Text(
                "Payment Successful",
                style: BaseTypography.headlineSmall(color: AppColors.black),
              ),
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
