import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductStepIndicator extends StatelessWidget {
  final AddSellerProductController controller;

  const AddProductStepIndicator({super.key, required this.controller});

  static const _steps = ['Type', 'Details'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 12,
      ),
      child: Obx(
        () => Row(
          children: List.generate(_steps.length * 2 - 1, (i) {
            if (i.isOdd) return _connector(i ~/ 2, controller.step.value);
            final index = i ~/ 2;
            return _StepDot(
              index: index,
              label: _steps[index],
              currentStep: controller.step.value,
            );
          }),
        ),
      ),
    );
  }

  Widget _connector(int afterIndex, AddProductStep current) {
    final passed = current.index > afterIndex;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: passed
              ? AppColors.primaryColor
              : AppColors.lightGrey2,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final AddProductStep currentStep;

  const _StepDot({
    required this.index,
    required this.label,
    required this.currentStep,
  });

  bool get _isActive => currentStep.index == index;
  bool get _isDone => currentStep.index > index;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = (_isActive || _isDone)
        ? AppColors.primaryColor
        : AppColors.lightGrey2;
    final Color textColor = (_isActive || _isDone)
        ? AppColors.primaryColor
        : AppColors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _isActive
                ? AppColors.primaryColor
                : (_isDone
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : AppColors.background),
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: _isDone
              ? const Icon(Icons.check_rounded, size: 14, color: AppColors.primaryColor)
              : CustomText(
                  text: '${index + 1}',
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.bold,
                  color: _isActive ? AppColors.white : AppColors.grey,
                ),
        ),
        const SizedBox(height: 4),
        CustomText(
          text: label,
          fontSize: AppFontSize.tiny,
          fontWeight: _isActive ? FontWeight.w600 : FontWeight.w400,
          color: textColor,
        ),
      ],
    );
  }
}
