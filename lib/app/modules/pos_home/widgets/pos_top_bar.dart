import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class PosTopBar extends StatelessWidget {
  final PosHomeController c;
  const PosTopBar({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(children: [
        Expanded(
          child: CustomTextField(
            controller: c.searchController,
            onChanged: c.onSearchChanged,
            hintText: 'Search products or scan barcode (SKU)...',
            fillColor: AppColors.background,
            isborder: true,
          ),
        ),
        const SizedBox(width: 8),
        _PosBarButton(
          icon: Icons.qr_code_scanner_rounded,
          label: 'Scan',
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _PosBarButton(
          icon: Icons.add_rounded,
          label: 'Custom Item',
          onTap: () {},
          filled: true,
        ),
      ]),
    );
  }
}

class _PosBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _PosBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: filled ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: filled ? AppColors.primaryColor : AppColors.lightGrey2,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: filled ? AppColors.white : AppColors.black2),
          const SizedBox(width: 6),
          CustomText(
            text: label,
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w500,
            color: filled ? AppColors.white : AppColors.black2,
          ),
        ]),
      ),
    );
  }
}
