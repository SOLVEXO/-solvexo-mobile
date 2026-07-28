import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Form(
      key: authController.registerFormKey,
      child: SingleChildScrollView(
        key: const PageStorageKey("signup"),
        padding: EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: BaseSpacing.sm),

            // ── Profile photo ────────────────────────────────────────────
            Row(
              spacing: 10,
              children: [
                _ProfilePhotoPicker(controller: authController),
                Expanded(
                  child: Column(
                    children: [
                      CustomTextField(
                        hintText: 'First name',
                        prefixIcon: SvgIcon(
                          assetName: AppIcons.profileIcon,
                          color: AppColors.gray600,
                        ),
                        isborder: true,

                        controller: authController.registerFirstNameController,
                        validator: authController.validateName,
                      ),
                      SizedBox(height: BaseSpacing.xs + 2),
                      CustomTextField(
                        hintText: 'Last name',
                        prefixIcon: SvgIcon(
                          assetName: AppIcons.profileIcon,
                          color: AppColors.gray600,
                        ),
                        isborder: true,

                        controller: authController.registerLastNameController,
                        validator: authController.validateName,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: BaseSpacing.md),

            // ── Email ─────────────────────────────────────────────────────
            CustomTextField(
              hintText: 'Email address',
              isborder: true,

              prefixIcon: SvgIcon(
                assetName: AppIcons.emailIcon,
                color: AppColors.gray600,
              ),
              controller: authController.registerEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: authController.validateEmail,
            ),
            SizedBox(height: BaseSpacing.xs),

            // ── Phone ─────────────────────────────────────────────────────
            CustomTextField(
              hintText: 'Mobile number',
              isborder: true,

              controller: authController.registerPhoneController,
              keyboardType: TextInputType.phone,
              validator: authController.validatePhone,
              prefixIcon: SvgIcon(
                assetName: AppIcons.phoneIcon,
                color: AppColors.lightGrey,
              ),
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── Address ───────────────────────────────────────────────────
            CustomTextField(
              hintText: 'Address',
              isborder: true,

              controller: authController.registerAddressController,
              keyboardType: TextInputType.streetAddress,
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: AppColors.gray600,
                size: 20,
              ),
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── Password ──────────────────────────────────────────────────
            Obx(
              () => CustomTextField(
                hintText: 'Password',
                isborder: true,
                filled: true,
                prefixIcon: SvgIcon(
                  assetName: AppIcons.lockPassword,
                  color: AppColors.gray600,
                ),
                controller: authController.registerPasswordController,
                obscureText: !authController.isPasswordVisible.value,
                validator: authController.validatePassword,
                suffixIcon: SvgIcon(
                  assetName: authController.isPasswordVisible.value
                      ? AppIcons.hidePassword
                      : AppIcons.showPassword,
                  color: AppColors.grey,
                  onTap: () => authController.togglePasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── Confirm password ──────────────────────────────────────────
            Obx(
              () => CustomTextField(
                hintText: 'Confirm password',
                isborder: true,
                filled: true,
                prefixIcon: SvgIcon(
                  assetName: AppIcons.lockPassword,
                  color: AppColors.gray600,
                ),
                controller: authController.registerConfirmPasswordController,
                obscureText: !authController.isConfirmPasswordVisible.value,
                validator: authController.validateConfirmPassword,
                suffixIcon: SvgIcon(
                  assetName: authController.isConfirmPasswordVisible.value
                      ? AppIcons.hidePassword
                      : AppIcons.showPassword,
                  color: AppColors.grey,
                  onTap: () => authController.toggleConfirmPasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: BaseSpacing.sm),

            // ── Sign up button ────────────────────────────────────────────
            Obx(
              () => PrimaryButton(
                label: authController.isLoading.value
                    ? 'Creating Account…'
                    : 'Create Account',
                isLoading: authController.isLoading.value,
                onPressed: authController.isLoading.value
                    ? null
                    : authController.register,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile photo picker — dashed circle + camera badge ─────────────────────

class _ProfilePhotoPicker extends StatelessWidget {
  const _ProfilePhotoPicker({required this.controller});
  final AuthController controller;

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.pickRegisterProfileImage,
      child: Column(
        children: [
          Obx(() {
            final file = controller.registerProfileImage.value;
            return SizedBox(
              width: _size,
              height: _size,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(_size, _size),
                    painter: _DashedCirclePainter(color: AppColors.lightGrey2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: file != null
                          ? CommonImageView(
                              file: file,
                              fit: BoxFit.cover,
                              width: _size - 8,
                              height: _size - 8,
                            )
                          : Container(
                              color: AppColors.background,
                              alignment: Alignment.center,
                              child: SvgIcon(
                                assetName: AppIcons.profileIcon,
                                size: 40,
                                color: AppColors.lightGrey,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: controller.isPickingRegisterImage.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const SvgIcon(
                              assetName: AppIcons.uploadImageIcon,
                              size: 15,
                              color: AppColors.white,
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: BaseSpacing.xs),
          CustomText(
            text: 'Add profile photo',
            color: AppColors.primaryColor,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    const dashCount = 36;
    const dashSweep = 360 / dashCount * 0.6 * (3.1415926535 / 180);
    const gapSweep = 360 / dashCount * 0.4 * (3.1415926535 / 180);
    double angle = 0;
    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 1),
        angle,
        dashSweep,
        false,
        paint,
      );
      angle += dashSweep + gapSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
