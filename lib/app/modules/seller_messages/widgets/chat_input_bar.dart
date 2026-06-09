import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_chat_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputBar extends StatelessWidget {
  final SellerChatController controller;

  const ChatInputBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomTextField(
              controller: controller.inputCtrl,
              onChanged: controller.onTextChanged,
              maxLines: null,
              hintText: 'Type a message...',
              fillColor: AppColors.textfldFillColor,
              isborder: true,
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final hasText = controller.inputText.value.trim().isNotEmpty;
            return GestureDetector(
              onTap: hasText ? controller.sendMessage : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: hasText
                      ? AppColors.primaryColor
                      : AppColors.primaryColor.withOpacity(0.35),
                  shape: BoxShape.circle,
                  boxShadow: hasText
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: SvgIcon(
                  assetName: AppIcons.messageSendIcon,
                  color: AppColors.white,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
