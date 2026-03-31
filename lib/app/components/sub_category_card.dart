import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class SubCategoryCard extends StatelessWidget {
  final String title;
  final String price;
  final String image;
  final Color color;

  const SubCategoryCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 🔥 Responsive scaling
    final padding = width * 0.035; // dynamic padding
    final imageSize = width * 0.18; // dynamic image size
    final titleSize = width * 0.035;
    final smallText = width * 0.028;

    return LayoutBuilder(
      builder: (context, constraints) {
        // final cardWidth = constraints.maxWidth;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              /// 🔹 TEXT SIDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: title,
                      fontSize: titleSize.clamp(12, 16), // 👈 safe scaling
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    CustomText(
                      text: "Start from",
                      fontSize: smallText.clamp(10, 13),
                      color: AppColors.lightGrey,
                    ),
                    const SizedBox(height: 4),

                    CustomText(
                      text: price,
                      fontSize: smallText.clamp(11, 14),
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// 🔹 IMAGE
              SizedBox(
                height: imageSize.clamp(50, 90),
                width: imageSize.clamp(50, 90),
                child: CommonImageView(url: image, fit: BoxFit.contain),
              ),
            ],
          ),
        );
      },
    );
  }
}
