import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey2.withOpacity(0.6),
      highlightColor: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _bubble(align: Alignment.centerLeft, width: 190),
          _bubble(align: Alignment.centerRight, width: 140),
          _bubble(align: Alignment.centerLeft, width: 220),
          _bubble(align: Alignment.centerLeft, width: 130),
          _bubble(align: Alignment.centerRight, width: 170),
          _bubble(align: Alignment.centerRight, width: 100),
        ],
      ),
    );
  }

  Widget _bubble({required Alignment align, required double width}) {
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: width,
        height: 40,
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
