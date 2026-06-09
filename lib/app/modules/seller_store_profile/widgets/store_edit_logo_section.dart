import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreEditLogoSection extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreEditLogoSection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Row(children: [
        Obx(() {
          final hasFile = c.logoFile.value != null;
          final logoUrl = c.store.value?.logo ?? '';
          final hasUrl  = logoUrl.isNotEmpty;
          return GestureDetector(
            onTap: c.pickLogo,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (hasFile || hasUrl)
                    ? Colors.transparent
                    : AppColors.background,
                borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: (hasFile || hasUrl)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                      child: CommonImageView(
                        file: hasFile ? c.logoFile.value : null,
                        url:  hasFile ? null : logoUrl,
                        fit:   BoxFit.cover,
                        width:  72,
                        height: 72,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: AppColors.primaryColor,
                    ),
            ),
          );
        }),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const CustomText(
              text: 'Store Logo',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            const SizedBox(height: 4),
            const CustomText(
              text: 'PNG or JPG · min 200×200px',
              fontSize: AppFontSize.tiny,
              color: AppColors.grey,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: c.pickLogo,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(() => CustomText(
                  text: (c.logoFile.value != null || (c.store.value?.logo.isNotEmpty ?? false))
                      ? 'Change Photo'
                      : 'Upload Photo',
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                )),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
);
