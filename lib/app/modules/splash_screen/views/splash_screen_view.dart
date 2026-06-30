import 'dart:math' as math;
import 'package:book_store_app/app/components/animated_background_circles.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/splash_screen/controllers/splash_screen_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
          ),

          // ── Animated background circles ──────────────────────────────────
          const AnimatedBackgroundCircles(),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo with glow pulse
                AnimatedBuilder(
                  animation: Listenable.merge([
                    controller.logoController,
                    controller.glowController,
                  ]),
                  builder: (context, _) {
                    final glow = controller.glowAnim.value;
                    return SlideTransition(
                      position: controller.slideAnim,
                      child: ScaleTransition(
                        scale: controller.scaleAnim,
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              // Base shadow
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              // Animated glow
                              BoxShadow(
                                color: AppColors.white.withOpacity(
                                  0.15 + 0.25 * glow,
                                ),
                                blurRadius: 20 + 30 * glow,
                                spreadRadius: 2 + 10 * glow,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              AppImages.logoImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Brand name + slogan
                AnimatedBuilder(
                  animation: controller.logoController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: controller.brandFade.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Brand name
                          const Text(
                            'Solvexo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Thin divider
                          Container(
                            width: 40,
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Animated slogan
                          SizedBox(
                            height: 22,
                            child: Center(
                              child: AnimatedBuilder(
                                animation: controller.sloganController,
                                builder: (context, _) {
                                  return Opacity(
                                    opacity: controller.sloganFade.value,
                                    child: Obx(
                                      () => Text(
                                        controller.currentSlogan,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.white.withOpacity(
                                            0.85,
                                          ),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(flex: 4),

                // ── Bottom logo mark + loading dots ──────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _AnimatedDots(glowAnim: controller.glowAnim),
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white.withOpacity(0.2),
                        ),
                        child: SvgIcon(
                          assetName: AppIcons.appLogoSvg,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated loading dots ───────────────────────────────────────────────────

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.glowAnim});
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot peaks at a different phase of the 0→1 cycle
            final phase = i / 3.0;
            final raw = math.sin(math.pi * ((glowAnim.value - phase) % 1.0));
            final t = raw.clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.5),
              child: Container(
                width: 6 + 2 * t,
                height: 6 + 2 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.3 + 0.6 * t),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
