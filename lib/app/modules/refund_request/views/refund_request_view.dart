import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/recent_order.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/refund_request/controllers/refund_request_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RefundRequestView extends StatelessWidget {
  RefundRequestView({super.key});
  final controller = Get.put(RefundRequestController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: "Request Refund"),
      body: Obx(() {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Order Header
              RecentOrder(),

              const SizedBox(height: 20),

              /// Issue Selection
              if (controller.selectedIssue.value == null)
                _issueList()
              else
                _uploadSection(),

              const Spacer(),

              /// Continue Button
              AppButton(
                label: "Continue",
                onPressed: controller.canContinue ? () {} : () {},
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _issueList() {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "What is the issue with your item?",
            fontWeight: FontWeight.w800,
            fontSize: AppFontSize.regular,
          ),
          ...controller.issues.entries.map((e) {
            return GestureDetector(
              onTap: () => controller.selectedIssue.value = e.key,
              child: Container(
                padding: const EdgeInsets.only(top: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: e.value,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSize.small,
                      color: AppColors.gray600,
                    ),
                    Icon(Icons.radio_button_off, size: 27),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _uploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "What is the issue with your item?",
          fontWeight: FontWeight.w800,
          fontSize: AppFontSize.regular,
        ),
        ListTile(
          title: CustomText(
            text: controller.selectedIssue.value.toString(),
            fontWeight: FontWeight.w500,
            fontSize: AppFontSize.regular,
          ),
          trailing: SvgIcon(assetName: AppIcons.chevronRight),
        ),
        const Text(
          "Upload images or videos (Required)",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        /// Attachments
        Obx(
          () => Wrap(
            spacing: 10,
            children: [
              ...List.generate(controller.attachments.length, (i) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        controller.attachments[i],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: -5,
                      top: -5,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => controller.removeAttachment(i),
                      ),
                    ),
                  ],
                );
              }),

              /// Add Button
              GestureDetector(
                onTap: () => _showPicker(Get.context!),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// Message
        const CustomText(
          text: "Message (optional)",
          fontWeight: FontWeight.w600,
          fontSize: AppFontSize.small,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.messageController,
          hintText: "Tell me more details about your issue",
          maxLines: 4,
          isborder: true,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text("Take Screenshot / Photo"),
              onTap: () {
                controller.pickImage(ImageSource.camera);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                controller.pickImage(ImageSource.gallery);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
