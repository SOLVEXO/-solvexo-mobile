import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/seller_onboarding/controllers/seller_onboarding_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step1AccountForm extends StatelessWidget {
  final SellerOnboardingController controller;

  const Step1AccountForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomText(
            text: 'Create your free account',
            fontSize: AppFontSize.large,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            textAlign: TextAlign.center,
          ),
          const CustomText(
            text: 'Commerce. Solved. — Start selling in minutes.',
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
            textAlign: TextAlign.center,
          ),
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First + Last name row
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'First Name',
                        ctrl: controller.firstNameCtrl,
                        hint: 'Alex',
                        onChanged: (v) => controller.firstName.value = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Last Name',
                        ctrl: controller.lastNameCtrl,
                        hint: 'Chen',
                        onChanged: (v) => controller.lastName.value = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Email Address',
                  ctrl: controller.emailCtrl,
                  hint: 'alex@example.com',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => controller.email.value = v,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => _Field(
                    label: 'Password',
                    ctrl: controller.passwordCtrl,
                    hint: 'Minimum 8 characters',
                    obscure: !controller.passwordVisible.value,
                    onChanged: (v) => controller.password.value = v,
                    suffix: GestureDetector(
                      onTap: () => controller.passwordVisible.toggle(),
                      child: Icon(
                        controller.passwordVisible.value
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 20,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CountryField(controller: controller),
                const SizedBox(height: 20),
                _Divider(),
                const SizedBox(height: 16),
                _SocialRow(),
                const SizedBox(height: 20),
                _TermsNote(),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Reusable field wrapper ────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final void Function(String) onChanged;
  final Widget? suffix;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.onChanged,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black2,
        ),
        const SizedBox(height: 6),
        CustomTextField(
          controller: ctrl,
          onChanged: onChanged,
          hintText: hint,
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          obscureText: obscure,
          keyboardType: keyboardType,
          suffixIcon: suffix,
        ),
      ],
    );
  }
}

// ── Country field ─────────────────────────────────────────────────────────────

class _CountryField extends StatelessWidget {
  final SellerOnboardingController controller;

  const _CountryField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Country',
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black2,
        ),
        const SizedBox(height: 6),
        Obx(
          () => GestureDetector(
            onTap: controller.pickCountry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.textfldFillColor,
                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                border: Border.all(color: AppColors.lightGrey, width: 0.3),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: controller.country.value,
                      fontSize: AppFontSize.verySmall,
                      color: AppColors.black,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── "or continue with" divider ────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.lightGrey2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CustomText(
            text: 'or continue with',
            fontSize: AppFontSize.tiny,
            color: AppColors.grey,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.lightGrey2)),
      ],
    );
  }
}

// ── Social buttons ────────────────────────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SocialBtn(label: 'Google', emoji: 'G', color: AppColors.red),
        const SizedBox(width: 10),
        _SocialBtn(label: 'Apple', emoji: '🍎', color: AppColors.black),
        const SizedBox(width: 10),
        _SocialBtn(
          label: 'Facebook',
          emoji: 'f',
          color: AppColors.facebookBlue,
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;

  const _SocialBtn({
    required this.label,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            border: Border.all(color: AppColors.lightGrey2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 5),
              CustomText(
                text: label,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Terms note ────────────────────────────────────────────────────────────────

class _TermsNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 11, color: AppColors.grey),
        children: [
          const TextSpan(text: 'By signing up you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── White form card wrapper ───────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppDimen.serviceCountTileRadius + 4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
