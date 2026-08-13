import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/store_verification/controllers/store_verification_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows the rejection reason prominently (when `verificationStatus ==
/// 'rejected'`) or a short explainer that the form is locked while
/// submitted/under review/verified. Deliberately keys off
/// [StoreVerificationController.verificationStatus], NOT `storeStatus` — a
/// resubmission flips `verificationStatus` back to `pending` immediately
/// while the store's marketplace `status` stays `rejected` until the next
/// admin decision, and this banner must track the former, not the latter.
class VerificationStatusBanner extends StatelessWidget {
  final StoreVerificationController c;
  const VerificationStatusBanner({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = c.verificationStatus.value;
      final reason = c.rejectionReason.value;

      if (status == 'rejected') {
        return _Banner(
          icon: Icons.error_outline_rounded,
          color: AppColors.red,
          title: 'Resubmission required',
          message: reason.isNotEmpty
              ? reason
              : 'Your verification was rejected. Please review and resubmit your details.',
        );
      }

      if (!c.isEditable) {
        final String message;
        switch (status) {
          case 'under_review':
            message =
                'Your verification is under review. These details are locked until a decision is made.';
            break;
          case 'pending':
            message =
                'Your verification has been submitted and is awaiting review.';
            break;
          default:
            message =
                'These details are locked because your store verification has already been processed.';
        }
        return _Banner(
          icon: Icons.lock_outline_rounded,
          color: AppColors.grey,
          title: 'Details locked',
          message: message,
        );
      }

      return const SizedBox.shrink();
    });
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _Banner({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: message,
                  fontSize: AppFontSize.tiny,
                  color: AppColors.black2,
                  height: 1.4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
