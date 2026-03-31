import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/repositories/address_repository.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  final AddressRepository service = Get.put(AddressRepository());

  RxList<AddressModel> addresses = <AddressModel>[].obs;
  RxBool loading = false.obs;

  RxString selectedLabel = "Home".obs;
  RxBool makeDefault = false.obs;

  // =============================
  // FORM CONTROLLERS
  // =============================
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl1 = TextEditingController();
  final addressCtrl2 = TextEditingController();
  final stateCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final countryCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl1.dispose();
    addressCtrl2.dispose();
    stateCtrl.dispose();
    cityCtrl.dispose();
    zipCtrl.dispose();
    countryCtrl.dispose();
    super.onClose();
  }

  // =========================================================
  // FETCH
  // =========================================================
  Future<void> fetchAddresses() async {
    try {
      loading.value = true;
      addresses.value = await service.fetchAddresses();
    } finally {
      loading.value = false;
    }
  }

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere((e) => e.isDefault == true);
    } catch (e) {
      return null;
    }
  }

  // =========================================================
  // CREATE
  // =========================================================
  Future<void> saveAddress() async {
    try {
      final model = AddressModel(
        label: selectedLabel.value,
        fullName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        addressLine1: addressCtrl1.text.trim(),
        addressLine2: addressCtrl2.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        zipCode: zipCtrl.text.trim(),
        country: countryCtrl.text.trim(),
        isDefault: makeDefault.value,
      );

      await service.createAddress(model); // ✅ send ONE object only
      await fetchAddresses(); // refresh from backend

      _clearForm();

      Get.back();
      Get.snackbar("Success", "Address added successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // =========================================================
  // UPDATE
  // =========================================================
  Future<void> updateAddress(AddressModel model) async {
    await service.updateAddress(model);
    await fetchAddresses();
  }

  // =========================================================
  // DELETE
  // =========================================================
  Future<void> deleteAddress(String id) async {
    await service.deleteAddress(id);
    await fetchAddresses();
  }

  // =========================================================
  // SET DEFAULT
  // =========================================================
  Future<void> setDefault(String id) async {
    await service.setDefault(id);
    await fetchAddresses();
  }

  // =========================================================
  // HELPERS
  // =========================================================
  void _clearForm() {
    nameCtrl.clear();
    phoneCtrl.clear();
    addressCtrl1.clear();
    addressCtrl2.clear();
    stateCtrl.clear();
    cityCtrl.clear();
    zipCtrl.clear();
    countryCtrl.clear();

    selectedLabel.value = "Home";
    makeDefault.value = false;
  }

  // =========================================================
  // LABEL BOTTOM SHEET
  // =========================================================
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
