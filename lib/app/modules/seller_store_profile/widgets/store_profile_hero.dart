import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreProfileHero extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreProfileHero({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top > 0 ? 20 : 30,
        20,
        52,
      ),
      decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
      child: Obx(() {
        final s = c.store.value;
        final logoUrl = s?.logo ?? '';
        return Column(children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: AppColors.appbarGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: logoUrl.isEmpty
                ? CustomText(
                    text: c.initials,
                    fontSize: AppFontSize.large,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  )
                : ClipOval(
                    child: CommonImageView(
                      url: logoUrl,
                      fit: BoxFit.cover,
                      width: 84,
                      height: 84,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          CustomText(
            text: s?.name ?? '',
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            StorePill(
              label: s?.categoryId ?? '',
              bgColor: AppColors.white.withOpacity(0.18),
              textColor: AppColors.white,
              icon: Icons.category_rounded,
            ),
            const SizedBox(width: 8),
            StorePill(
              label: 'Active',
              bgColor: AppColors.darkGreen.withOpacity(0.9),
              textColor: AppColors.white,
              icon: Icons.circle,
              iconSize: 7,
            ),
          ]),
        ]);
      }),
    );
  }
}

class StorePill extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData icon;
  final double iconSize;

  const StorePill({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.icon,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: iconSize, color: textColor),
        const SizedBox(width: 5),
        CustomText(text: label, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, color: textColor),
      ]),
    );
  }
}
