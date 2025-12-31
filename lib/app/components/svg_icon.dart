// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;
  final double? size;
  final Color? color;

  const SvgIcon({super.key, required this.assetName, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    if (assetName.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        assetName,
        height: size ?? 24,
        width: size ?? 24,
        color: color,
      );
    } else {
      // fallback for PNG/JPG
      return Image.asset(
        assetName,
        height: size ?? 24,
        width: size ?? 24,
        color: color,
      );
    }
  }
}
