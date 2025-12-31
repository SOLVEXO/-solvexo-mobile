import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class SubCategoryItem extends StatelessWidget {
  final String prodImage;
  final String subCategoryName;

  const SubCategoryItem({
    super.key,
    required this.prodImage,
    required this.subCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Container(
      width: w / 3.9,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),

      // 👇 KEY: only take required height
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(assetName: prodImage, size: 70),

          CustomText(
            text: subCategoryName,
            fontSize: AppFontSize.extraSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
