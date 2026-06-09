import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosCartHeader extends StatelessWidget {
  final PosHomeController c;
  const PosCartHeader({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.lightGrey2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CustomText(
            text: 'Current Sale',
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.bold,
            color: AppColors.black2,
          ),
          const Spacer(),
          _HeaderBtn(icon: Icons.person_outline_rounded, label: 'Customer', onTap: () {}),
          const SizedBox(width: 6),
          _HeaderBtn(icon: Icons.local_offer_outlined, label: 'Discount', onTap: () {}),
        ]),
        const SizedBox(height: 4),
        Obx(() => CustomText(
          text: '${c.itemCount} item${c.itemCount == 1 ? '' : 's'} · \$${c.subtotal.toStringAsFixed(2)} subtotal',
          fontSize: AppFontSize.tiny,
          color: AppColors.grey,
        )),
      ]),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.lightGrey2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppColors.grey),
          const SizedBox(width: 4),
          CustomText(text: label, fontSize: AppFontSize.tiny, color: AppColors.grey),
        ]),
      ),
    );
  }
}
