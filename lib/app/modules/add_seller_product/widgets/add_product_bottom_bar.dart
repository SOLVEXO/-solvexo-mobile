import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductBottomBar extends StatelessWidget {
  final AddSellerProductController controller;

  const AddProductBottomBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      final isLast = controller.isOnLastStep;
      final canProceed = controller.canProceed;
      final isSaving = controller.isSaving.value;

      return Container(
        padding: EdgeInsets.fromLTRB(
          AppDimen.allPadding,
          12,
          AppDimen.allPadding,
          12 + bottomInset,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isLast) ...[
              _BackButton(onTap: controller.goBack),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: _PrimaryButton(
                label: isLast
                    ? (controller.saveAsDraft.value ? 'Save Draft' : 'Publish')
                    : 'Continue',
                icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                isLoading: isSaving,
                isEnabled: canProceed,
                onTap: isLast ? controller.publish : controller.goNext,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(color: AppColors.lightGrey2),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: AppColors.black2,
            ),
            SizedBox(width: 6),
            CustomText(
              text: 'Back',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.black2,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled && !isLoading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primaryColor
              : AppColors.primaryColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: label,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: AppColors.white),
                ],
              ),
      ),
    );
  }
}
