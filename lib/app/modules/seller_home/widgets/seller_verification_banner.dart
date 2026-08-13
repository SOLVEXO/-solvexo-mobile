import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/common_models/store_status_style.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Persistent reminder on the dashboard while the store isn't `active` yet
/// — a seller can back out of (or never open) the one-time verification
/// redirect right after onboarding, so this keeps the requirement visible
/// on every visit instead of only at that one moment. Mirrors
/// `StoreVerificationCard` (seller_store_profile) but reads from
/// [SellerHomeController], which this screen already has, instead of
/// pulling in that unrelated module's controller.
///
/// Reads `storeStatus` (marketplace listing: `pending|active|rejected|
/// suspended`) AND `storeVerificationStatus` (the KYC review's own state:
/// `not_started|pending|under_review|verified|rejected`) — they're
/// deliberately separate fields (see `store.schema.ts`), and after a
/// resubmission `storeStatus` can still read 'rejected' while
/// `storeVerificationStatus` has already moved on to 'pending'/'under_review'.
class SellerVerificationBanner extends StatelessWidget {
  const SellerVerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SellerHomeController>();

    return Obx(() {
      final storeStatus = controller.storeStatus.value;
      // Nothing to show once approved, or before the store status has
      // loaded at all (avoids a flash of the banner on first frame).
      if (storeStatus.isEmpty || storeStatus == 'active') {
        return const SizedBox.shrink();
      }

      final isSuspended = storeStatus == 'suspended';
      final verificationStatus = controller.storeVerificationStatus.value;
      final Color color;
      final String label;
      if (isSuspended) {
        final style = storeStatusStyle('suspended');
        color = style.color;
        label = style.label;
      } else {
        final style = verificationStatusStyle(
          verificationStatus.isEmpty ? 'not_started' : verificationStatus,
        );
        color = style.color;
        label = style.label;
      }
      final rejectionReason = controller.storeRejectionReason.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimen.allPadding,
          16,
          AppDimen.allPadding,
          0,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppDimen.allPadding),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_rounded, size: 18, color: color),
                  SizedBox(width: BaseSpacing.sm),
                  Expanded(
                    child: CustomText(
                      text: label,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CustomText(
                text: _description(isSuspended, verificationStatus, rejectionReason),
                fontSize: AppFontSize.tiny,
                color: AppColors.grey,
                height: 1.45,
              ),
              if (!isSuspended) ...[
                const SizedBox(height: 12),
                OutlineButton(
                  label: _ctaLabel(verificationStatus),
                  compact: true,
                  expand: false,
                  onPressed: controller.storeId.value.isEmpty
                      ? null
                      : () => Get.toNamed(
                          Routes.storeVerification,
                          arguments: controller.storeId.value,
                        ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  String _description(bool isSuspended, String verificationStatus, String rejectionReason) {
    if (isSuspended) return 'Your store is suspended. Contact support for details.';
    switch (verificationStatus) {
      case 'under_review':
        return "Your business verification is being reviewed. You can't publish products until it's approved.";
      case 'pending':
        return "Your verification has been submitted and is awaiting review.";
      case 'rejected':
        return rejectionReason.isNotEmpty
            ? 'Rejected: $rejectionReason. Fix the details and resubmit to start selling.'
            : 'Your submission was rejected. Review the reason and resubmit to start selling.';
      default: // 'not_started'
        return "Verify your business details to get approved — you can't publish products until then.";
    }
  }

  String _ctaLabel(String verificationStatus) {
    switch (verificationStatus) {
      case 'under_review':
      case 'pending':
        return 'View Status';
      case 'rejected':
        return 'Resubmit';
      default:
        return 'Complete Verification';
    }
  }
}
