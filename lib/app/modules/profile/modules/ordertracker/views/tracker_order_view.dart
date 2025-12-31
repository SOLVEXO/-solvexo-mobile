import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/modules/ordertracker/controllers/order_tracker_controller.dart';
import 'package:book_store_app/app/modules/profile/modules/ordertracker/widgets/tracking_tile.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackOrderView extends StatelessWidget {
  TrackOrderView({super.key});

  final controller = Get.put(OrderTrackerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Track Order"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final items = controller.visibleEvents;

          return Column(
            children: [
              /// Courier Info
              ListTile(
                leading: SvgIcon(assetName: AppIcons.dhlLogo, size: 40),
                title: CustomText(
                  text: "DHL Standard Shipping",
                  fontSize: AppFontSize.regular,
                  fontWeight: FontWeight.w600,
                ),
                subtitle: Row(
                  spacing: 5,
                  children: [
                    CustomText(
                      text: "7256227111",
                      fontSize: AppFontSize.small,
                      color: AppColors.primaryColor,
                    ),
                    Icon(Icons.copy, size: 18, color: AppColors.primaryColor),
                  ],
                ),
              ),
              Divider(color: AppColors.background, thickness: 3),

              const SizedBox(height: 16),

              /// Timeline
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    return TrackingTile(
                      event: items[i],
                      isLast: i == items.length - 1,
                    );
                  },
                ),
              ),

              /// Show more / less
              AppButton(
                isOutlined: true,
                textColor: AppColors.primaryColor,
                onPressed: controller.toggleShow,
                label: controller.showAll.value ? "Show less" : "Show more",
              ),
            ],
          );
        }),
      ),
    );
  }
}
