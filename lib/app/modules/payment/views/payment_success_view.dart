import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (_, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.seaGreen,
                      size: 120,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Payment Successful",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              AppButton(
                onPressed: () {
                  Get.offAllNamed(Routes.mainHome);
                },
                label: "Continue Shopping",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
