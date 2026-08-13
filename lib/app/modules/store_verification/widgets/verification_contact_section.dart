import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/app/modules/store_verification/widgets/verification_form_widgets.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Authorized contact fields — the person the platform can reach about this
/// store's verification (name/designation/email/phone).
class VerificationContactSection extends StatelessWidget {
  final StoreVerificationController c;
  const VerificationContactSection({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: verificationCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VerificationSectionTitle('AUTHORIZED CONTACT'),
          const SizedBox(height: 14),

          const VerificationFieldLabel('Full Name', required: true),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.contactNameCtrl,
              hintText: 'e.g. Jane Doe',
              enabled: c.isEditable,
            ),
          ),
          const SizedBox(height: 16),

          const VerificationFieldLabel('Designation'),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.contactDesignationCtrl,
              hintText: 'e.g. Owner, Manager',
              enabled: c.isEditable,
            ),
          ),
          const SizedBox(height: 16),

          const VerificationFieldLabel('Email', required: true),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.contactEmailCtrl,
              hintText: 'name@business.com',
              enabled: c.isEditable,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),

          const VerificationFieldLabel('Phone', required: true),
          const SizedBox(height: 6),
          Obx(
            () => VerificationTextField(
              controller: c.contactPhoneCtrl,
              hintText: '+1 555 123 4567',
              enabled: c.isEditable,
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }
}
