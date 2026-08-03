import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/payment/manual_payment_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// Reusable pending/approved/rejected banner for a manual bank-transfer
/// proof — used on the status screen right after submission, and reusable
/// anywhere else a buyer needs to see "we're verifying your payment"
/// (e.g. an order-detail screen), so the messaging stays identical everywhere.
class ManualPaymentStatusBanner extends StatelessWidget {
  final ManualPaymentProof proof;
  const ManualPaymentStatusBanner({super.key, required this.proof});

  ({IconData icon, Color color, String title, String body}) get _visual {
    if (proof.isApproved) {
      return (
        icon: Icons.check_circle_rounded,
        color: AppColors.greenSuccess,
        title: 'Payment confirmed',
        body: 'Your bank transfer has been verified — your order is confirmed.',
      );
    }
    if (proof.isRejected) {
      return (
        icon: Icons.error_rounded,
        color: AppColors.error,
        title: 'Payment could not be verified',
        body: proof.rejectionReason?.isNotEmpty == true
            ? proof.rejectionReason!
            : 'Please re-upload your proof of payment.',
      );
    }
    return (
      icon: Icons.hourglass_top_rounded,
      color: AppColors.amberDark,
      title: "We're verifying your payment",
      body: "This usually takes a few hours. We'll notify you as soon as it's confirmed.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.md),
      decoration: BoxDecoration(
        color: v.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        border: Border.all(color: v.color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(v.icon, color: v.color, size: 26),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: v.title, color: v.color, fontSize: AppFontSize.small2, fontWeight: FontWeight.w700),
                SizedBox(height: BaseSpacing.xxs / 2),
                CustomText(text: v.body, color: AppColors.gray600, fontSize: AppFontSize.tiny),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
