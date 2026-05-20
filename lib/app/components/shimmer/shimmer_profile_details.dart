import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ShimmerProfileDetails extends StatelessWidget {
  final int itemCount;
  const ShimmerProfileDetails({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Skeleton(height: 14, width: 100, cornerRadius: 4),
                Skeleton(height: 14, width: 150, cornerRadius: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
