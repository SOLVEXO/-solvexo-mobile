import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Function()? onPressed;
  final bool isPadding;
  final String assetName;
  final double? size;
  final Color? color;
  const CustomIconButton({
    super.key,
    this.onPressed,
    required this.assetName,
    this.isPadding = false,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: isPadding ? 12.0 : 0),
      child: GestureDetector(
        onTap: onPressed,
        child: SvgIcon(assetName: assetName, size: size, color: color),
      ),
    );
  }
}
