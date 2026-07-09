import 'package:book_store_app/app/components/animated_background_circles.dart';
import 'package:book_store_app/app/modules/login/controller/auth_tabs_controller.dart';
import 'package:book_store_app/app/modules/login/login_view.dart';
import 'package:book_store_app/app/modules/signup/sign_up_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthTabsView extends StatelessWidget {
  const AuthTabsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthTabsController>();
    return BaseViewScreen(
      child: Stack(
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
          Column(
            children: [
              // Top: logo + brand
              const Expanded(flex: 2, child: _TopBrand()),

              // Bottom: white card with tabs + form
              Expanded(flex: 8, child: _AuthCard(controller: controller)),
            ],
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
            borderRadius: BorderRadius.circular(BaseRadius.xl),
            boxShadow: [
              ...BaseShadows.forLevel(BaseElevation.level4),
              BoxShadow(
                color: AppColors.white.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(BaseSpacing.xs + 2),
            child: Image.asset(AppImages.logoImage, fit: BoxFit.contain),
          ),
        ),

        SizedBox(height: BaseSpacing.xs),

        Text(
          'Solvexo',
          style: BaseTypography.headlineLarge(color: AppColors.white).copyWith(letterSpacing: 1.2),
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(BaseRadius.xxxl)),
        boxShadow: BaseShadows.forLevel(BaseElevation.level4),
      ),
      child: Column(
        children: [
          SizedBox(height: BaseSpacing.md),

          // ── Tab toggle ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
            child: Container(
              padding: EdgeInsets.all(BaseSpacing.xxs),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(BaseRadius.lg),
                border: Border.all(color: AppColors.lightGrey2, width: 0.4),
              ),
              child: Row(
                children: [
                  _TabButton(label: 'Sign In', index: 0, controller: controller),
                  _TabButton(label: 'Sign Up', index: 1, controller: controller),
                ],
              ),
            ),
          ),

          SizedBox(height: BaseSpacing.xxs),

          // ── Form area ──────────────────────────────────────────────────
          Expanded(
            child: Obx(
              () => AnimatedSwitcher(
                duration: BaseMotion.normal,
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
              ),
            ),
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
      child: Semantics(
        button: true,
        selected: controller.tabIndex.value == index,
        label: label,
        child: GestureDetector(
          onTap: () => controller.switchTab(index),
          child: Obx(() {
            final active = controller.tabIndex.value == index;
            return AnimatedContainer(
              duration: BaseMotion.normal,
              curve: BaseMotion.standard,
              constraints: const BoxConstraints(minHeight: 48),
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryColor : AppColors.transparent,
                borderRadius: BorderRadius.circular(BaseRadius.sm),
                boxShadow: active ? BaseShadows.forLevel(BaseElevation.level2) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: BaseTypography.bodySmall(
                  color: active ? AppColors.white : AppColors.grey,
                ).copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w500, fontSize: 14),
              ),
            );
          }),
        ),
      ),
    );
  }
}
