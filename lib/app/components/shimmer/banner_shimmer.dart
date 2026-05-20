import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BannerShimmer extends StatelessWidget {
  const BannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimen.allPadding),
      height: 24.h,
      width: double.maxFinite,
      child: Skeleton(cornerRadius: AppDimen.borderRadius),
    );
  }
}
