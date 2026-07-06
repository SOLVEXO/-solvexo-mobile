import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Full-screen skeleton shown while the storefront profile is loading —
/// mirrors [StorefrontHeader]'s proportions so the loading → loaded
/// transition doesn't visibly jump.
class StorefrontShimmer extends StatelessWidget {
  const StorefrontShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey2.withOpacity(0.6),
      highlightColor: AppColors.background,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 244,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Container(height: 200, width: double.infinity, color: AppColors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(width: 170, height: 20),
                  const SizedBox(height: 10),
                  _bar(width: 90, height: 22, radius: 20),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _bar(width: 100, height: 30, radius: 12),
                      const SizedBox(width: 10),
                      _bar(width: 100, height: 30, radius: 12),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _bar(width: double.infinity, height: 44, radius: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _bar(width: double.infinity, height: 60, radius: 16),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: _bar(width: double.infinity, height: 60, radius: 18),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (_, __) => _bar(width: double.infinity, height: double.infinity, radius: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
