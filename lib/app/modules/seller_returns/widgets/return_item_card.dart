import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/reject_reason_sheet.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/return_status_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReturnItemCard extends StatelessWidget {
  final SellerReturnItem item;
  final SellerReturnsController controller;

  const ReturnItemCard({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: item.orderNumber,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              ReturnStatusBadge(status: item.returnStatus),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (item.productImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CommonImageView(url: item.productImage, width: 44, height: 44),
                ),
              if (item.productImage != null) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: item.productName,
                      fontSize: AppFontSize.small2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      text: item.customerName,
                      fontSize: AppFontSize.verySmall,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
              CustomText(
                text: '\$${item.amount.toStringAsFixed(2)}',
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFamily: AppTextStyles.monoFontFamily,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            ),
            child: CustomText(
              text: item.returnStatus == ReturnStatus.rejected &&
                      item.returnRejectReason != null
                  ? 'Reason: ${item.returnReason}\nRejected: ${item.returnRejectReason}'
                  : 'Reason: ${item.returnReason}',
              fontSize: AppFontSize.verySmall,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 6),
          CustomText(
            text: item.returnRequestedAt,
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
          ),
          if (item.returnStatus == ReturnStatus.requested) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            Obx(() {
              final isBusy = controller.isProcessing(item.itemId);
              return Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      color: AppColors.red,
                      isLoading: false,
                      onTap: isBusy
                          ? null
                          : () => RejectReasonSheet.show(context, controller, item),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Approve',
                      color: AppColors.darkGreen,
                      isLoading: isBusy,
                      onTap: isBusy ? null : () => controller.approve(item),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : CustomText(
                text: label,
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: color,
              ),
      ),
    );
  }
}
