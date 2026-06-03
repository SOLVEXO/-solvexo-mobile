import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class ShimmerVanCard extends StatelessWidget {
  const ShimmerVanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimen.allPadding),
      child: Container(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                SizedBox(width: AppDimen.horizontalPadding),
                Skeleton(height: 60, width: 60, cornerRadius: 30),
                Spacer(),
                // Skeleton(height: 30, width: 100, cornerRadius: 15),
              ],
            ),
            const SizedBox(height: AppDimen.allPadding),
            Divider(),
            const SizedBox(height: AppDimen.allPadding),

            // Van details (matches _buildVanDetails)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerDetailRow(),
                _buildShimmerDetailRow(),
                _buildShimmerDetailRow(),
                // _buildShimmerDetailRow(),
                // _buildShimmerDetailRow(),
                // _buildShimmerDetailRow(),
                // For image previews
                // _buildShimmerImagePreview(),
                // _buildShimmerImagePreview(),
              ],
            ),
            Divider(),
            const SizedBox(height: AppDimen.verticalPadding),

            // Action buttons (matches _buildActionButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Skeleton(height: 36, width: 120, cornerRadius: 18),
                Skeleton(height: 36, width: 100, cornerRadius: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerDetailRow() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Skeleton(height: 14, width: 100, cornerRadius: 4),
          SizedBox(width: 8),
          Expanded(child: Skeleton(height: 14, cornerRadius: 4)),
        ],
      ),
    );
  }
}
