import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/profile_tile.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_profile_details.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_user_greeting.dart';
import 'package:book_store_app/app/components/shimmer/trip_shimmer.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_bar.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomRefreshWrapper(
          onRefresh: () => controller.refreshProfile(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: AppDimen.borderRadius,
            ),
            child: Obx(
              () => Column(
                spacing: controller.isLoading.value ? 30 : 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => controller.isLoading.value
                        ? ShimmerUserGreeting()
                        : ProfileBar(),
                  ),

                  Obx(
                    () => controller.isLoading.value
                        ? ShimmerProfileDetails()
                        : ProfileCard(),
                  ),
                  Obx(
                    () => controller.isLoading.value
                        ? TripShimmer(itemCount: 3)
                        : Expanded(
                            child: Scrollbar(
                              thumbVisibility: true,
                              thickness: 4,
                              radius: const Radius.circular(10),
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: ClampingScrollPhysics(),
                                ),
                                itemCount: controller.options.length,
                                itemBuilder: (context, index) {
                                  final item = controller.options[index];
                                  final isLastItem =
                                      index == controller.options.length - 1;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0
                                          ? 0
                                          : AppDimen.bottomPadding,
                                    ),
                                    child: ProfileTile(
                                      onTap: () {
                                        isLastItem
                                            ? controller.logout()
                                            : Get.toNamed(
                                                item["ontap"] as String,
                                              );
                                      },
                                      iconName: item["icon"] as String,
                                      title: item["title"] as String,
                                      isSubTitle: true,
                                      subTitle: item["subtitle"] as String,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
