import 'package:flutter/widgets.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final ImageLoadingBuilder? loadingBuilder;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder:
          loadingBuilder ??
          (context, child, progress) {
            if (progress == null) return child;
            return placeholder ?? SizedBox(width: width, height: height);
          },
      errorBuilder:
          (context, error, stackTrace) =>
              placeholder ?? SizedBox(width: width, height: height),
    );
  }
}
