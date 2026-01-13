import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
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
    final controller = Get.find<HomeController>();
    final mapPickerController = Get.put(MapPickerController());

    return Container(
      color: AppColors.white,
      child: ListTile(
        leading: SvgIcon(
          assetName: AppIcons.locationIcon,
          color: AppColors.primaryColor,
          size: 40,
        ),
        title: CustomText(text: "Delivery to"),
        subtitle: CustomText(
          text: mapPickerController.selectedAddress.value,
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.w500,
        ),
        trailing: IconButton(
          onPressed: () => Get.toNamed(Routes.mapPickerView),
          icon: SvgIcon(assetName: AppIcons.mapsIcon),
        ),
      ),
    );
  }
}
