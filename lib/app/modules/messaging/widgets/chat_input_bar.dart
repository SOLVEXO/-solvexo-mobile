import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/messaging/controllers/chat_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputBar extends StatelessWidget {
  final ChatController c;
  const ChatInputBar({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isBlocked) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: AppColors.white,
          child: const Center(
            child: CustomText(
              text: 'You can\'t reply to this conversation.',
              fontSize: AppFontSize.verySmall,
              color: AppColors.gray600,
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.fromLTRB(
          10,
          8,
          10,
          MediaQuery.of(context).padding.bottom + 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: c.isSending.value
                    ? null
                    : () => AppImagePicker.show(
                        title: 'Send Photo',
                        onPicked: (file) => c.sendImage(file),
                      ),
                child: Container(
                  width: 42,
                  height: 42,
                  margin: const EdgeInsets.only(bottom: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgIcon(
                    assetName: AppIcons.uploadImageIcon,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: c.textController,
                  hintText: 'Type a message…',
                  filled: true,
                  fillColor: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  // maxLines: 5,
                  onFieldSubmitted: (_) => c.sendText(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: c.isSending.value ? null : c.sendText,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.accentColor],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: c.isSending.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : SvgIcon(
                          assetName: AppIcons.messageSendIcon,
                          color: AppColors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
