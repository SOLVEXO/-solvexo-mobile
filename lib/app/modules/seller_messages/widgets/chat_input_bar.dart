import 'package:book_store_app/app/modules/seller_messages/controllers/seller_chat_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lightGrey2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12, bottom: 10),
                    child: Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.grey,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.inputCtrl,
                      onChanged: controller.onTextChanged,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 10, bottom: 10),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.grey,
                      size: 22,
                    ),
                  ),
                ],
              ),
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
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
