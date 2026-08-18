import 'package:book_store_app/app/data/models/onboarding_slide_model.dart';
import 'package:book_store_app/app/data/repositories/onboarding_slides_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  OnboardingController({OnboardingSlidesRepository? repository})
    : _repository = repository ?? OnboardingSlidesRepository();

  final OnboardingSlidesRepository _repository;

  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = true.obs;
  final RxList<OnboardingSlideModel> slides = <OnboardingSlideModel>[].obs;

  int get slideCount => slides.length;
  bool get isLastPage => currentPage.value == slideCount - 1;

  @override
  void onInit() {
    super.onInit();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    isLoading.value = true;
    final result = await _repository.fetchSlides();
    // No slides configured by the admin yet — nothing to show, so treat
    // this launch as already onboarded rather than rendering an empty screen.
    if (result.isEmpty) {
      await finish();
      return;
    }
    slides.assignAll(result);
    isLoading.value = false;
  }

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (isLastPage) {
      finish();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void skip() => finish();

  Future<void> finish() async {
    await AppPreferences.setHasSeenOnboarding(true);
    Get.offAllNamed(Routes.mainHome);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
