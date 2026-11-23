import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:flutter/material.dart';

/// SVG icon button. R4: always a 44x44 minimum tap area, and a screen-reader
/// label + long-press tooltip when [semanticLabel] is given (pass `.tr` text
/// on buyer screens).
class CustomIconButton extends StatelessWidget {
  final Function()? onPressed;
  final bool isPadding;
  final String assetName;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  const CustomIconButton({
    super.key,
    this.onPressed,
    required this.assetName,
    this.isPadding = false,
    this.size,
    this.color,
    this.semanticLabel,
  });

  static const double minTap = 44;

  @override
  Widget build(BuildContext context) {
    Widget child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: minTap, minHeight: minTap),
        child: Center(widthFactor: 1, heightFactor: 1, child: SvgIcon(assetName: assetName, size: size, color: color)),
      ),
    );
    if (semanticLabel != null) {
      child = Tooltip(
        message: semanticLabel!,
        child: Semantics(button: true, label: semanticLabel, excludeSemantics: true, child: child),
      );
    }
    return Padding(padding: EdgeInsetsDirectional.only(end: isPadding ? 12.0 : 0), child: child);
  }
}
