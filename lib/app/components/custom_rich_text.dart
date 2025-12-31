import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final double fontSize;
  final TextAlign textAlign;
  final List<TextSpan> spans;
  final double lineSpacing;
  final Color color;
  final int? maxLines;

  const CustomRichText({
    super.key,
    required this.spans,
    this.maxLines,
    this.fontSize = AppFontSize.small2,
    this.lineSpacing = 1.2,
    this.textAlign = TextAlign.start,
    this.color = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: true,
      text: TextSpan(
        style: TextStyle(color: color, height: lineSpacing, fontSize: fontSize),
        children: spans,
      ),
    );
  }
}

class CustomSpan extends TextSpan {
  CustomSpan({
    String text = "",
    Color fontColor = AppColors.white,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = AppFontSize.small2,
    void Function()? onTap,
  }) : super(
         text: text,
         style: TextStyle(
           color: fontColor,
           fontWeight: fontWeight,
           fontSize: fontSize,
         ),
         recognizer: TapGestureRecognizer()..onTap = onTap,
       );
}
