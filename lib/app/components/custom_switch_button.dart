import 'package:book_store_app/app/components/custom_text.dart';
import 'package:flutter/cupertino.dart';

class CustomSwitchButton extends StatelessWidget {
  const CustomSwitchButton({
    super.key,
    required this.text,
    required this.onChanged,
    required this.isSelected,
  });

  final String text;
  final Function(bool) onChanged;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text: text, fontSize: 15, fontWeight: FontWeight.w500),
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(value: isSelected, onChanged: onChanged),
        ),
      ],
    );
  }
}
