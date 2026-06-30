import 'package:book_store_app/app/components/animated_background_circles.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  Future<void> _selectRole(String role) async {
    await AppPreferences.saveIntentRole(role);
    Get.offAllNamed(Routes.authTabView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
          ),
          const AnimatedBackgroundCircles(),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LogoSection(),
                _BottomSection(onSelectRole: _selectRole),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo + branding ───────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // width: 100,
          // height: 100,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CommonImageView(imagePath: AppImages.logoImage),
        ),
        const SizedBox(height: 20),
        const CustomText(
          text: 'Solvexo',
          fontSize: AppFontSize.veryLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        const SizedBox(height: 8),
        CustomText(
          text: 'Commerce. Solved.',
          fontSize: AppFontSize.small2,
          color: AppColors.white.withOpacity(0.8),
          fontWeight: FontWeight.w400,
        ),
        const SizedBox(height: 6),
        CustomText(
          text: 'Buy, sell, and grow — all in one place.',
          fontSize: AppFontSize.verySmall,
          color: AppColors.white.withOpacity(0.65),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Role selection buttons ─────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  final Future<void> Function(String role) onSelectRole;

  const _BottomSection({required this.onSelectRole});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      padding: const EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        28,
        AppDimen.allPadding,
        32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'How would you like to use Solvexo?',
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: 'You can switch anytime from your profile settings.',
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
          ),
          const SizedBox(height: 24),
          _RoleCard(
            emoji: AppIcons.cartIcon,
            title: 'I\'m a Buyer',
            subtitle: 'Browse, discover and purchase products',
            isPrimary: false,
            onTap: () => onSelectRole('user'),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            emoji: AppIcons.cashIcon,
            title: 'I\'m a Seller',
            subtitle: 'Create a store and start selling today',
            isPrimary: true,
            onTap: () => onSelectRole('seller'),
          ),
          const SizedBox(height: 16),
          Center(
            child: CustomText(
              text: 'By continuing you agree to our Terms & Privacy Policy',
              fontSize: AppFontSize.tiny,
              color: AppColors.lightGrey5,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(
            color: isPrimary ? AppColors.primaryColor : AppColors.lightGrey2,
            width: isPrimary ? 0 : 1,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppColors.white.withOpacity(0.2)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: SvgIcon(
                assetName: emoji,
                size: 30,
                color: isPrimary ? AppColors.white10 : AppColors.barrierColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? AppColors.white : AppColors.black,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: subtitle,
                    fontSize: AppFontSize.tiny,
                    color: isPrimary
                        ? AppColors.white.withOpacity(0.8)
                        : AppColors.grey,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isPrimary
                  ? AppColors.white.withOpacity(0.8)
                  : AppColors.lightGrey5,
            ),
          ],
        ),
      ),
    );
  }
}
