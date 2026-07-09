import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return SingleChildScrollView(
      key: const PageStorageKey("signin"),
      padding: EdgeInsets.fromLTRB(BaseSpacing.xl, BaseSpacing.xs, BaseSpacing.xl, BaseSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ─────────────────────────────────────────────────────
          Text('Welcome back', style: BaseTypography.headlineLarge(color: AppColors.black2)),
          SizedBox(height: BaseSpacing.xxs / 2),
          Text(
            'Sign in to continue to your account',
            style: BaseTypography.bodySmall(color: AppColors.grey),
          ),

          SizedBox(height: BaseSpacing.md),

          // ── Form ─────────────────────────────────────────────────────────
          Form(
            key: authController.loginFormKey,
            child: Column(
              children: [
                CustomTextField(
                  prefixIcon: SvgIcon(
                    assetName: AppIcons.emailIcon,
                    color: AppColors.gray600,
                  ),
                  controller: authController.loginEmailController,
                  hintText: 'Email or phone number',
                  isborder: true,
                  fillColor: AppColors.background,
                  filled: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: authController.validateEmail,
                ),

                SizedBox(height: BaseSpacing.xs),

                Obx(
                  () => CustomTextField(
                    hintText: 'Password',
                    isborder: true,
                    prefixIcon: SvgIcon(
                      assetName: AppIcons.lockPassword,
                      color: AppColors.gray600,
                    ),
                    fillColor: AppColors.background,
                    filled: true,
                    controller: authController.loginPasswordController,
                    obscureText: !authController.isPasswordVisible.value,
                    validator: authController.validatePassword,
                    suffixIcon: IconButton(
                      icon: SvgIcon(
                        assetName: authController.isPasswordVisible.value
                            ? AppIcons.hidePassword
                            : AppIcons.showPassword,
                        color: AppColors.grey,
                        size: 22,
                      ),
                      onPressed: authController.togglePasswordVisibility,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Forgot password ───────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: GhostButton(
              label: 'Forgot Password?',
              onPressed: () => Get.toNamed(Routes.forgetPasswordView),
            ),
          ),

          SizedBox(height: BaseSpacing.xs),

          // ── Login button ──────────────────────────────────────────────────
          Obx(
            () => PrimaryButton(
              label: authController.isLoading.value ? 'Signing In…' : 'Sign In',
              isLoading: authController.isLoading.value,
              onPressed: authController.isLoading.value ? null : authController.login,
            ),
          ),

          SizedBox(height: BaseSpacing.md),

          // ── Divider ───────────────────────────────────────────────────────
          const AuthOrRow(),

          SizedBox(height: BaseSpacing.sm),

          // ── Social icons ──────────────────────────────────────────────────
          _SocialRow(
            onGoogle: authController.signInWithGoogle,
            onFacebook: authController.signInWithFacebook,
            onApple: authController.signInWithApple,
          ),
        ],
      ),
    );
  }
}

// ── Compact horizontal social icons ───────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.onGoogle,
    required this.onFacebook,
    required this.onApple,
  });
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialIcon(icon: AppIcons.googleIcon, onTap: onGoogle),
        SizedBox(width: BaseSpacing.sm),
        _SocialIcon(icon: AppIcons.facebookIcon, onTap: onFacebook),
        SizedBox(width: BaseSpacing.sm),
        _SocialIcon(icon: AppIcons.appleIcon, onTap: onApple),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.onTap});
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48, // 48px minimum touch target
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey2),
            borderRadius: BorderRadius.circular(BaseRadius.md),
            color: AppColors.white,
          ),
          child: Center(child: SvgIcon(assetName: icon, size: 22)),
        ),
      ),
    );
  }
}
