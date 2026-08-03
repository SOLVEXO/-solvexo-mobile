import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/activity_log/activity_log_model.dart';
import 'package:book_store_app/app/modules/seller_activity_log/widgets/activity_log_tile.dart';
import 'package:book_store_app/app/modules/seller_store_banners/controllers/seller_store_banners_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Read-only activity timeline for a single banner — reuses
/// [ActivityLogTile] from the seller activity log module so entries render
/// identically everywhere they're surfaced.
class StoreBannerTimelineSheet extends StatelessWidget {
  final SellerStoreBannersController controller;
  final String bannerId;

  const StoreBannerTimelineSheet({super.key, required this.controller, required this.bannerId});

  static void show(BuildContext context, SellerStoreBannersController controller, String bannerId) {
    Get.bottomSheet(
      StoreBannerTimelineSheet(controller: controller, bannerId: bannerId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: BaseSpacing.sm),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.md, BaseSpacing.lg, BaseSpacing.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      text: 'Banner Activity',
                      color: AppColors.black2,
                      fontSize: AppFontSize.small2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<ActivityLogModel>>(
                    future: controller.loadTimeline(bannerId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                      }
                      final logs = snapshot.data ?? const [];
                      if (logs.isEmpty) {
                        return Center(
                          child: CustomText(
                            text: 'No activity recorded for this banner yet.',
                            color: AppColors.gray600,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(BaseSpacing.lg, 0, BaseSpacing.lg, BaseSpacing.lg),
                        itemCount: logs.length,
                        itemBuilder: (_, i) => ActivityLogTile(log: logs[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
