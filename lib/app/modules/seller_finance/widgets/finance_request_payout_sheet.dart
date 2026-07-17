import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/finance/payout_method_model.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_payout_methods_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinanceRequestPayoutSheet extends StatefulWidget {
  final SellerFinanceController controller;
  const FinanceRequestPayoutSheet({super.key, required this.controller});

  static void show(BuildContext context, SellerFinanceController controller) {
    Get.bottomSheet(
      FinanceRequestPayoutSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<FinanceRequestPayoutSheet> createState() => _FinanceRequestPayoutSheetState();
}

class _FinanceRequestPayoutSheetState extends State<FinanceRequestPayoutSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _notesCtrl;
  String? _selectedMethodId;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    final methods = widget.controller.payoutMethods;
    final active = methods.where((m) => m.isActive).toList();
    final defaults = active.where((m) => m.isDefault);
    _selectedMethodId = defaults.isNotEmpty ? defaults.first.id : (active.isNotEmpty ? active.first.id : null);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount < 1) {
      Get.snackbar('Invalid amount', 'Enter an amount of at least \$1.00', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedMethodId == null) {
      Get.snackbar('No payout method', 'Add a payout method first.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final ok = await widget.controller.requestPayout(
      amount: amount,
      payoutMethodId: _selectedMethodId!,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.lg, BaseSpacing.sm, BaseSpacing.lg, BaseSpacing.lg),
            child: SingleChildScrollView(
              child: Obx(() {
                final methods = widget.controller.payoutMethods;
                final activeMethods = methods.where((m) => m.isActive).toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(bottom: BaseSpacing.md),
                        decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    CustomText(text: 'Request Payout', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                    const SizedBox(height: 4),
                    CustomText(
                      text: 'Available balance: \$${widget.controller.availableBalance.toStringAsFixed(2)}',
                      color: AppColors.lightGrey5,
                      fontSize: AppFontSize.tiny,
                    ),
                    const SizedBox(height: BaseSpacing.md),
                    if (activeMethods.isEmpty)
                      _NoMethodsPrompt(controller: widget.controller)
                    else ...[
                      CustomText(text: 'Payout Method', color: AppColors.black2, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600),
                      const SizedBox(height: 8),
                      ...activeMethods.map((m) => _MethodRadioTile(
                            method: m,
                            selected: _selectedMethodId == m.id,
                            onTap: () => setState(() => _selectedMethodId = m.id),
                          )),
                      const SizedBox(height: BaseSpacing.sm),
                      CustomTextField(
                        label: 'Amount (USD)',
                        hintText: '0.00',
                        controller: _amountCtrl,
                        isborder: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: BaseSpacing.sm),
                      CustomTextField(label: 'Notes (optional)', controller: _notesCtrl, isborder: true, maxLines: 2),
                      const SizedBox(height: BaseSpacing.lg),
                      Obx(
                        () => GestureDetector(
                          onTap: widget.controller.isRequestingPayout.value ? null : _submit,
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 50),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
                            child: widget.controller.isRequestingPayout.value
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                                : CustomText(text: 'Request Payout', color: AppColors.white, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodRadioTile extends StatelessWidget {
  final PayoutMethodModel method;
  final bool selected;
  final VoidCallback onTap;
  const _MethodRadioTile({required this.method, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor.withOpacity(0.06) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey11),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 18,
              color: selected ? AppColors.primaryColor : AppColors.lightGrey5,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomText(
                text: method.displayLabel,
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
            if (method.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppColors.darkGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: const CustomText(text: 'Default', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoMethodsPrompt extends StatelessWidget {
  final SellerFinanceController controller;
  const _NoMethodsPrompt({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'You need an active payout method before requesting a payout.',
          color: AppColors.lightGrey5,
          fontSize: AppFontSize.verySmall,
        ),
        const SizedBox(height: BaseSpacing.md),
        GestureDetector(
          onTap: () {
            Get.back();
            FinancePayoutMethodFormSheet.show(context, controller);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const CustomText(text: 'Add Payout Method', color: AppColors.white, fontSize: AppFontSize.small2, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
