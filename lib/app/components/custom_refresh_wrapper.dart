import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/comp_controllers/refresh_controller.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  CustomRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final refreshController = Get.put(RefreshControllerX());

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll is OverscrollNotification) {
          // ✅ Only allow TOP overscroll (pull-down)
          if (scroll.overscroll < 0) {
            refreshController.updatePull(scroll.overscroll.abs());

            if (refreshController.pullDistance.value > 100) {
              refreshController.handleRefresh(onRefresh);
            }
          }
        }

        if (scroll is ScrollEndNotification) {
          refreshController.resetPull();
        }

        return false;
      },
      child: Stack(
        children: [
          child,

          /// 🔥 Custom Logo Loader
          Obx(() {
            if (refreshController.pullDistance.value <= 0 &&
                !refreshController.isRefreshing.value) {
              return const SizedBox();
            }

            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: refreshController.isRefreshing.value
                        ? 50
                        : refreshController.pullDistance.value.clamp(0, 70),
                    child: CommonImageView(
                      imagePath: AppImages.logoImage,
                      radius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
