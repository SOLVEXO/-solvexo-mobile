import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/login/controller/auth_tabs_controller.dart';
import 'package:book_store_app/app/modules/login/login_view.dart';
import 'package:book_store_app/app/modules/signup/sign_up_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthTabsView extends StatelessWidget {
  AuthTabsView({super.key});

  final controller = Get.put(AuthTabsController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTab = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(
        backgroundColor: AppColors.white,
        color: AppColors.black,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 22),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.lightGrey, strokeAlign: 0.5),
            ),
            child: CustomText(text: "Skip", letterSpacing: 2),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: isTab ? size.width * 0.55 : size.width,
          padding: EdgeInsets.symmetric(
            horizontal: isTab ? 40 : 22,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TABS
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGrey, width: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.background,
                ),
                child: Row(
                  children: [
                    _tab("Sign in", 0, AppColors.primaryColor, controller),
                    _tab("Sign up", 1, AppColors.primaryColor, controller),
                  ],
                ),
              ),

              /// BODY AREA
              Expanded(
                child: Obx(() {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: controller.tabIndex.value == 0
                        ? LoginView(key: const ValueKey(0))
                        : SignUpView(key: const ValueKey(1)),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _tab(
    String text,
    int pos,
    Color primary,
    AuthTabsController controller,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.switchTab(pos),
        child: Obx(() {
          final active = controller.tabIndex.value == pos;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: active ? primary : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: CustomText(
              text: text,
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ),
    );
  }
}
