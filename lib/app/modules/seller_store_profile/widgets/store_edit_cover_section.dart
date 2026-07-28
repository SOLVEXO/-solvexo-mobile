import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreEditCoverSection extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreEditCoverSection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Store Cover Image',
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          const SizedBox(height: 4),
          const CustomText(
            text: 'Shown at the top of your store profile · 1200×400px',
            fontSize: AppFontSize.tiny,
            color: AppColors.grey,
          ),
          const SizedBox(height: 10),
          Obx(() {
            final hasFile = c.coverFile.value != null;
            final coverUrl = c.store.value?.coverImage ?? '';
            final hasUrl = coverUrl.isNotEmpty;
            return GestureDetector(
              onTap: c.pickCoverImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: (hasFile || hasUrl)
                      ? Colors.transparent
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(
                    AppDimen.serviceCountTileRadius,
                  ),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: (hasFile || hasUrl)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CommonImageView(
                            file: hasFile ? c.coverFile.value : null,
                            url: hasFile ? null : coverUrl,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const CustomText(
                                text: 'Change',
                                fontSize: AppFontSize.tiny,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 28,
                        color: AppColors.primaryColor,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [
    BoxShadow(
      color: AppColors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);
