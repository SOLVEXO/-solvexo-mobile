import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/controllers/seller_ai_studio_controller.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/widgets/ai_credits_banner.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/widgets/ai_output_panel.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/widgets/ai_tool_grid.dart';
import 'package:book_store_app/app/modules/seller_ai_studio/widgets/ai_tool_input_panel.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerAiStudioView extends StatelessWidget {
  SellerAiStudioView({super.key});

  final SellerAiStudioController controller = Get.put(
    SellerAiStudioController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'AI Studio'),
      body: Column(
        children: [
          // const SellerAppBar(title: 'AI Studio', subtitle: 'My Shop'),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: CustomRefreshWrapper(
              onRefresh: () async {},
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AiCreditsBanner(controller: controller),
                    _SectionHeader(title: 'AI Tools'),
                    const SizedBox(height: 10),
                    AiToolGrid(controller: controller),
                    const SizedBox(height: 20),
                    AiToolInputPanel(controller: controller),
                    const SizedBox(height: 16),
                    AiOutputPanel(controller: controller),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimen.allPadding,
        0,
        AppDimen.allPadding,
        0,
      ),
      child: CustomText(
        text: title,
        fontSize: AppFontSize.medium,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}
