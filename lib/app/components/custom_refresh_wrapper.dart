import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/comp_controllers/refresh_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
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
                child: Obx(() {
                  final pull = refreshController.pullDistance.value.clamp(
                    0,
                    120,
                  );
                  final progress = (pull / 100).clamp(0.0, 1.0);

                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: pull.toDouble()),
                    curve: Curves.elasticOut, // 🔥 elastic bounce
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, value * 0.4), // 👈 elastic drop
                        child: Transform.scale(
                          scale: 0.7 + (progress * 0.3), // 👈 grow effect
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                /// 🔥 GRADIENT LOADER RING
                                if (refreshController.isRefreshing.value ||
                                    progress > 0)
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(seconds: 1),
                                    builder: (context, _, __) {
                                      return ShaderMask(
                                        shaderCallback: (rect) {
                                          return SweepGradient(
                                            startAngle: 0,
                                            endAngle: 6.3,
                                            colors: [
                                              AppColors.primaryColor,
                                              AppColors.secondryColor,
                                              AppColors.accentColor,
                                              AppColors.secondryColor,
                                              AppColors.primaryColor,
                                            ],
                                            stops: const [
                                              0.0,
                                              0.4,
                                              0.6,
                                              0.8,
                                              1.0,
                                            ],
                                          ).createShader(rect);
                                        },
                                        child: SizedBox(
                                          height: 80,
                                          width: 80,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            value:
                                                refreshController
                                                    .isRefreshing
                                                    .value
                                                ? null
                                                : progress,
                                            color: AppColors
                                                .background, // masked by gradient
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                Container(
                                  height: 48,
                                  width: 48,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CommonImageView(
                                    imagePath: AppImages.logoImage,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}
