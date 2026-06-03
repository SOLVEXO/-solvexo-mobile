import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DynamicShimmer extends StatelessWidget {
  final bool isbanner;
  final bool iscategories;
  final bool issubcategories;
  final bool isproducts;
  final bool istabs;

  const DynamicShimmer({
    super.key,
    this.isbanner = false,
    this.istabs = false,
    this.iscategories = false,
    this.issubcategories = false,
    this.isproducts = false,
  });

  Widget shimmerBox({double? height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(.1),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textPrimary.withOpacity(.2),
      highlightColor: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Banner
            if (isbanner)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: shimmerBox(height: 160),
              ),

            /// Subcategories
            if (issubcategories)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (_, __) => shimmerBox(),
                ),
              ),

            /// Tabs
            if (istabs)
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: shimmerBox(width: 70, height: 40),
                  ),
                ),
              ),

            /// Categories
            if (iscategories)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: .8,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (_, __) => shimmerBox(),
                ),
              ),

            /// Products
            if (isproducts)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .9,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemBuilder: (_, __) => shimmerBox(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
