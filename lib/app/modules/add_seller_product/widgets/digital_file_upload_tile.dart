import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable tile for a single digital product file upload.
/// Used by both the Add and Edit product forms.
class DigitalFileUploadTile extends StatelessWidget {
  final DigitalFileEntry entry;
  final VoidCallback onPickFile;
  final VoidCallback onRemove;

  const DigitalFileUploadTile({
    super.key,
    required this.entry,
    required this.onPickFile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                // ── Upload area ─────────────────────────────────────────────
                Obx(() {
                  final uploading = entry.isUploading.value;
                  final uploaded  = entry.isUploaded;

                  return GestureDetector(
                    onTap: uploading ? null : onPickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 13),
                      decoration: BoxDecoration(
                        color: uploaded
                            ? AppColors.darkGreen.withOpacity(0.05)
                            : AppColors.textfldFillColor,
                        borderRadius:
                            BorderRadius.circular(AppDimen.borderRadius),
                        border: Border.all(
                          color: uploaded
                              ? AppColors.darkGreen.withOpacity(0.35)
                              : uploading
                                  ? AppColors.primaryColor.withOpacity(0.4)
                                  : AppColors.lightGrey2,
                        ),
                      ),
                      child: uploading
                          ? _UploadingRow()
                          : uploaded
                              ? _UploadedRow(entry: entry)
                              : _IdleRow(),
                    ),
                  );
                }),

                const SizedBox(height: 6),

                // ── Display name override ───────────────────────────────────
                CustomTextField(
                  controller: entry.nameCtrl,
                  hintText: 'Display name (optional)',
                  isborder: true,
                  fillColor: AppColors.textfldFillColor,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Remove button ───────────────────────────────────────────────
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.remove_rounded,
                size: 18,
                color: AppColors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-states ────────────────────────────────────────────────────────────────

class _IdleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.upload_file_rounded,
            size: 18, color: AppColors.primaryColor.withOpacity(0.7)),
        const SizedBox(width: 8),
        CustomText(
          text: 'Tap to upload file',
          fontSize: AppFontSize.small2,
          color: AppColors.grey,
        ),
      ],
    );
  }
}

class _UploadingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        CustomText(
          text: 'Uploading…',
          fontSize: AppFontSize.small2,
          color: AppColors.primaryColor,
        ),
      ],
    );
  }
}

class _UploadedRow extends StatelessWidget {
  final DigitalFileEntry entry;
  const _UploadedRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 18, color: AppColors.darkGreen),
            const SizedBox(width: 8),
            Expanded(
              child: CustomText(
                text: entry.fileName.value,
                fontSize: AppFontSize.small2,
                color: AppColors.black2,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (entry.displaySize.isNotEmpty) ...[
              const SizedBox(width: 6),
              CustomText(
                text: entry.displaySize,
                fontSize: AppFontSize.tiny,
                color: AppColors.grey,
              ),
            ],
          ],
        ));
  }
}
