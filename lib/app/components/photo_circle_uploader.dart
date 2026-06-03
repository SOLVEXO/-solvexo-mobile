import 'dart:io';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/dashed_circle_painter.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class PhotoCircleUploader extends StatelessWidget {
  final File? imageFile;
  final String? imagePath;
  final VoidCallback onTap;
  final String label;
  final String? iconPath;
  final String? overlayIconPath;
  final bool showDashedBorder;
  final bool showOverlay;
  final double size;
  final double? iconSize;
  final Color backgroundColor;

  const PhotoCircleUploader({
    super.key,
    required this.imageFile,
    required this.onTap,
    required this.label,
    this.imagePath,
    this.iconPath,
    this.overlayIconPath,
    this.showDashedBorder = false,
    this.showOverlay = false,
    this.size = 80,
    this.iconSize,
    this.backgroundColor = AppColors.textfldFillColor,
  });

  bool _isNetworkImage(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final double overlaySize = iconSize ?? size * 0.3;

    Widget imageWidget;

    if (imageFile != null) {
      imageWidget = Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      if (_isNetworkImage(imagePath)) {
        imageWidget = CommonImageView(
          url: imagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } else if (imagePath!.startsWith('assets/')) {
        imageWidget = Image.asset(
          imagePath!,
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      } else {
        imageWidget = Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      }
    } else {
      // Default state (dashed border or icon)
      if (showDashedBorder) {
        imageWidget = CustomPaint(
          painter: DashedCirclePainter(
            color: AppColors.primaryColor,
            dashWidth: 7,
            dashSpace: 3,
          ),
          child: Center(
            child: iconPath != null
                ? CommonImageView(
                    svgPath: iconPath!,
                    height: overlaySize,
                    width: overlaySize,
                  )
                : const SizedBox.shrink(),
          ),
        );
      } else {
        imageWidget = Center(
          child: iconPath != null
              ? CommonImageView(
                  svgPath: iconPath!,
                  height: overlaySize,
                  width: overlaySize,
                )
              : const SizedBox.shrink(),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                ),
                child: ClipOval(child: imageWidget),
              ),
              if (showOverlay)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              if (showOverlay && overlayIconPath != null)
                CommonImageView(
                  svgPath: overlayIconPath!,
                  height: overlaySize,
                  width: overlaySize,
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        CustomText(
          text: label,
          fontSize: AppFontSize.small2,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}
