import 'package:flutter/material.dart';

class NotchClipper extends CustomClipper<Path> {
  final double radius;
  final double cut;
  NotchClipper({required this.radius, required this.cut});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
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
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
