import 'package:flutter/material.dart';

class NotchBorderPainter extends CustomPainter {
  final double radius;
  final double cut;
  final Color color;
  final double strokeWidth;
  NotchBorderPainter({
    required this.radius,
    required this.cut,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w - cut, cut)
      ..lineTo(w, cut)
      ..lineTo(w, h - radius)
      ..quadraticBezierTo(w, h, w - radius, h)
      ..lineTo(radius, h)
      ..quadraticBezierTo(0, h, 0, h - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
