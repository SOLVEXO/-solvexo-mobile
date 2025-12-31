import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFloatingButton extends StatelessWidget {
  CustomFloatingButton({super.key});
  final controller = Get.find<CategoryController>();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      height: h / 12,
      width: w / 2,
      child: Row(
        children: [
          Expanded(child: customRow(AppIcons.filterIcon, "Filters", context)),
          VerticalDivider(
            color: AppColors.lightGrey,
            thickness: 0.5,
            indent: 20,
            endIndent: 20,
          ),
          Expanded(child: customRow(AppIcons.sortIcon, "Sort", context)),
        ],
      ),
    );
  }

  Widget customRow(String icon, String text, context) {
    return GestureDetector(
      onTap: () {
        controller.bottomsheet(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          SvgIcon(assetName: icon, color: AppColors.black),
          CustomText(text: text),
        ],
      ),
    );
  }
}
