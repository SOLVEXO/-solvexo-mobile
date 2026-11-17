import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerLanguageController extends GetxController {
  final RxString selected = 'English'.obs;
  final RxBool isSaving = false.obs;

  static const List<Map<String, String>> languages = [
    {'name': 'English', 'native': 'English', 'flag': '🇺🇸'},
    {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Turkish', 'native': 'Türkçe', 'flag': '🇹🇷'},
    {'name': 'Malay', 'native': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'name': 'Urdu', 'native': 'اردو', 'flag': '🇵🇰'},
    {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇧🇩'},
  ];

  void select(String lang) => selected.value = lang;

  Future<void> save() async {
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isSaving.value = false;
    Get.back();
    Get.snackbar('', 'Language set to ${selected.value}',
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12);
  }
}
