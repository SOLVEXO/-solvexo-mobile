import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_request_model.dart';
import 'package:book_store_app/app/modules/seller_promotions/controllers/seller_promotions_controller.dart';
import 'package:book_store_app/app/modules/seller_promotions/views/promotion_detail_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Color promotionStatusColor(String status) {
  switch (status) {
    case 'active':
      return AppColors.greenSuccess;
    case 'approved':
      return AppColors.amberDark;
    case 'rejected':
    case 'cancelled':
      return AppColors.red;
    case 'paused':
    case 'expired':
      return AppColors.iosGrey;
    case 'pending':
    default:
      return AppColors.gray600;
  }
}

Color _paymentStatusColor(String status) {
  switch (status) {
    case 'paid':
      return AppColors.greenSuccess;
    case 'failed':
      return AppColors.red;
    case 'refunded':
      return AppColors.iosGrey;
    case 'pending':
    default:
      return AppColors.amberDark;
  }
}

String _paymentStatusLabel(String status) {
  switch (status) {
    case 'paid':
      return 'Paid';
    case 'failed':
      return 'Payment Failed';
    case 'refunded':
      return 'Refunded';
    case 'pending':
    default:
      return 'Payment Pending';
  }
}

/// One promotion request card for [SellerPromotionsView]'s list — creative
/// thumbnail, placement + status, date range, price, and the pay/cancel
/// actions gated by [PromotionRequestModel.canPay]/[canCancel]. Tapping the
/// card opens [PromotionDetailView] for the full timeline.
class PromotionCard extends StatelessWidget {
  final PromotionRequestModel request;
  final SellerPromotionsController controller;

  const PromotionCard({super.key, required this.request, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PromotionDetailView(request: request)),
      child: Container(
        margin: EdgeInsets.only(bottom: BaseSpacing.sm),
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(BaseRadius.md),
                  child: CommonImageView(
                    url: request.creativeUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: BaseSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: kPromotionPlacementLabels[request.placement] ?? request.placement,
                        fontSize: AppFontSize.verySmall,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: BaseSpacing.xxs),
                      Wrap(
                        spacing: BaseSpacing.xxs,
                        runSpacing: BaseSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _Pill(text: promotionStatusLabel(request.status), color: promotionStatusColor(request.status)),
                          if (request.status == 'approved' || request.isPaid || request.status == 'active')
                            _Pill(text: _paymentStatusLabel(request.paymentStatus), color: _paymentStatusColor(request.paymentStatus)),
                        ],
                      ),
                      SizedBox(height: BaseSpacing.xxs),
                      CustomText(
                        text:
                            '${DateFormat('MMM d').format(request.startAt.toLocal())} – ${DateFormat('MMM d, yyyy').format(request.endAt.toLocal())}',
                        fontSize: AppFontSize.tiny,
                        color: AppColors.gray600,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: BaseSpacing.xs),
                CustomText(
                  text: '\$${request.priceUSD.toStringAsFixed(2)}',
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                  fontFamily: AppTextStyles.monoFontFamily,
                ),
              ],
            ),
            if (request.isRejected && (request.rejectionReason?.isNotEmpty ?? false)) ...[
              SizedBox(height: BaseSpacing.xs),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xxs),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(BaseRadius.sm),
                ),
                child: CustomText(
                  text: request.rejectionReason!,
                  fontSize: AppFontSize.tiny,
                  color: AppColors.red,
                ),
              ),
            ],
            if (request.canPay || request.canCancel) ...[
              SizedBox(height: BaseSpacing.sm),
              Row(
                children: [
                  if (request.canPay)
                    Expanded(
                      child: Obx(
                        () => PrimaryButton(
                          label: 'Pay Now',
                          compact: true,
                          isLoading: controller.payingId.value == request.id,
                          onPressed: controller.payingId.value != null ? null : () => controller.payNow(request),
                        ),
                      ),
                    ),
                  if (request.canPay && request.canCancel) SizedBox(width: BaseSpacing.xs),
                  if (request.canCancel)
                    Expanded(
                      child: Obx(
                        () => OutlineButton(
                          label: 'Cancel',
                          compact: true,
                          isLoading: controller.cancelingId.value == request.id,
                          onPressed: controller.cancelingId.value != null ? null : () => _confirmCancel(context),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    CustomConfirmDialog.show(
      context,
      title: 'Cancel Promotion?',
      message: request.isActive
          ? 'This promotion will be taken down immediately. This cannot be undone.'
          : 'This request will be cancelled. This cannot be undone.',
      confirmLabel: 'Cancel Promotion',
      confirmColor: AppColors.red,
      onConfirm: () => controller.cancelRequest(request.id),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs + 3, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(BaseRadius.pill)),
      child: CustomText(text: text, fontSize: 10.5, fontWeight: FontWeight.w700, color: color),
    );
  }
}
