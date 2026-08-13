import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

/// Shared visual helpers for the verification form's cards — kept in one
/// place since `verification_business_section.dart` and
/// `verification_contact_section.dart` both need identical field chrome.

BoxDecoration verificationCardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [
    BoxShadow(
      color: AppColors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);

class VerificationSectionTitle extends StatelessWidget {
  final String text;
  const VerificationSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => CustomText(
    text: text,
    fontSize: AppFontSize.tiny,
    fontWeight: FontWeight.w700,
    color: AppColors.grey,
    letterSpacing: 0.8,
  );
}

class VerificationFieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const VerificationFieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomText(
          text: text,
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black2,
        ),
        if (required)
          const CustomText(
            text: ' *',
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w600,
            color: AppColors.red,
          ),
      ],
    );
  }
}

/// A [CustomTextField] that dims and stops accepting input when [enabled]
/// is false — `CustomTextField` itself has no such flag, so this wraps it.
class VerificationTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;

  const VerificationTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: CustomTextField(
          controller: controller,
          hintText: hintText,
          isborder: true,
          fillColor: AppColors.textfldFillColor,
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}

/// A tappable dropdown-styled field — used for the business type / ID
/// document type pickers (bottom sheets live on the controller).
class VerificationPickerField extends StatelessWidget {
  final String displayValue;
  final String placeholder;
  final bool enabled;
  final VoidCallback onTap;

  const VerificationPickerField({
    super.key,
    required this.displayValue,
    required this.placeholder,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.textfldFillColor,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            border: Border.all(color: AppColors.lightGrey, width: 0.3),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  text: displayValue.isEmpty ? placeholder : displayValue,
                  fontSize: AppFontSize.verySmall,
                  color: displayValue.isEmpty
                      ? AppColors.grey
                      : AppColors.black,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
