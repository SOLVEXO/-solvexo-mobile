import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomVarient extends StatelessWidget {
  CustomVarient({super.key});
  final controller = Get.put(ProductController());
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Select Variants",
          fontWeight: FontWeight.w600,
          fontSize: AppFontSize.regular,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: [
            ListView.builder(
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return ChoiceChip(
                  selected: true,
                  label: Text("Color"),
                  selectedColor: Colors.blue.shade100,
                  onSelected: (_) => controller.selectVariant(index),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
