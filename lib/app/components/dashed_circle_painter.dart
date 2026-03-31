import 'dart:math';
import 'package:flutter/material.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  const DashedCirclePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startAngle = 0;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 1,
    );

    while (startAngle < 360) {
      canvas.drawArc(
        rect,
        startAngle * (pi / 180),
        dashWidth * (pi / 180),
        false,
        paint,
      );
      startAngle += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
