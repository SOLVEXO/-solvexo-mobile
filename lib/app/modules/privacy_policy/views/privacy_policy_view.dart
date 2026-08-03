import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/shimmer/html_content_shimmer.dart';
import 'package:book_store_app/app/components/static_content_html_style.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Privacy Policy"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(BaseSpacing.md),
        child: Obx(
          () => controller.isLoading.value
              ? const HtmlContentShimmer()
              : Html(
                  data: controller.htmlContent.value,
                  style: staticContentHtmlStyle,
                ),
        ),
      ),
    );
  }
}
