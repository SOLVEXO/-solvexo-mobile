import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';

class CustomPinCodeField extends StatelessWidget {
  final String? fieldText;
  final String? hintText, label;
  final bool isFinal;
  final bool enabled;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final int limit;
  final String filteringRegex;
  final int maxLines;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onComplete;
  final bool isPassword;
  final bool isCaps;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final Color labelColor;
  final double labelFontSize;

  final String? suffixIcon;
  final String? prefixIcon;

  final void Function()? suffixIconOnTap;

  final double suffixConstraint;
  final double prefixConstraint;

  const CustomPinCodeField({
    super.key,
    this.fieldText,
    this.hintText,
    this.isFinal = false,
    this.readOnly = false,
    this.validator,
    this.enabled = true,
    this.label,
    this.isCaps = false,
    this.onChanged,
    this.onTap,
    this.onComplete,
    this.isPassword = false,
    this.limit = 100,
    this.filteringRegex = "",
    this.maxLines = 1,
    this.focusNode,
    this.nextFocusNode,
    this.controller,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.labelColor = AppColors.black,
    this.labelFontSize = AppFontSize.extraSmall,
    this.suffixConstraint = 10,
    this.prefixConstraint = 10,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixIconOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      controller: controller,
      length: 6,
      keyboardType: TextInputType.number,
      showCursor: false,
      hintCharacter: "-",
      autoFocus: true,
      enablePinAutofill: false,
      enableActiveFill: true,
      validator: validator,
      autovalidateMode: AutovalidateMode.disabled,
      onCompleted: onComplete,
      pinTheme: PinTheme(
        borderWidth: 1,
        activeBorderWidth: 1,
        selectedBorderWidth: 1,
        inactiveBorderWidth: 1,
        disabledBorderWidth: 1,

        activeFillColor: AppColors.white,
        inactiveFillColor: AppColors.white,
        selectedFillColor: AppColors.white,
        inactiveColor: AppColors.white,
        activeColor: AppColors.white,
        selectedColor: AppColors.white,

        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        fieldHeight: 50,
        fieldWidth: 50,
      ),
      textStyle: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: AppFontSize.small,
        color: AppColors.black,
      ),
    );
  }
}
