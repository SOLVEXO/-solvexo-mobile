import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_profile_details.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_user_greeting.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_hero.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_stats_strip.dart';
import 'package:book_store_app/app/modules/settings/widgets/settings_section_widget.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/base/base_view.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends BaseView<ProfileController> {
  const ProfileView({super.key});

  // `ProfileView` is embedded directly as a bottom-nav tab, not only
  // reached via `Routes.profileView`'s `ProfileBinding` — self-registering
  // keeps it working either way, matching the original
  // `Get.put(ProfileController())` field-initializer behaviour.
  @override
  ProfileController get controller {
    if (!Get.isRegistered<ProfileController>()) Get.put(ProfileController());
    return Get.find<ProfileController>();
  }

  @override
  Color? get backgroundColor => AppColors.background;

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _LoadingBody();

      return CustomRefreshWrapper(
        onRefresh: controller.refreshProfile,
        child: SingleChildScrollView(
          child: Column(children: [
            ProfileHero(controller: controller),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(children: [
                  const SizedBox(height: 20),
                  ProfileStatsStrip(controller: controller),
                  const SizedBox(height: 24),
                  ...controller.sections.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: SettingsSectionWidget(section: s),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
    });
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(children: [
        Container(
          height: topPad + 200,
          decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimen.allPadding),
          child: Column(children: [
            const SizedBox(height: 8),
            ShimmerUserGreeting(),
            const SizedBox(height: 16),
            ShimmerProfileDetails(),
          ]),
        ),
      ]),
    );
  }
}
