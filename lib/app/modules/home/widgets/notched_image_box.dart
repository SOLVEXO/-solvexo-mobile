import 'package:book_store_app/app/modules/home/widgets/notch_border_painter.dart';
import 'package:book_store_app/app/modules/home/widgets/notch_clipper.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class NotchedImageBox extends StatelessWidget {
  final Widget child;
  final double heartGap;
  final double heartSize;
  final double radius;

  const NotchedImageBox({
    super.key,
    required this.child,
    required this.heartGap,
    required this.heartSize,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final cut = heartSize + heartGap;

    return Stack(
      children: [
        ClipPath(
          clipper: NotchClipper(radius: radius, cut: cut),
          child: Container(
            color: AppColors.languageBg,

            child: SizedBox.expand(child: child),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: NotchBorderPainter(
              radius: radius,
              cut: cut,
              color: AppColors.primaryColor.withOpacity(0.4),
              strokeWidth: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
