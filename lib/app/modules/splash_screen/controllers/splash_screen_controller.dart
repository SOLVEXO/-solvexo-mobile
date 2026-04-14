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
      duration: const Duration(milliseconds: 1900),
    );

    /// 🔥 Slide from bottom
    slideAnim = Tween<Offset>(begin: const Offset(0, 1.9), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: logoController, curve: Curves.easeOutCubic),
        );

    /// 🔥 Scale small → big
    scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
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

  // RxInt index = 0.obs;

  // final List<List<Color>> gradients = [
  //   /// 1️⃣ Brand Blue → Deep Navy
  //   [Color(0xFF17B1DE), Color(0xFF0B3C5D)],

  //   /// 2️⃣ Aqua → Purple blend
  //   [Color(0xFF17B1DE), Color(0xFF6C3AFF)],

  //   /// 3️⃣ Sky Blue → Emerald Teal
  //   [Color(0xFF17B1DE), Color(0xFF0AA175)],

  //   /// 4️⃣ Futuristic Cyan → Dark Space Blue
  //   [Color(0xFF17B1DE), Color(0xFF00223E)],

  //   /// 5️⃣ Blue → Pink Sunset Glow
  //   [Color(0xFF17B1DE), Color(0xFFF72585)],

  //   /// 6️⃣ Modern Blue → Indigo
  //   [Color(0xFF17B1DE), Color(0xFF283593)],

  //   /// 7️⃣ Ocean Blue → Deep Lagoon
  //   [Color(0xFF17B1DE), Color(0xFF006D77)],

  //   /// 8️⃣ Corporate Blue → Royal Purple
  //   [Color(0xFF17B1DE), Color(0xFF4A148C)],

  //   /// 9️⃣ Blue → Neon Green (Tech Style)
  //   [Color(0xFF17B1DE), Color(0xFF00CE61)],

  //   /// 🔟 Cyan → Slate Gray (Luxurious)
  //   [Color(0xFF17B1DE), Color(0xFF2F3B52)],
  // ];

  // @override
  // void onInit() {
  //   super.onInit();

  //   Timer.periodic(const Duration(seconds: 3), (timer) {
  //     index.value = (index.value + 1) % gradients.length;
  //   });
  // }
}
