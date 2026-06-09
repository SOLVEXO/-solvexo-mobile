import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreEditSaveBar extends StatelessWidget {
  final SellerStoreProfileController c;
  final double bottomInset;

  const StoreEditSaveBar({super.key, required this.c, required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 12, AppDimen.allPadding, 12 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: GestureDetector(
        onTap: c.canSave && !c.isSaving.value ? c.save : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: c.canSave ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.38),
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          ),
          alignment: Alignment.center,
          child: c.isSaving.value
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_rounded, color: AppColors.white, size: 18),
                  SizedBox(width: 8),
                  CustomText(text: 'Save Changes', fontSize: AppFontSize.small2, fontWeight: FontWeight.w600, color: AppColors.white),
                ]),
        ),
      ),
    ));
  }
}
