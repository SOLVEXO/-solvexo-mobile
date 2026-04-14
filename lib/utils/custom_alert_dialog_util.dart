import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class CustomAlertDialogUtil extends StatelessWidget {
  final String title, content, leftButtonName, rightButtonName;
  final Function()? onLeftButtonTap, onRightButtonTap;

  const CustomAlertDialogUtil({
    super.key,
    required this.title,
    required this.content,
    required this.leftButtonName,
    required this.rightButtonName,
    this.onLeftButtonTap,
    this.onRightButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: CommonImageView(imagePath: AppImages.transparentLogo, width: 20),
      title: CustomText(
        text: title,
        fontSize: AppFontSize.medium,
        fontWeight: FontWeight.w600,
      ),
      content: CustomText(
        text: content,
        fontSize: AppFontSize.small,
        fontWeight: FontWeight.w400,
      ),
      actions: [
        Row(
          spacing: AppDimen.borderRadius,
          children: [
            Expanded(
              child: AppButton(
                onPressed: onLeftButtonTap,
                label: leftButtonName,
                isOutlined: true,
              ),
            ),
            Expanded(
              child: AppButton(
                onPressed: onRightButtonTap,
                label: rightButtonName,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
