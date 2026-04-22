import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatelessWidget {
  FilterBottomSheet({super.key});
  final c = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height / 2.5,
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// BRAND
          InkWell(
            onTap: () => _showBrandSelector(),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: "Brands",
                    fontSize: AppFontSize.small,
                  ),
                ),
                Text(
                  c.selectedBrand.value.isEmpty ? "" : c.selectedBrand.value,
                  style: TextStyle(color: Colors.grey),
                ),
                SvgIcon(assetName: AppIcons.chevronRight, size: 16),
              ],
            ),
          ),

          Divider(height: 30),

          /// PRICE RANGE TITLE
          CustomText(text: "Price Range", fontSize: AppFontSize.small),

          SizedBox(height: 20),

          /// PRICE INPUT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _priceBox(true),
              Text("—", style: TextStyle(fontSize: 22)),
              _priceBox(false),
            ],
          ),

          SizedBox(height: 8),

          /// SLIDER
          Obx(
            () => RangeSlider(
              min: c.minPrice.value,
              max: c.maxPrice.value,
              values: RangeValues(
                c.currentMinFilter.value,
                c.currentMaxFilter.value,
              ),
              onChanged: (v) {
                c.currentMinFilter.value = v.start;
                c.currentMaxFilter.value = v.end;
              },
              activeColor: Color(0xFF7a73ff),
              inactiveColor: Colors.grey.shade300,
            ),
          ),

          SizedBox(height: 12),

          /// Rating selector
          InkWell(
            onTap: () => _showRatingSelector(),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: "Customer Rating",
                    fontSize: AppFontSize.small,
                  ),
                ),
                if (c.selectedRating.value > 0)
                  CustomText(
                    text: "${c.selectedRating.value}+",
                    fontSize: AppFontSize.small,
                  ),
                SizedBox(width: 5),
                SvgIcon(assetName: AppIcons.chevronRight, size: 16),
              ],
            ),
          ),

          Divider(height: 30),
          SizedBox(height: 10),

          AppButton(
            label: 'Apply',
            onPressed: () {
              Get.back();
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _priceBox(bool isMin) {
    return Container(
      width: 120,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Obx(
        () => CustomText(
          text:
              "\$ ${isMin ? c.currentMinFilter.value.toInt() : c.currentMaxFilter.value.toInt()}",

          fontSize: 16,
        ),
      ),
    );
  }

  void _showBrandSelector() {
    Get.bottomSheet(
      Container(
        height: Get.height / 3.5,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: List.generate(
            c.brands.length,
            (i) => ListTile(
              onTap: () {
                c.selectedBrand.value = c.brands[i];
                Get.back();
              },
              title: CustomText(text: c.brands[i], fontSize: AppFontSize.small),
              trailing: SvgIcon(assetName: AppIcons.chevronRight, size: 15),
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingSelector() {
    Get.bottomSheet(
      Container(
        height: Get.height / 2.8,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: List.generate(
            c.ratings.length,
            (i) => ListTile(
              onTap: () {
                c.selectedRating.value = c.ratings[i];
                Get.back();
              },
              title: CustomText(
                text: "${c.ratings[i]} ★ & above",
                fontSize: AppFontSize.small,
              ),
              trailing: SvgIcon(assetName: AppIcons.chevronRight, size: 15),
            ),
          ),
        ),
      ),
    );
  }
}
