import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Save Draft + Submit for Review — only shown while the store's status
/// still allows edits (`c.isEditable`); a rejected/under_review/active store
/// has nothing left to save here.
class VerificationBottomBar extends StatelessWidget {
  final StoreVerificationController c;
  final double bottomInset;

  const VerificationBottomBar({
    super.key,
    required this.c,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // `canSubmit`/`submitBlockedReason` read plain TextEditingControllers —
      // touching `formRevision` here is what makes this Obx rebuild as the
      // seller types (the controllers bump it via a listener).
      c.formRevision.value;
      if (!c.isEditable) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.fromLTRB(
          BaseSpacing.md,
          BaseSpacing.sm,
          BaseSpacing.md,
          BaseSpacing.sm + bottomInset,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: c.submitBlockedReason,
              fontSize: AppFontSize.tiny,
              color: c.canSubmit ? AppColors.greenSuccess : AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: BaseSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    label: 'Save Draft',
                    isLoading: c.isSaving.value,
                    onPressed: c.isSaving.value ? null : c.saveDraft,
                  ),
                ),
                SizedBox(width: BaseSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Submit for Review',
                    isLoading: c.isSubmitting.value,
                    onPressed: (c.canSubmit && !c.isSubmitting.value)
                        ? c.submit
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
