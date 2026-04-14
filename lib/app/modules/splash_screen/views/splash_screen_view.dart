import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/splash_screen/controllers/splash_screen_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
        child: AnimatedBuilder(
          animation: controller.logoController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                SlideTransition(
                  position: controller.slideAnim,
                  child: ScaleTransition(
                    scale: controller.scaleAnim,
                    child: Container(
                      height: 90,
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(AppImages.fullLogo),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Opacity(
                  opacity: controller.textFade.value,
                  child: Column(
                    children: [
                      const CustomText(
                        text: "EduDeen",
                        fontSize: AppFontSize.medium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      CustomText(
                        text: "Read. Learn. Grow.",
                        fontSize: AppFontSize.small2,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
