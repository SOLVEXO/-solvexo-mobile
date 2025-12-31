import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeController extends GetxController {
  RxInt index = 0.obs;

  final List<List<Color>> gradients = [
    /// 1️⃣ Brand Blue → Deep Navy
    [Color(0xFF17B1DE), Color(0xFF0B3C5D)],

    /// 2️⃣ Aqua → Purple blend
    [Color(0xFF17B1DE), Color(0xFF6C3AFF)],

    /// 3️⃣ Sky Blue → Emerald Teal
    [Color(0xFF17B1DE), Color(0xFF0AA175)],

    /// 4️⃣ Futuristic Cyan → Dark Space Blue
    [Color(0xFF17B1DE), Color(0xFF00223E)],

    /// 5️⃣ Blue → Pink Sunset Glow
    [Color(0xFF17B1DE), Color(0xFFF72585)],

    /// 6️⃣ Modern Blue → Indigo
    [Color(0xFF17B1DE), Color(0xFF283593)],

    /// 7️⃣ Ocean Blue → Deep Lagoon
    [Color(0xFF17B1DE), Color(0xFF006D77)],

    /// 8️⃣ Corporate Blue → Royal Purple
    [Color(0xFF17B1DE), Color(0xFF4A148C)],

    /// 9️⃣ Blue → Neon Green (Tech Style)
    [Color(0xFF17B1DE), Color(0xFF00CE61)],

    /// 🔟 Cyan → Slate Gray (Luxurious)
    [Color(0xFF17B1DE), Color(0xFF2F3B52)],
  ];

  @override
  void onInit() {
    super.onInit();

    Timer.periodic(const Duration(seconds: 3), (timer) {
      index.value = (index.value + 1) % gradients.length;
    });
  }
}
