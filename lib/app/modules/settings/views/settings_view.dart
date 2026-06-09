import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/settings/controllers/settings_controller.dart';
import 'package:book_store_app/app/modules/settings/widgets/settings_profile_card.dart';
import 'package:book_store_app/app/modules/settings/widgets/settings_section_widget.dart';
import 'package:book_store_app/app/modules/settings/widgets/settings_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Settings'),
      body: Obx(() {
        if (controller.isLoading.value) return const SettingsShimmer();

        return CustomRefreshWrapper(
          onRefresh: controller.refreshData,
          child: ListView(
            padding: const EdgeInsets.only(
              top: AppDimen.allPadding,
              bottom: AppDimen.allPadding,
            ),
            children: [
              SettingsProfileCard(controller: controller),
              const SizedBox(height: 24),
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
    );
  }
}
