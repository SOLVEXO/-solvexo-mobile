import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/routes/app_pages.dart';

class SplashScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController logoController;
  late Animation<double> scaleAnim;
  late Animation<Offset> slideAnim;
  late Animation<double> textFade;

  @override
  void onInit() {
    super.onInit();

    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    /// 🔥 Slide from bottom
    slideAnim = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: logoController, curve: Curves.easeOutCubic),
        );

    /// 🔥 Scale small → big
    scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
    );

    /// 🔥 Text fade (delay)
    textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: logoController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    logoController.forward();

    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(Routes.mainHome);
  }

  @override
  void onClose() {
    logoController.dispose();
    super.onClose();
  }
}
