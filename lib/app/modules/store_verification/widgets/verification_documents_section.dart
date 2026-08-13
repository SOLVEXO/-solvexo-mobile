import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_form_widgets.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// One upload row per document type in the backend's checklist — required
/// types come from `documents[].required` (authoritative), never a
/// hardcoded business-type switch. Optional documents (e.g.
/// `authorization_proof`) get their own section below, same row widget.
class VerificationDocumentsSection extends StatelessWidget {
  final StoreVerificationController c;
  const VerificationDocumentsSection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: verificationCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerificationSectionTitle('REQUIRED DOCUMENTS'),
          const SizedBox(height: 4),
          Obx(() {
            final docs = c.requiredDocs;
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 10),
                child: CustomText(
                  text: 'No documents are required yet — pick a business type first.',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.grey,
                ),
              );
            }
            return Column(
              children: [
                const SizedBox(height: 10),
                for (int i = 0; i < docs.length; i++) ...[
                  if (i != 0)
                    const Divider(height: 1, color: AppColors.lightGrey2),
                  _DocumentRow(c: c, type: docs[i].type),
                ],
              ],
            );
          }),
          Obx(() {
            final docs = c.optionalDocs;
            if (docs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const VerificationSectionTitle('OPTIONAL DOCUMENTS'),
                const SizedBox(height: 10),
                for (int i = 0; i < docs.length; i++) ...[
                  if (i != 0)
                    const Divider(height: 1, color: AppColors.lightGrey2),
                  _DocumentRow(c: c, type: docs[i].type),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final StoreVerificationController c;
  final String type;
  const _DocumentRow({required this.c, required this.type});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final doc = c.documentFor(type);
      final isUploading = c.uploadingTypes.contains(type);
      final uploaded = doc?.isUploaded ?? false;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (uploaded ? AppColors.greenSuccess : AppColors.grey)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                uploaded
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                size: 18,
                color: uploaded ? AppColors.greenSuccess : AppColors.grey,
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: type.documentTypeLabel,
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: (uploaded && (doc?.viewUrl ?? '').isNotEmpty)
                        ? () => _openDoc(doc!.viewUrl!)
                        : null,
                    child: CustomText(
                      text: uploaded ? (doc?.fileName ?? '') : 'Not uploaded',
                      fontSize: AppFontSize.tiny,
                      color: uploaded
                          ? AppColors.primaryColor
                          : AppColors.lightGrey5,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            _UploadButton(
              uploaded: uploaded,
              isUploading: isUploading,
              enabled: c.isEditable,
              onTap: () => c.pickAndUploadDocument(type),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _openDoc(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _UploadButton extends StatelessWidget {
  final bool uploaded;
  final bool isUploading;
  final bool enabled;
  final VoidCallback onTap;

  const _UploadButton({
    required this.uploaded,
    required this.isUploading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isUploading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor,
        ),
      );
    }
    if (!enabled) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: uploaded
              ? AppColors.background
              : AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: uploaded ? Border.all(color: AppColors.lightGrey2) : null,
        ),
        child: CustomText(
          text: uploaded ? 'Replace' : 'Upload',
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
          color: uploaded ? AppColors.grey : AppColors.primaryColor,
        ),
      ),
    );
  }
}
