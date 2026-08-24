import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller/widgets/seller_app_bar.dart';
import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:book_store_app/app/modules/seller_settings/widgets/settings_profile_card.dart';
import 'package:book_store_app/app/modules/seller_settings/widgets/settings_section.dart';
import 'package:book_store_app/app/modules/seller_settings/widgets/settings_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerSettingsView extends StatelessWidget {
  SellerSettingsView({super.key});

  final SellerSettingsController controller = Get.put(
    SellerSettingsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SellerAppBar(title: 'Settings'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const SettingsShimmer();

              return CustomRefreshWrapper(
                onRefresh: controller.refreshData,
                child: ListView(
                  padding: EdgeInsets.only(bottom: Get.height / 8),
                  children: [
                    SettingsProfileCard(controller: controller),
                    ...controller.sections.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SettingsSectionWidget(section: s),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
