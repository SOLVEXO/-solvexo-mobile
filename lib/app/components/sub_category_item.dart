import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class SubCategoryItem extends StatelessWidget {
  final String? prodImage;
  final String subCategoryName;

  const SubCategoryItem({
    super.key,
    this.prodImage,
    required this.subCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    // double w = MediaQuery.of(context).size.width;

    return Container(
      // width: w / 3.9,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: AppColors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),

      // 👇 KEY: only take required height
      child: Column(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CommonImageView(
            url: prodImage,
            width: 50,
            height: 50,
            radius: BorderRadius.circular(AppDimen.borderRadius),
          ),

          CustomText(
            text: subCategoryName,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
