import 'package:book_store_app/app/modules/welcome/controller/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedBackground extends StatelessWidget {
  final Widget child;

  AnimatedBackground({super.key, required this.child});

  final controller = Get.put(WelcomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Obx(() {
          return AnimatedContainer(
            duration: const Duration(seconds: 4),
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: controller.gradients[controller.index.value],
              ),
            ),
          );
        }),

        /// Your UI screen on top
        child,
      ],
    );
  }
}
