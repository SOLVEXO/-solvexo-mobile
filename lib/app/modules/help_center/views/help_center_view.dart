import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/help_center/controllers/help_center_controller.dart';
import 'package:book_store_app/app/modules/help_center/widgets/search_bar.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
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
          /// Recent Order
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20),
          //   child: RecentOrder(),
          // ),
          Divider(
            thickness: 5,
            color: AppColors.lightGrey.withOpacity(0.2),
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: "Related FAQs",
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.regular,
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed(Routes.faqListView);
                  },
                  child: CustomText(
                    color: AppColors.primaryColor,
                    text: "View all topics",
                    fontSize: AppFontSize.small,
                  ),
                ),
              ],
            ),
          ),
          HelpSearchBar(),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                itemCount: controller.filteredFaqs.length,
                itemBuilder: (_, i) {
                  final faq = controller.filteredFaqs[i];
                  return FaqTile(
                    faq: faq,
                    onTap: () =>
                        Get.toNamed(Routes.faqDetailView, arguments: faq),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
