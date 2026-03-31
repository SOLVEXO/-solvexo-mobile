import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "About"),
      body: const Center(
        child: Text('AboutView is working', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
