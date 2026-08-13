import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_form_widgets.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Business type picker + core business info fields (legal name,
/// registration number, tax ID, address, ID document type).
class VerificationBusinessSection extends StatelessWidget {
  final StoreVerificationController c;
  const VerificationBusinessSection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: verificationCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerificationSectionTitle('BUSINESS INFORMATION'),
          const SizedBox(height: 14),

          const VerificationFieldLabel('Business Type'),
          const SizedBox(height: 6),
          Obx(
            () => VerificationPickerField(
              displayValue: c.businessType.value.isEmpty
                  ? ''
                  : c.businessType.value.businessTypeLabel,
              placeholder: 'Select business type',
              enabled: c.isEditable,
              onTap: c.pickBusinessType,
            ),
          ),
          const SizedBox(height: 16),

          const VerificationFieldLabel('Legal Business Name', required: true),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.legalBusinessNameCtrl,
              hintText: 'e.g. Creative Classroom Resources LLC',
              enabled: c.isEditable,
            ),
          ),
          const SizedBox(height: 16),

          Obx(
            () => VerificationFieldLabel(
              'Registration Number',
              required: c.isBusinessLevel,
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.registrationNumberCtrl,
              hintText: 'Business registration / incorporation number',
              enabled: c.isEditable,
            ),
          ),
          const SizedBox(height: 16),

          Obx(
            () => VerificationFieldLabel(
              'Tax ID',
              required: c.isBusinessLevel,
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.taxIdCtrl,
              hintText: 'Tax registration number',
              enabled: c.isEditable,
            ),
          ),
          const SizedBox(height: 16),

          const VerificationFieldLabel('Business Address', required: true),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.businessAddressCtrl,
              hintText: 'Full registered business address',
              enabled: c.isEditable,
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 16),

          const VerificationFieldLabel('ID Document Type', required: true),
          const SizedBox(height: 6),
          Obx(
            () => VerificationPickerField(
              displayValue: c.idDocumentType.value.isEmpty
                  ? ''
                  : c.idDocumentType.value.idDocumentTypeLabel,
              placeholder: 'Select ID document type',
              enabled: c.isEditable,
              onTap: c.pickIdDocumentType,
            ),
          ),
        ],
      ),
    );
  }
}
