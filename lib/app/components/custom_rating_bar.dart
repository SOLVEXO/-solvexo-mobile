import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomRatingBar extends StatelessWidget {
  const CustomRatingBar({
    super.key,
    this.onRatingUpdate,
    this.rating = 0,
    this.itemSize = 15,
    this.ignoreGestures = false,
  });

  final void Function(double)? onRatingUpdate;
  final double rating;
  final double itemSize;
  final bool ignoreGestures;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      ignoreGestures: ignoreGestures,
      maxRating: 5,
      minRating: 0,
      initialRating: rating,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: itemSize,
      ratingWidget: RatingWidget(
        full: const SvgIcon(assetName: AppIcons.fillStar),
        empty: const SvgIcon(assetName: AppIcons.starOutlined),
        half: const SvgIcon(assetName: AppIcons.starOutlined),
      ),
      itemPadding: EdgeInsets.only(right: 1.w),
      onRatingUpdate: (rating) {
        if (onRatingUpdate != null) {
          onRatingUpdate!(rating);
        }
      },
    );
  }
}
