import 'package:book_store_app/app/components/skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HtmlContentShimmer extends StatelessWidget {
  const HtmlContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(height: 20, width: 30.w),

        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 7.0),
              child: Skeleton(height: 10, width: 90.w),
            );
          },
        ),
        Skeleton(height: 10, width: 70.w),
        SizedBox(height: 7),
        Skeleton(height: 10, width: 30.w),
      ],
    );
  }
}
