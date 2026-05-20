import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class TripShimmer extends StatelessWidget {
  const TripShimmer({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(AppDimen.allPadding),
          margin: EdgeInsets.only(bottom: AppDimen.allPadding),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            color: AppColors.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: const [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Skeleton(width: 50, height: 8),
                  Skeleton(width: 70, height: 12, cornerRadius: 50),
                ],
              ),
              Skeleton(width: 60, height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Skeleton(width: 50, height: 8),
                  Skeleton(width: 50, height: 8),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
