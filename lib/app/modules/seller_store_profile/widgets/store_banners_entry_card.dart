import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Entry point tile navigating to the free storefront hero carousel screen
/// (`/seller/store-banners`) — a sibling module to this profile screen, kept
/// separate since banners have their own list+CRUD lifecycle.
class StoreBannersEntryCard extends StatelessWidget {
  const StoreBannersEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.sellerStoreBanners),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: _cardDeco(),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.view_carousel_outlined, size: 18, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Storefront Banners',
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black2,
                    ),
                    SizedBox(height: 2),
                    CustomText(
                      text: 'Manage your hero carousel',
                      fontSize: AppFontSize.tiny,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey5),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      boxShadow: [
        BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    );
