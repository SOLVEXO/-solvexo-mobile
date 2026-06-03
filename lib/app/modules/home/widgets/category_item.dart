import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String? image;
  final Function()? onTap;
  const CategoryItem({super.key, required this.title, this.image, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // onTap: () => Get.toNamed(Routes.categoryView),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: AppColors.black12, blurRadius: 6)],
        ),

        // height: height / 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonImageView(
              url: image, // Backend image URL
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              radius: BorderRadius.circular(12),
              placeHolder: AppImages.sampleProduct,
            ),
            // const SizedBox(height: 8),
            CustomText(
              text: title,
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
