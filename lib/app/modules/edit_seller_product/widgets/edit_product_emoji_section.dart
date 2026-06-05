import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProductEmojiSection extends StatelessWidget {
  final EditSellerProductController controller;

  const EditProductEmojiSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() => _EmojiCircle(
                emoji: controller.selectedEmoji.value,
                onTap: () => _showEmojiPicker(context, controller),
              )),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Product Icon',
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                const SizedBox(height: 4),
                const CustomText(
                  text: 'Tap the icon to change it',
                  fontSize: AppFontSize.verySmall,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEmojiPicker(context, controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                border: Border.all(color: AppColors.lightGrey2),
              ),
              child: const CustomText(
                text: 'Change',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(
    BuildContext context,
    EditSellerProductController controller,
  ) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'Select an Icon',
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(
                () => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: kProductEmojis.map((emoji) {
                    final isSelected = controller.selectedEmoji.value == emoji;
                    return GestureDetector(
                      onTap: () => controller.pickEmoji(emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.lightGrey2,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class _EmojiCircle extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiCircle({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.languageBg,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }
}
