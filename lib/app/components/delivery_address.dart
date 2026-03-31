import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/map_picker/controllers/mappicker_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryAddress extends StatelessWidget {
  const DeliveryAddress({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.find<HomeController>();
    final mapPickerController = Get.put(MapPickerController());

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.appbarGradient,
        // color: AppColors.primaryColor.with Opacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Obx(
        () => ListTile(
          onTap: () => Get.toNamed(Routes.mapPickerView),
          leading: SvgIcon(
            assetName: AppIcons.locationIcon,
            color: AppColors.white,
            size: 40,
          ),
          title: CustomText(
            text: "Delivery to",
            fontWeight: FontWeight.w500,
            color: AppColors.white10,
          ),
          subtitle: CustomText(
            text: mapPickerController.selectedAddress.value.isEmpty
                ? mapPickerController.currentAddress.value
                : mapPickerController.selectedAddress.value,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
          trailing: IconButton(
            onPressed: () => Get.toNamed(Routes.mapPickerView),
            icon: SvgIcon(assetName: AppIcons.mapsIcon, size: 30),
          ),
        ),
      ),
    );
  }
}
