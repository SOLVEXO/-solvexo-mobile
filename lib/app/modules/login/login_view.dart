import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey("signin"),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ─────────────────────────────────────────────────────
          const CustomText(
            text: 'Welcome back',
            fontSize: AppFontSize.veryLarge,
            fontWeight: FontWeight.w800,
            color: AppColors.black2,
          ),
          const SizedBox(height: 2),
          const CustomText(
            text: 'Sign in to continue to your account',
            fontSize: AppFontSize.small,
            color: AppColors.grey,
          ),

          const SizedBox(height: 14),

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

                const SizedBox(height: 8),

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
            child: TextButton(
              onPressed: () => Get.toNamed(Routes.forgetPasswordView),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const CustomText(
                text: 'Forgot Password?',
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: AppFontSize.verySmall,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Login button ──────────────────────────────────────────────────
          Obx(
            () => AppButton(
              label: authController.isLoading.value ? 'Signing In…' : 'Sign In',
              onPressed: authController.isLoading.value
                  ? null
                  : authController.login,
            ),
          ),

          const SizedBox(height: 14),

          // ── Divider ───────────────────────────────────────────────────────
          const AuthOrRow(),

          const SizedBox(height: 12),

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
        const SizedBox(width: 12),
        _SocialIcon(icon: AppIcons.facebookIcon, onTap: onFacebook),
        const SizedBox(width: 12),
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
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey2),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.white,
          ),
          child: Center(child: SvgIcon(assetName: icon, size: 22)),
        ),
      ),
    );
  }
}
