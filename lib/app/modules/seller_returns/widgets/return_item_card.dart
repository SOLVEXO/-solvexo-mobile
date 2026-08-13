import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/reject_reason_sheet.dart';
import 'package:book_store_app/app/modules/seller_returns/widgets/return_status_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/currency_formatter.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// The `refund-request/seller/:storeId` list returns raw request documents —
/// no populated buyer name/product name/image the old `orders/returns`
/// endpoint used to shape — so this card surfaces only the fields the new
/// contract actually provides (order id, item count, reason, amounts, notes).
class ReturnItemCard extends StatelessWidget {
  final RefundRequestModel item;
  final SellerReturnsController controller;

  const ReturnItemCard({super.key, required this.item, required this.controller});

  String get _shortOrderId =>
      '#${item.orderId.length > 8 ? item.orderId.substring(item.orderId.length - 8) : item.orderId}';

  String get _itemCountLabel => '${item.itemIds.length} item${item.itemIds.length == 1 ? '' : 's'}';

  String _formatDate(DateTime dt) => DateFormat('MMM d, y · h:mm a').format(dt.toLocal());

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
                text: _shortOrderId,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              ReturnStatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 10),
          CustomText(
            text: _itemCountLabel,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            ),
            child: CustomText(
              text: item.isRejected && item.resolutionNotes != null && item.resolutionNotes!.isNotEmpty
                  ? 'Reason: ${item.reason}\nRejected: ${item.resolutionNotes}'
                  : 'Reason: ${item.reason}',
              fontSize: AppFontSize.verySmall,
              color: AppColors.gray600,
            ),
          ),
          if (item.isApproved && item.buyerRefundAmount != null) ...[
            const SizedBox(height: 8),
            CustomText(
              text: 'Refunded: ${CurrencyFormatter.amount(item.buyerRefundAmount!, item.buyerRefundCurrency)}',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
              fontFamily: AppTextStyles.monoFontFamily,
            ),
          ],
          const SizedBox(height: 6),
          CustomText(
            text: _formatDate(item.createdAt),
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
          ),
          if (item.isPending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            Obx(() {
              final isBusy = controller.isProcessing(item.id);
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
