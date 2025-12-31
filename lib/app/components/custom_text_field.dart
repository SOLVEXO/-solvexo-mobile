import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:hifzpro_app/apptheme/app_colors.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final String? label;
  final int? maxLength;
  final int? maxLines;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? filled;
  final Color? fillColor;
  final Color color;
  final BorderRadiusGeometry? borderRadius;
  final bool ispadding;
  final bool isborder;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.filled = true,
    this.fillColor = Colors.white,
    this.borderRadius,
    this.ispadding = false,
    this.isborder = false,
    this.controller,
    this.onChanged,
    this.color = AppColors.white,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onFieldSubmitted,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Container(
      margin: ispadding ? EdgeInsets.only(bottom: 2) : null,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      child: TextFormField(
        onFieldSubmitted: onFieldSubmitted,
        maxLength: maxLength,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          prefixIconColor: AppColors.grey,
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.grey,
            fontSize: isTablet ? 18 : 14,
          ),
          hintText: "$hintText".tr,
          hintStyle: TextStyle(color: AppColors.grey),
          suffixIcon: suffixIcon,
          suffixIconColor: AppColors.grey,
          filled: filled,
          fillColor: fillColor,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: isTablet ? 20 : 16,
          ),
          enabledBorder: isborder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.lightGrey),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
          focusedBorder: isborder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.primaryColor),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
        ),
      ),
    );
  }
}
