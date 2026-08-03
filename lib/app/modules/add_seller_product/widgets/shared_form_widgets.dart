import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Label (+ optional hint/required marker) wrapper around a form field —
/// shared by the product-level form and per-variant cards.
class FormFieldSection extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  final bool required;

  const FormFieldSection({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
              text: label,
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.black2,
            ),
            if (required)
              const CustomText(
                text: ' *',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          CustomText(
            text: hint!,
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
          ),
        ],
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Horizontal image picker/thumbnail row — generic over whichever
/// `RxList<String>`/`RxBool` the caller injects, so it can be embedded once
/// at the product level and once per variant card without duplicating logic.
class ImagesSection extends StatelessWidget {
  final String label;
  final String hint;
  final RxList<String> images;
  final RxBool isUploading;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const ImagesSection({
    super.key,
    required this.label,
    required this.hint,
    required this.images,
    required this.isUploading,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return FormFieldSection(
      label: label,
      hint: hint,
      child: Obx(() {
        final imgs = images;
        final uploading = isUploading.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List.generate(imgs.length, (i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ImageThumbnail(
                      url: imgs[i],
                      onRemove: () => onRemove(i),
                    ),
                  )),
              if (uploading)
                const LoadingThumbnail()
              else if (imgs.length < 5)
                AddImageButton(onTap: onAdd),
            ],
          ),
        );
      }),
    );
  }
}

class ImageThumbnail extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  const ImageThumbnail({super.key, required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 80,
              height: 80,
              color: AppColors.textfldFillColor,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: AppColors.textfldFillColor,
              child: const Icon(Icons.broken_image_rounded,
                  color: AppColors.grey, size: 28),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 12, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingThumbnail extends StatelessWidget {
  const LoadingThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.textfldFillColor,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddImageButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.4),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                size: 26, color: AppColors.primaryColor),
            SizedBox(height: 4),
            CustomText(
              text: 'Add',
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Unlimited stock" placeholder badge shown instead of a stock count field.
class UnlimitedStockPlaceholder extends StatelessWidget {
  const UnlimitedStockPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.greenContainerInnerColor,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        border: Border.all(color: AppColors.darkGreen.withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.all_inclusive_rounded,
            size: 18,
            color: AppColors.darkGreen,
          ),
          SizedBox(width: 8),
          CustomText(
            text: 'Unlimited stock',
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGreen,
          ),
        ],
      ),
    );
  }
}

/// Generic unlimited-stock checkbox toggle bound to an injected RxBool, so
/// it can be reused for the product-level field and per-variant fields.
class UnlimitedStockToggle extends StatelessWidget {
  final RxBool value;
  const UnlimitedStockToggle({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () => value.toggle(),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value.value ? AppColors.primaryColor : AppColors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value.value ? AppColors.primaryColor : AppColors.lightGrey2,
                ),
              ),
              alignment: Alignment.center,
              child: value.value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'Unlimited stock',
              fontSize: AppFontSize.verySmall,
              color: AppColors.black2,
            ),
          ],
        ),
      ),
    );
  }
}
