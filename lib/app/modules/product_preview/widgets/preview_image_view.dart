import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom view of a watermarked image preview. No
/// save/share affordance is exposed — the URL is a short-lived signed link
/// to a downsized, watermarked derivative, never the original file.
class PreviewImageView extends StatelessWidget {
  final String url;

  const PreviewImageView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Center(
        child: CommonImageView(url: url, fit: BoxFit.contain),
      ),
    );
  }
}
