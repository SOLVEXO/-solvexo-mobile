import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileStatsStrip extends StatelessWidget {
  final ProfileController controller;
  const ProfileStatsStrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(children: [
            _StatCell(value: user != null ? '—' : '0', label: 'Orders'),
            _vDivider(),
            _StatCell(value: '—', label: 'Wishlist'),
            _vDivider(),
            _StatCell(value: '—', label: 'Addresses'),
          ]),
        ),
      );
    });
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: AppColors.lightGrey2);
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CustomText(
          text: value,
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        const SizedBox(height: 2),
        CustomText(text: label, fontSize: AppFontSize.tiny, color: AppColors.grey),
      ]),
    );
  }
}
