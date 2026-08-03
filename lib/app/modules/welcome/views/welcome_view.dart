import 'package:book_store_app/app/components/animated_background_circles.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/welcome/controllers/welcome_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WelcomeController>();
    return BaseViewScreen(
      useSafeArea: false,
      child: Stack(
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
                const _LogoSection(),
                _BottomSection(onSelectRole: controller.selectRole),
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
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 100,
          width: 100,
          padding: EdgeInsets.all(BaseSpacing.xxs + 1),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.xxl),
            boxShadow: BaseShadows.forLevel(BaseElevation.level4),
          ),
          child: CommonImageView(
            imagePath: AppImages.logoImage,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(BaseRadius.xxl),
          ),
        ),
        SizedBox(height: BaseSpacing.lg),
        CustomText(
          text: 'Solvexo',
          color: AppColors.white,
          fontFamily: AppTextStyles.headingFontFamily,
          fontSize: AppFontSize.veryLarge3,
          fontWeight: FontWeight.w800,
        ),
        SizedBox(height: BaseSpacing.xxs),
        CustomText(
          text: 'Commerce. Solved.',
          color: AppColors.white.withOpacity(0.8),
          fontSize: AppFontSize.extraSmall,
        ),
        SizedBox(height: BaseSpacing.xxs - 2),
        CustomText(
          text: 'Buy, sell, and grow — all in one place.',
          textAlign: TextAlign.center,
          color: AppColors.white.withOpacity(0.65),
          fontSize: AppFontSize.tiny,
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
      padding: EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        BaseSpacing.xl,
        AppDimen.allPadding,
        BaseSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.xxxl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'How would you like to use Solvexo?',
            color: AppColors.black,
            fontFamily: AppTextStyles.headingFontFamily,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: BaseSpacing.xxs),
          CustomText(
            text: 'You can switch anytime from your profile settings.',
            color: AppColors.grey,
            fontSize: AppFontSize.tiny,
          ),
          SizedBox(height: BaseSpacing.xl),
          _RoleCard(
            emoji: AppIcons.cartIcon,
            title: 'I\'m a Buyer',
            subtitle: 'Browse, discover and purchase products',
            isPrimary: false,
            onTap: () => onSelectRole('user'),
          ),
          SizedBox(height: BaseSpacing.sm),
          _RoleCard(
            emoji: AppIcons.cashIcon,
            title: 'I\'m a Seller',
            subtitle: 'Create a store and start selling today',
            isPrimary: true,
            onTap: () => onSelectRole('seller'),
          ),
          SizedBox(height: BaseSpacing.md),
          Center(
            child: CustomText(
              text: 'By continuing you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              color: AppColors.lightGrey5,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w400,
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
    return Semantics(
      button: true,
      label: '$title — $subtitle',
      child: PressableScale(
        onTap: onTap,
        child: ConstrainedBox(
          // Enforce the 48px minimum touch target regardless of content height.
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSpacing.md + 2,
              vertical: BaseSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primaryColor : AppColors.background,
              borderRadius: BorderRadius.circular(
                AppDimen.serviceCountTileRadius,
              ),
              border: Border.all(
                color: isPrimary
                    ? AppColors.primaryColor
                    : AppColors.lightGrey2,
                width: isPrimary ? 0 : 1,
              ),
              boxShadow: isPrimary
                  ? BaseShadows.glow(AppColors.primaryColor)
                  : BaseShadows.none,
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
                    borderRadius: BorderRadius.circular(BaseRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: SvgIcon(
                    assetName: emoji,
                    size: 30,
                    color: isPrimary
                        ? AppColors.white10
                        : AppColors.barrierColor,
                  ),
                ),
                SizedBox(width: BaseSpacing.md - 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        color: isPrimary ? AppColors.white : AppColors.black,
                        fontSize: AppFontSize.verySmall,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: BaseSpacing.xxs / 2),
                      CustomText(
                        text: subtitle,
                        color: isPrimary
                            ? AppColors.white.withOpacity(0.8)
                            : AppColors.grey,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w400,
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
        ),
      ),
    );
  }
}
