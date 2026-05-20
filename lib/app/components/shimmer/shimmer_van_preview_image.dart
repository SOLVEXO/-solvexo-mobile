import 'package:book_store_app/app/components/shimmer/shimmer_image.dart';
import 'package:book_store_app/app/components/skeleton.dart';
import 'package:flutter/widgets.dart';

class ShimmerVanPreviewImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const ShimmerVanPreviewImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ShimmerImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: Skeleton(height: height, width: width, cornerRadius: 8),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Skeleton(height: height, width: width, cornerRadius: 8);
        },
      ),
    );
  }
}
