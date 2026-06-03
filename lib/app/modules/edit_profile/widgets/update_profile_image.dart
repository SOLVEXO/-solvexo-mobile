import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileImage extends StatelessWidget {
  UpdateProfileImage({super.key});
  final ProfileController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value!;
      return Stack(
        children: [
          // Profile Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // border: Border.all(color: AppColors.primaryColor, width: 3),
            ),
            child: ClipOval(
              child: controller.selectedImageFile.value != null
                  ? Image.file(
                      controller.selectedImageFile.value!,
                      fit: BoxFit.cover,
                    )
                  : CommonImageView(
                      url: user.profileImage,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // Edit button
          if (controller.isEditMode.value)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.showImagePickerOptions,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.white, size: 10),
                ),
              ),
            ),
        ],
      );
    });
  }
}
