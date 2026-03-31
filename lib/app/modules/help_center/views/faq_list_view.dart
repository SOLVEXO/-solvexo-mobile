import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_center_controller.dart';
import '../widgets/faq_tile.dart';
import '../widgets/search_bar.dart';

class FAQListView extends StatelessWidget {
  const FAQListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "FAQ"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            HelpSearchBar(),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(
                () => ListView.builder(
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
      ),
    );
  }
}
