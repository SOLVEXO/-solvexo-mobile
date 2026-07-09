import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/modules/help_center/controllers/help_center_controller.dart';
import 'package:book_store_app/app/modules/help_center/widgets/search_bar.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/faq_tile.dart';

class HelpCenterView extends StatelessWidget {
  HelpCenterView({super.key});
  final controller = Get.put(FaqController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Help Centre"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 5, color: AppColors.lightGrey.withOpacity(0.2), height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Related FAQs",
                  style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
                ),
                GhostButton(label: "View all topics", onPressed: () => Get.toNamed(Routes.faqListView)),
              ],
            ),
          ),
          HelpSearchBar(),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs + 2),
                itemCount: controller.filteredFaqs.length,
                itemBuilder: (_, i) {
                  final faq = controller.filteredFaqs[i];
                  return FaqTile(faq: faq, onTap: () => Get.toNamed(Routes.faqDetailView, arguments: faq));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
