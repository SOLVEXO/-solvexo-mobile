import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  RxList<AddressModel> addresses = <AddressModel>[].obs;
  RxString selectedLabel = "Home".obs;
  RxBool makeDefault = false.obs;

  /// Form fields
  final nameCtrl = "".obs;
  final phoneCtrl = "".obs;
  final addressCtrl = "".obs;
  final aptCtrl = "".obs;
  final stateCtrl = "".obs;
  final cityCtrl = "".obs;
  final zipCtrl = "".obs;

  void saveAddress() {
    if (makeDefault.value) {
      for (var a in addresses) {
        a.isDefault = false;
      }
    }

    addresses.add(
      AddressModel(
        label: selectedLabel.value,
        name: nameCtrl.value,
        phone: phoneCtrl.value,
        address: addressCtrl.value,
        apartment: aptCtrl.value,
        state: stateCtrl.value,
        city: cityCtrl.value,
        zip: zipCtrl.value,
        isDefault: makeDefault.value,
      ),
    );

    Get.back();
    Get.snackbar(
      "Success",
      "We have added your new address",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.barrierColor,
      colorText: AppColors.white,
    );
  }

  void selectDefault(int index) {
    for (var a in addresses) {
      a.isDefault = false;
    }
    addresses[index].isDefault = true;
    addresses.refresh();
  }

  void labelSheet(Size size) {
    Get.bottomSheet(
      CustomBottomSheet(
        height: size.height / 2.7,
        title: "Label Address",
        widget: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Home", "Office", "Apartment", "Other"].map((e) {
              return ListTile(
                title: CustomText(text: e, fontSize: AppFontSize.regular),
                trailing: Obx(
                  () => Radio(
                    value: e,
                    groupValue: selectedLabel.value,
                    onChanged: (_) {
                      selectedLabel.value = e;
                      Get.back();
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
