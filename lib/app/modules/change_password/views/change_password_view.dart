import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Change Password"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            CustomTextField(
              label: "Current Password",
              hintText: "Enter current Password",
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              ispadding: true,
            ),
            CustomTextField(
              label: "New Password",
              hintText: "Set New Password",
              ispadding: true,
            ),
            CustomTextField(
              label: "Conform Password",
              hintText: "Conform Password",
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            SizedBox(height: 10),
            AppButton(label: "Reset", onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
