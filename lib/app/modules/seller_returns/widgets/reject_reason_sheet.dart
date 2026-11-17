import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet collecting the reject reason (`notes`, min 3 / max 500 chars
/// server-side) before calling `SellerReturnsController.reject` — mirrors
/// `_PlanFormSheet` (subscription_plans_tab.dart) for the modal shell +
/// submit pattern.
class RejectReasonSheet extends StatefulWidget {
  final SellerReturnsController controller;
  final RefundRequestModel item;

  const RejectReasonSheet({super.key, required this.controller, required this.item});

  static void show(BuildContext context, SellerReturnsController controller, RefundRequestModel item) {
    Get.bottomSheet(
      RejectReasonSheet(controller: controller, item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<RejectReasonSheet> {
  late final TextEditingController _reasonCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _reasonCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty || _submitting) return;

    setState(() => _submitting = true);
    await widget.controller.reject(widget.item, reason);
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: EdgeInsets.only(bottom: BaseSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                CustomText(
                  text: 'Reject Return Request',
                  color: AppColors.black2,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: BaseSpacing.sm),
                CustomText(
                  text:
                      '${widget.item.itemIds.length} item${widget.item.itemIds.length == 1 ? '' : 's'} · Order #${widget.item.orderId.length > 8 ? widget.item.orderId.substring(widget.item.orderId.length - 8) : widget.item.orderId}',
                  color: AppColors.grey,
                  fontSize: AppFontSize.verySmall,
                ),
                SizedBox(height: BaseSpacing.md),
                CustomTextField(
                  label: 'Reason for rejection',
                  hintText: 'e.g. Item shows signs of use beyond normal wear',
                  controller: _reasonCtrl,
                  isborder: true,
                  maxLines: 3,
                ),
                SizedBox(height: BaseSpacing.lg),
                GestureDetector(
                  onTap: _submitting ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : CustomText(
                            text: 'Reject Return',
                            color: AppColors.white,
                            fontSize: AppFontSize.small,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
