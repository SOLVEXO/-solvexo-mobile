import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({
    super.key,
    this.parentHomeShimmer = false,
    this.itemCount = 1,
  });

  final bool parentHomeShimmer;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(top: AppDimen.allPadding),
          padding: EdgeInsets.all(AppDimen.allPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            color: AppColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimen.allPadding,
            children: [
              if (!parentHomeShimmer) ...[
                Skeleton(),
                Skeleton(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Flexible(child: Skeleton(width: 80, height: 15)),
                    Flexible(child: Skeleton(width: 80, height: 15)),
                  ],
                ),
                Skeleton(),
              ] else ...[
                Skeleton(),
                Skeleton(),
                profile(),
                profile(),
              ],
              Skeleton(height: 40, width: double.maxFinite, cornerRadius: 8),
            ],
          ),
        );
      },
    );
  }

  Widget profile() {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,

      children: const [
        Skeleton(cornerRadius: 100, width: 45, height: 45),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Skeleton(height: 10, width: 60),
            Skeleton(height: 10, width: 40),
          ],
        ),
      ],
    );
  }
}
