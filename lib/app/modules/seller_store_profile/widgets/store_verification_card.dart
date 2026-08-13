import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/common_models/store_status_style.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// CTA card pointing sellers at business/KYC verification — shown right
/// after the hero/stats strip so a pending/rejected seller sees it first.
///
/// Combines `store.status` (marketplace listing: `pending|active|rejected|
/// suspended`) with `store.verificationStatus` (the KYC review's own state:
/// `not_started|pending|under_review|verified|rejected`) — they're
/// deliberately separate fields (see `store.schema.ts`).
class StoreVerificationCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreVerificationCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: _cardDeco(),
        child: Obx(() {
          final status = c.store.value?.status ?? '';
          final verificationStatus = c.store.value?.verificationStatus ?? '';
          final storeId = c.store.value?.id ?? '';

          final Color color;
          final String label;
          if (status == 'active') {
            final style = storeStatusStyle('active');
            color = style.color;
            label = style.label;
          } else if (status == 'suspended') {
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.verified_user_rounded,
                      size: 18,
                      color: color,
                    ),
                  ),
                  SizedBox(width: BaseSpacing.sm),
                  const Expanded(
                    child: CustomText(
                      text: 'Business Verification',
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black2,
                    ),
                  ),
                  _StatusChip(color: color, label: label),
                ],
              ),
              const SizedBox(height: 10),
              CustomText(
                text: _description(status, verificationStatus),
                fontSize: AppFontSize.tiny,
                color: AppColors.grey,
                height: 1.45,
              ),
              const SizedBox(height: 12),
              OutlineButton(
                label: _ctaLabel(status, verificationStatus),
                compact: true,
                expand: false,
                onPressed: storeId.isEmpty
                    ? null
                    : () => Get.toNamed(
                        Routes.storeVerification,
                        arguments: storeId,
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _description(String status, String verificationStatus) {
    if (status == 'active') {
      return 'Your business details are verified. Buyers can see your store is trusted.';
    }
    if (status == 'suspended') {
      return 'Your store is suspended. Contact support for details.';
    }
    switch (verificationStatus) {
      case 'under_review':
        return 'Your verification is being reviewed. We\'ll notify you once a decision is made.';
      case 'pending':
        return 'Your verification has been submitted and is awaiting review.';
      case 'rejected':
        return 'Your last submission was rejected. Review the reason and resubmit.';
      default: // 'not_started'
        return 'Complete your business verification to build trust with buyers and unlock full store access.';
    }
  }

  String _ctaLabel(String status, String verificationStatus) {
    if (status == 'active') return 'View Details';
    if (status == 'suspended') return 'View Details';
    switch (verificationStatus) {
      case 'under_review':
      case 'pending':
        return 'View Status';
      case 'rejected':
        return 'Resubmit';
      default:
        return 'Start Verification';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: label,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [
    BoxShadow(
      color: AppColors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
);
