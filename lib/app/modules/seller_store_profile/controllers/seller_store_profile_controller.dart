import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<String> kStoreCategories = [
  'Education & Learning', 'Arts & Crafts', 'Fashion & Apparel',
  'Electronics', 'Food & Beverage', 'Health & Beauty',
  'Home & Garden', 'Sports & Outdoors', 'Books & Media',
  'Services & Consulting', 'Others',
];

class SellerStoreProfileController extends GetxController {
  final RxBool isSaving = false.obs;

  final RxString storeName = 'My Shop'.obs;
  final RxString storeDescription = ''.obs;
  final RxString storeCategory = 'Education & Learning'.obs;
  final RxString contactEmail = 'alex@myshop.com'.obs;
  final RxString contactPhone = ''.obs;
  final RxBool hasLogo = false.obs;

  late final TextEditingController nameCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;

  bool get canSave => storeName.value.trim().isNotEmpty;

  void pickCategory(String cat) => storeCategory.value = cat;
  void pickLogo() => hasLogo.value = true;

  Future<void> save() async {
    if (!canSave || isSaving.value) return;
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    isSaving.value = false;
    Get.back();
    Get.snackbar('', 'Store profile updated!',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12);
  }

  @override
  void onInit() {
    super.onInit();
    nameCtrl = TextEditingController(text: storeName.value);
    descCtrl = TextEditingController(text: storeDescription.value);
    emailCtrl = TextEditingController(text: contactEmail.value);
    phoneCtrl = TextEditingController(text: contactPhone.value);
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }
}
