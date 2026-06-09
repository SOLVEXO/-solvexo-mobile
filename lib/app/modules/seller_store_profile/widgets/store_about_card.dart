import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreAboutCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreAboutCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: _cardDeco(),
        child: Obx(() {
          final desc = c.store.value?.description ?? '';
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CustomText(
              text: 'ABOUT THE STORE',
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
              letterSpacing: 0.8,
            ),
            const SizedBox(height: 10),
            CustomText(
              text: desc.isEmpty ? 'No description added yet.' : desc,
              fontSize: AppFontSize.verySmall,
              color: desc.isEmpty ? AppColors.lightGrey5 : AppColors.black2,
              height: 1.55,
            ),
          ]);
        }),
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
);
