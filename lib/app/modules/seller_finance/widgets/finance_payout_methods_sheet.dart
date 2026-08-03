import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/finance/payout_method_model.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet listing a store's payout methods (bank/PayPal/Stripe) with
/// set-default/edit/delete actions, plus an "Add" entry point that opens
/// [FinancePayoutMethodFormSheet].
class FinancePayoutMethodsSheet extends StatelessWidget {
  final SellerFinanceController controller;
  const FinancePayoutMethodsSheet({super.key, required this.controller});

  static void show(BuildContext context, SellerFinanceController controller) {
    Get.bottomSheet(
      FinancePayoutMethodsSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmDelete(BuildContext context, PayoutMethodModel method) {
    CustomConfirmDialog.show(
      context,
      title: 'Remove payout method?',
      message: method.isDefault
          ? 'This is your default payout method — set another as default first.'
          : '"${method.displayLabel}" will no longer be available for payouts.',
      confirmLabel: 'Remove',
      confirmColor: AppColors.red,
      onConfirm: method.isDefault ? null : () => controller.deletePayoutMethod(method.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: BaseSpacing.md),
                  decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              CustomText(text: 'Payout Methods', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
              const SizedBox(height: BaseSpacing.md),
              Flexible(
                child: Obx(() {
                  final methods = controller.payoutMethods;
                  if (controller.isLoadingPayoutMethods.value && methods.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor)),
                    );
                  }
                  if (methods.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: CustomText(
                        text: 'No payout methods yet. Add a bank account, PayPal, or Stripe account to receive payouts.',
                        color: AppColors.lightGrey5,
                        fontSize: AppFontSize.verySmall,
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: methods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _MethodTile(
                      method: methods[i],
                      onSetDefault: () => controller.setDefaultPayoutMethod(methods[i].id),
                      onEdit: () => FinancePayoutMethodFormSheet.show(context, controller, existing: methods[i]),
                      onDelete: () => _confirmDelete(context, methods[i]),
                    ),
                  );
                }),
              ),
              const SizedBox(height: BaseSpacing.md),
              GestureDetector(
                onTap: () => FinancePayoutMethodFormSheet.show(context, controller),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_rounded, size: 16, color: AppColors.primaryColor),
                      SizedBox(width: 6),
                      CustomText(text: 'Add Payout Method', color: AppColors.primaryColor, fontSize: AppFontSize.small2, fontWeight: FontWeight.w700),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PayoutMethodModel method;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MethodTile({required this.method, required this.onSetDefault, required this.onEdit, required this.onDelete});

  IconData get _icon {
    switch (method.type) {
      case 'jazzcash':
      case 'easypaisa':
        return Icons.phone_android_rounded;
      case 'paypal':
        return Icons.account_balance_wallet_rounded;
      case 'stripe':
        return Icons.credit_card_rounded;
      case 'bank_transfer':
      default:
        return Icons.account_balance_rounded;
    }
  }

  /// pending_verification (amber) / inactive (grey) — active methods show
  /// no status pill at all, matching the existing "only mention it when it's
  /// not the happy path" convention.
  ({Color color, String label})? get _statusBadge {
    switch (method.status) {
      case 'pending_verification':
        return (color: const Color(0xFFD97706), label: 'Pending Verification');
      case 'inactive':
        return (color: AppColors.lightGrey5, label: 'Inactive');
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBadge = _statusBadge;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(_icon, size: 17, color: AppColors.primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(
                            text: '${method.displayLabel} · ${method.currency}',
                            fontSize: AppFontSize.verySmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (method.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.darkGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                            child: const CustomText(text: 'Default', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkGreen),
                          ),
                        ],
                      ],
                    ),
                    if (statusBadge != null) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: statusBadge.color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: CustomText(text: statusBadge.label, fontSize: 10, fontWeight: FontWeight.w700, color: statusBadge.color),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.lightGrey5),
                onSelected: (v) {
                  switch (v) {
                    case 'default':
                      onSetDefault();
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => [
                  if (!method.isDefault) const PopupMenuItem(value: 'default', child: Text('Set as default')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
              ),
            ],
          ),
          if (method.accountTitleMismatchFlagged) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: CustomText(
                      text: method.accountTitleMismatchNote ?? 'Account title may not match your registered name — flagged for admin review.',
                      fontSize: AppFontSize.tiny,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Add/edit form for a single payout method — fields shown depend on [type].
class FinancePayoutMethodFormSheet extends StatefulWidget {
  final SellerFinanceController controller;
  final PayoutMethodModel? existing;
  const FinancePayoutMethodFormSheet({super.key, required this.controller, this.existing});

  static void show(BuildContext context, SellerFinanceController controller, {PayoutMethodModel? existing}) {
    Get.bottomSheet(
      FinancePayoutMethodFormSheet(controller: controller, existing: existing),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<FinancePayoutMethodFormSheet> createState() => _FinancePayoutMethodFormSheetState();
}

class _FinancePayoutMethodFormSheetState extends State<FinancePayoutMethodFormSheet> {
  late String _type;
  late String _currency;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _accountHolderCtrl;
  late final TextEditingController _accountNumberCtrl;
  late final TextEditingController _routingNumberCtrl;
  late final TextEditingController _externalAccountCtrl;
  bool _setAsDefault = false;

  bool get _isEdit => widget.existing != null;
  bool get _isMobileWallet => _type == 'jazzcash' || _type == 'easypaisa';

  /// jazzcash/easypaisa default to PKR, everything else to USD — the seller
  /// can still override via the currency chips below.
  static String _defaultCurrencyFor(String type) =>
      (type == 'jazzcash' || type == 'easypaisa') ? 'PKR' : 'USD';

  void _selectType(String type) {
    setState(() {
      _type = type;
      _currency = _defaultCurrencyFor(type);
    });
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? 'bank_transfer';
    _currency = e?.currency ?? _defaultCurrencyFor(_type);
    _bankNameCtrl = TextEditingController(text: e?.bankName ?? '');
    _accountHolderCtrl = TextEditingController(text: e?.accountHolder ?? '');
    _accountNumberCtrl = TextEditingController();
    _routingNumberCtrl = TextEditingController(text: e?.routingNumber ?? '');
    _externalAccountCtrl = TextEditingController(text: e?.externalAccountId ?? '');
    _setAsDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    _routingNumberCtrl.dispose();
    _externalAccountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Bank details apply to bank_transfer only; jazzcash/easypaisa/paypal/stripe
    // all store their single identifying value in externalAccountId (a mobile
    // number for wallets, an email/account-id for PayPal/Stripe).
    final isBank = _type == 'bank_transfer';
    bool ok;
    if (_isEdit) {
      ok = await widget.controller.updatePayoutMethod(
        widget.existing!.id,
        currency: _currency,
        bankName: isBank ? _bankNameCtrl.text.trim() : null,
        accountHolder: isBank ? _accountHolderCtrl.text.trim() : null,
        accountNumber: isBank ? _accountNumberCtrl.text.trim() : null,
        routingNumber: isBank ? _routingNumberCtrl.text.trim() : null,
        externalAccountId: !isBank ? _externalAccountCtrl.text.trim() : null,
      );
    } else {
      ok = await widget.controller.addPayoutMethod(
        type: _type,
        currency: _currency,
        bankName: isBank ? _bankNameCtrl.text.trim() : null,
        accountHolder: isBank ? _accountHolderCtrl.text.trim() : null,
        accountNumber: isBank ? _accountNumberCtrl.text.trim() : null,
        routingNumber: isBank ? _routingNumberCtrl.text.trim() : null,
        externalAccountId: !isBank ? _externalAccountCtrl.text.trim() : null,
        setAsDefault: _setAsDefault,
      );
    }
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
              child: Column(
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
                  CustomText(
                    text: _isEdit ? 'Edit Payout Method' : 'Add Payout Method',
                    color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: BaseSpacing.md),
                  if (!_isEdit) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TypeChip(label: 'Bank', selected: _type == 'bank_transfer', onTap: () => _selectType('bank_transfer')),
                        _TypeChip(label: 'JazzCash', selected: _type == 'jazzcash', onTap: () => _selectType('jazzcash')),
                        _TypeChip(label: 'EasyPaisa', selected: _type == 'easypaisa', onTap: () => _selectType('easypaisa')),
                        _TypeChip(label: 'PayPal', selected: _type == 'paypal', onTap: () => _selectType('paypal')),
                        _TypeChip(label: 'Stripe', selected: _type == 'stripe', onTap: () => _selectType('stripe')),
                      ],
                    ),
                    const SizedBox(height: BaseSpacing.sm),
                    CustomText(text: 'Currency', fontSize: AppFontSize.tiny, color: AppColors.lightGrey5, fontWeight: FontWeight.w600),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        _TypeChip(label: 'USD', selected: _currency == 'USD', onTap: () => setState(() => _currency = 'USD')),
                        _TypeChip(label: 'PKR', selected: _currency == 'PKR', onTap: () => setState(() => _currency = 'PKR')),
                      ],
                    ),
                    const SizedBox(height: BaseSpacing.sm),
                  ],
                  if (_type == 'bank_transfer') ...[
                    CustomTextField(label: 'Bank Name', hintText: 'e.g. Chase Bank', controller: _bankNameCtrl, isborder: true),
                    const SizedBox(height: BaseSpacing.sm),
                    CustomTextField(label: 'Account Holder', controller: _accountHolderCtrl, isborder: true),
                    const SizedBox(height: BaseSpacing.sm),
                    CustomTextField(
                      label: _isEdit ? 'Account Number (leave blank to keep current)' : 'Account Number',
                      hintText: '••••••••1234',
                      controller: _accountNumberCtrl,
                      isborder: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: BaseSpacing.sm),
                    CustomTextField(label: 'Routing Number', controller: _routingNumberCtrl, isborder: true, keyboardType: TextInputType.number),
                  ] else if (_isMobileWallet)
                    CustomTextField(
                      label: '${_type == 'jazzcash' ? 'JazzCash' : 'EasyPaisa'} Mobile Number',
                      hintText: '03XXXXXXXXX',
                      controller: _externalAccountCtrl,
                      isborder: true,
                      keyboardType: TextInputType.phone,
                    )
                  else
                    CustomTextField(
                      label: _type == 'paypal' ? 'PayPal Email' : 'Stripe Account ID',
                      hintText: _type == 'paypal' ? 'seller@paypal.com' : 'acct_xxxxxxxx',
                      controller: _externalAccountCtrl,
                      isborder: true,
                    ),
                  if (!_isEdit) ...[
                    const SizedBox(height: BaseSpacing.sm),
                    Row(
                      children: [
                        Switch(
                          value: _setAsDefault,
                          activeColor: AppColors.primaryColor,
                          onChanged: (v) => setState(() => _setAsDefault = v),
                        ),
                        CustomText(text: 'Set as default', fontSize: AppFontSize.verySmall, color: AppColors.black2, fontWeight: FontWeight.w600),
                      ],
                    ),
                  ],
                  const SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isSavingPayoutMethod.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
                        child: widget.controller.isSavingPayoutMethod.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : CustomText(text: _isEdit ? 'Save Changes' : 'Add Method', color: AppColors.white, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single selectable chip — used both for payout-method type and currency.
/// Deliberately NOT `Expanded` (unlike the old 3-chip `Row` this replaced) so
/// it can sit inside a `Wrap` and flow onto a second line on narrow screens
/// now that there are 5 method types instead of 3.
class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey11),
        ),
        child: CustomText(
          text: label,
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.white : AppColors.lightGrey5,
        ),
      ),
    );
  }
}
