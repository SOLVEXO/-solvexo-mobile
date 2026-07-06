import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ConversationsShimmer extends StatelessWidget {
  const ConversationsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey2.withOpacity(0.6),
      highlightColor: AppColors.background,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.lightGrey3),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 130, height: 14, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 8),
                    Container(width: 190, height: 12, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
