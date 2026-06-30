import 'package:book_store_app/app/components/animated_background_circles.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/login/controller/auth_tabs_controller.dart';
import 'package:book_store_app/app/modules/login/login_view.dart';
import 'package:book_store_app/app/modules/signup/sign_up_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthTabsView extends StatelessWidget {
  AuthTabsView({super.key});

  final controller = Get.put(AuthTabsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top: logo + brand
                Expanded(
                  flex: 2,
                  child: const _TopBrand(),
                ),

                // Bottom: white card with tabs + form
                Expanded(
                  flex: 8,
                  child: _AuthCard(controller: controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top brand section ─────────────────────────────────────────────────────────

class _TopBrand extends StatelessWidget {
  const _TopBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo container
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.white.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(AppImages.logoImage, fit: BoxFit.contain),
          ),
        ),

        const SizedBox(height: 8),

        const CustomText(
          text: 'Solvexo',
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ],
    );
  }
}

// ── White auth card ───────────────────────────────────────────────────────────

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.controller});
  final AuthTabsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black12,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ── Tab toggle ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.lightGrey2,
                  width: 0.4,
                ),
              ),
              child: Row(
                children: [
                  _TabButton(label: 'Sign In', index: 0, controller: controller),
                  _TabButton(label: 'Sign Up', index: 1, controller: controller),
                ],
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Form area ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: controller.tabIndex.value == 0
                  ? LoginView(key: const ValueKey(0))
                  : SignUpView(key: const ValueKey(1)),
            )),
          ),
        ],
      ),
    );
  }
}

// ── Tab button ────────────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.index,
    required this.controller,
  });
  final String label;
  final int index;
  final AuthTabsController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(index),
        child: Obx(() {
          final active = controller.tabIndex.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryColor : AppColors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: CustomText(
              text: label,
              color: active ? AppColors.white : AppColors.grey,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          );
        }),
      ),
    );
  }
}

