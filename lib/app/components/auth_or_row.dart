import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class AuthOrRow extends StatelessWidget {
  const AuthOrRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.textPrimary, thickness: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CustomText(
            text: "Or continue with email",
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.textPrimary, thickness: 0.5),
        ),
      ],
    );
  }
}
