import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ShimmerProfileKids extends StatelessWidget {
  final int itemCount;
  const ShimmerProfileKids({super.key, this.itemCount = 3});

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
              children: const [
                Skeleton(height: 40, width: 40, cornerRadius: 25),
                SizedBox(width: 8),
                Skeleton(height: 10, width: 70, cornerRadius: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}
