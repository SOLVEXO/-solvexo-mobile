import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_stores/controllers/seller_stores_controller.dart';
import 'package:book_store_app/app/modules/seller_stores/widgets/stores_profile_section.dart';
import 'package:book_store_app/app/modules/seller_stores/widgets/stores_stats_strip.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoresHeroHeader extends StatelessWidget {
  final SellerStoresController controller;

  const StoresHeroHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SvgIcon(
                assetName: AppIcons.logoutIcon,
                onTap: () {
                  AppPreferences.clearAccessToken();
                  Get.offAndToNamed(Routes.welcome);
                },
                color: AppColors.white,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 20),
          StoresProfileSection(controller: controller),
          const SizedBox(height: 28),
          StoresStatsStrip(controller: controller),
        ],
      ),
    );
  }
}
