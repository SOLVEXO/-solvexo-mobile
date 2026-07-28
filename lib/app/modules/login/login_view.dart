import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return SingleChildScrollView(
      key: const PageStorageKey("signin"),
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Form ─────────────────────────────────────────────────────────
          Form(
            key: authController.loginFormKey,
            child: Column(
              children: [
                _LabeledField(
                  label: 'Phone or email',
                  child: CustomTextField(
                    prefixIcon: SvgIcon(
                      assetName: AppIcons.emailIcon,
                      color: AppColors.gray600,
                    ),
                    controller: authController.loginEmailController,
                    hintText: 'Enter your phone or email.',
                    isborder: true,
                    fillColor: AppColors.white,
                    filled: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: authController.validateEmail,
                  ),
                ),

                SizedBox(height: BaseSpacing.sm),

                _LabeledField(
                  label: 'Password',
                  child: Obx(
                    () => CustomTextField(
                      hintText: '* * * * *',
                      prefixIcon: SvgIcon(
                        assetName: AppIcons.lockPassword,
                        color: AppColors.gray600,
                      ),
                      isborder: true,
                      fillColor: AppColors.white,
                      filled: true,
                      controller: authController.loginPasswordController,
                      obscureText: !authController.isPasswordVisible.value,
                      validator: authController.validatePassword,
                      suffixIcon: SvgIcon(
                        assetName: authController.isPasswordVisible.value
                            ? AppIcons.hidePassword
                            : AppIcons.showPassword,
                        color: AppColors.grey,
                        size: 22,
                        onTap: authController.togglePasswordVisibility,
                      ),
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
              label: 'Forgot password?',
              onPressed: () => Get.toNamed(Routes.forgetPasswordView),
            ),
          ),

          // ── Login button ──────────────────────────────────────────────────
          Obx(
            () => PrimaryButton(
              label: authController.isLoading.value ? 'Signing In…' : 'Log in',
              isLoading: authController.isLoading.value,
              onPressed: authController.isLoading.value
                  ? null
                  : authController.login,
            ),
          ),

          SizedBox(height: BaseSpacing.lg),

          // ── Divider ───────────────────────────────────────────────────────
          const AuthOrRow(label: 'or continue with'),

          SizedBox(height: BaseSpacing.md),

          // ── Social buttons ──────────────────────────────────────────────
          Obx(
            () => _SocialRow(
              onGoogle: authController.signInWithGoogle,
              onFacebook: authController.signInWithFacebook,
              onApple: authController.signInWithApple,
              isBusy: authController.isSocialLoading.value,
              activeProvider: authController.activeSocialProvider.value,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label-above field, matching the flat marketplace form style ─────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: AppColors.black2,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: BaseSpacing.xxs + 2),
        child,
      ],
    );
  }
}

// ── Social sign-in row — outlined pill buttons with icon + label ────────────

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.onGoogle,
    required this.onFacebook,
    required this.onApple,
    required this.isBusy,
    required this.activeProvider,
  });
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback onApple;
  final bool isBusy;
  final String activeProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialButton(
          icon: AppIcons.googleIcon,
          label: 'Google',
          onTap: onGoogle,
          disabled: isBusy,
          isLoading: activeProvider == 'google',
        ),
        SizedBox(width: BaseSpacing.sm),
        _SocialButton(
          icon: AppIcons.facebookIcon,
          label: 'Facebook',
          onTap: onFacebook,
          disabled: isBusy,
          isLoading: activeProvider == 'facebook',
        ),
        SizedBox(width: BaseSpacing.sm),
        _SocialButton(
          icon: AppIcons.appleIcon,
          label: 'Apple',
          onTap: onApple,
          disabled: isBusy,
          isLoading: activeProvider == 'apple',
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
    this.isLoading = false,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Opacity(
          opacity: disabled && !isLoading ? 0.5 : 1,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey2),
              borderRadius: BorderRadius.circular(BaseRadius.md),
              color: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isLoading
                  ? [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ]
                  : [
                      SvgIcon(assetName: icon, size: 18),
                      SizedBox(width: BaseSpacing.xxs + 1),
                      Flexible(
                        child: CustomText(
                          text: label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.black2,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
