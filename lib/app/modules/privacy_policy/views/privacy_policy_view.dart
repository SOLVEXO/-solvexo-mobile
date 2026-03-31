import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Privacy Policy"),
      body: const Center(
        child: Text(
          'PrivacyPolicyView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
