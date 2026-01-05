import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/app/modules/profile/modules/address/models/address_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressView extends StatelessWidget {
  AddressView({super.key});
  final controller = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: "Address"),
      body: Obx(() {
        if (controller.addresses.isEmpty) {
          return _emptyState();
        }
        return ListView.builder(
          itemCount: controller.addresses.length,
          itemBuilder: (_, i) {
            final a = controller.addresses[i];
            return _addressCard(a, i);
          },
        );
      }),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(assetName: AppIcons.mapsIcon, size: 80),
          CustomText(
            textAlign: TextAlign.center,
            text: "You don’t have shipping address",
            fontSize: AppFontSize.large,
          ),
          AppButton(
            label: "Add Address",
            onPressed: () => Get.toNamed(Routes.addAddressView),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(AddressModel a, int index) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: AppColors.white),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customcontainer(
                Row(
                  children: [
                    SvgIcon(
                      assetName: AppIcons.locationIcon,
                      color: AppColors.primaryColor,
                    ),
                    CustomText(text: a.label, fontWeight: FontWeight.w500),
                  ],
                ),
              ),
              customcontainer(
                CustomText(text: "Edit", fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: a.name,
                      fontSize: AppFontSize.regular,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      text: "${a.address}, ${a.city}, ${a.state} ${a.zip}",
                      fontSize: AppFontSize.small,
                    ),
                    CustomText(text: a.phone, fontSize: AppFontSize.small),
                  ],
                ),
              ),
              CustomIconButton(
                assetName: AppIcons.checkIcon,
                size: 30,
                color: a.isDefault ? AppColors.primaryColor : AppColors.gray600,
                onPressed: () => controller.selectDefault(index),
              ),
              // Radio(
              //   value: true,
              //   groupValue: a.isDefault,
              //   onChanged: (_) => controller.selectDefault(index),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget customcontainer(Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
