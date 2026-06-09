import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_about_card.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_contact_card.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_edit_form_card.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_edit_logo_section.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_edit_save_bar.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_meta_card.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_profile_hero.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_profile_shimmer.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_stats_strip.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStoreProfileView extends StatelessWidget {
  SellerStoreProfileView({super.key});

  final SellerStoreProfileController c = Get.put(
    SellerStoreProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBarTwo(
          title: 'Store Profile',
          actions: [
            if (!c.isEditing.value)
              GestureDetector(
                onTap: c.startEditing,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcon(
                        assetName: AppIcons.editIcon,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 5),
                      CustomText(
                        text: 'Edit',
                        fontSize: AppFontSize.verySmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: c.cancelEditing,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.lightGrey2),
                  ),
                  child: const CustomText(
                    text: 'Cancel',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                ),
              ),
          ],
        ),
        body: c.isLoading.value
            ? const StoreProfileShimmer()
            : c.isEditing.value
                ? _EditBody(c: c)
                : _ProfileBody(c: c),
        bottomNavigationBar: c.isEditing.value
            ? StoreEditSaveBar(
                c: c,
                bottomInset: MediaQuery.of(context).padding.bottom,
              )
            : null,
      ),
    );
  }
}

// ── Profile body ──────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  final SellerStoreProfileController c;
  const _ProfileBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return CustomRefreshWrapper(
      onRefresh: () => c.refreshData(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StoreProfileHero(c: c),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    StoreStatsStrip(c: c),
                    const SizedBox(height: 16),
                    StoreAboutCard(c: c),
                    const SizedBox(height: 16),
                    StoreContactCard(c: c),
                    const SizedBox(height: 16),
                    StoreMetaCard(c: c),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit body ─────────────────────────────────────────────────────────────────

class _EditBody extends StatelessWidget {
  final SellerStoreProfileController c;
  const _EditBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoreEditLogoSection(c: c),
          const SizedBox(height: 16),
          StoreEditFormCard(c: c),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
