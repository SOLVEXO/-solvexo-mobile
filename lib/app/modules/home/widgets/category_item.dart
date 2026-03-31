import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String? image;

  const CategoryItem({super.key, required this.title, this.image});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.categoryView),
      child: SizedBox(
        width: w / 3.5,
        height: height / 5,
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: CommonImageView(
                url: image, // Backend image URL
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(12),
                placeHolder: AppImages.sampleProduct,
              ),
            ),
            const SizedBox(height: 8),
            CustomText(
              text: title,
              fontSize: AppFontSize.small2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
