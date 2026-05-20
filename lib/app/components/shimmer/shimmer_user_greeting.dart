import 'package:book_store_app/app/components/skeleton.dart';
import 'package:flutter/material.dart';

class ShimmerUserGreeting extends StatelessWidget {
  const ShimmerUserGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Skeleton(height: 48, width: 48, cornerRadius: 24), // profile image
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(height: 14, width: 120, cornerRadius: 4), // name
            SizedBox(height: 6),
            Skeleton(height: 12, width: 80, cornerRadius: 4), // location
          ],
        ),
      ],
    );
  }
}
