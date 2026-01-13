import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_center_controller.dart';

class HelpSearchBar extends StatelessWidget {
  const HelpSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final controller = Get.find<HelpCenterController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: CustomTextField(
        controller: searchController,
        isborder: true,
        hintText: "Search an issue",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.searchQuery.value = "";
                    searchController.clear();
                  },
                )
              : const SizedBox(),
        ),
        onChanged: (v) => controller.searchQuery.value = v,
      ),
    );
  }
}
