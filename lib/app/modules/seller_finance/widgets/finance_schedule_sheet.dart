import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Edits `frequency`/`dayOfWeek`/`dayOfMonth`/`minimumAmount`/`isEnabled` on
/// the store's payout schedule (`PATCH .../payout-schedule`).
class FinanceScheduleSheet extends StatefulWidget {
  final SellerFinanceController controller;
  const FinanceScheduleSheet({super.key, required this.controller});

  static void show(BuildContext context, SellerFinanceController controller) {
    Get.bottomSheet(
      FinanceScheduleSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<FinanceScheduleSheet> createState() => _FinanceScheduleSheetState();
}

class _FinanceScheduleSheetState extends State<FinanceScheduleSheet> {
  static const _frequencies = ['daily', 'weekly', 'biweekly', 'monthly', 'manual'];
  static const _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  late String _frequency;
  late int _dayOfWeek;
  late final TextEditingController _dayOfMonthCtrl;
  late final TextEditingController _minimumCtrl;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final s = widget.controller.payoutSchedule.value;
    _frequency = s.frequency;
    _dayOfWeek = s.dayOfWeek;
    _dayOfMonthCtrl = TextEditingController(text: s.dayOfMonth.toString());
    _minimumCtrl = TextEditingController(text: s.minimumAmount.toStringAsFixed(2));
    _isEnabled = s.isEnabled;
  }

  @override
  void dispose() {
    _dayOfMonthCtrl.dispose();
    _minimumCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final minimum = double.tryParse(_minimumCtrl.text.trim());
    final dayOfMonth = int.tryParse(_dayOfMonthCtrl.text.trim());
    if (minimum == null || minimum < 1) {
      Get.snackbar(
        'Invalid amount',
        'Minimum payout amount must be at least 1.00 ${widget.controller.selectedCurrency.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final ok = await widget.controller.updatePayoutSchedule(
      frequency: _frequency,
      dayOfWeek: _frequency == 'weekly' ? _dayOfWeek : null,
      dayOfMonth: _frequency == 'monthly' ? (dayOfMonth ?? 1).clamp(1, 28) : null,
      minimumAmount: minimum,
      isEnabled: _isEnabled,
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
                  CustomText(text: 'Payout Schedule', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                  const SizedBox(height: BaseSpacing.md),
                  CustomText(text: 'Frequency', color: AppColors.black2, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _frequencies.map((f) {
                      final selected = _frequency == f;
                      return GestureDetector(
                        onTap: () => setState(() => _frequency = f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryColor : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey11),
                          ),
                          child: CustomText(
                            text: f[0].toUpperCase() + f.substring(1),
                            fontSize: AppFontSize.verySmall,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.white : AppColors.lightGrey5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_frequency == 'weekly') ...[
                    const SizedBox(height: BaseSpacing.sm),
                    CustomText(text: 'Day of Week', color: AppColors.black2, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: List.generate(7, (i) {
                        final selected = _dayOfWeek == i;
                        return GestureDetector(
                          onTap: () => setState(() => _dayOfWeek = i),
                          child: Container(
                            width: 42, height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primaryColor : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey11),
                            ),
                            child: CustomText(
                              text: _weekDays[i],
                              fontSize: AppFontSize.tiny,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.white : AppColors.lightGrey5,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  if (_frequency == 'monthly') ...[
                    const SizedBox(height: BaseSpacing.sm),
                    CustomTextField(label: 'Day of Month (1-28)', controller: _dayOfMonthCtrl, isborder: true, keyboardType: TextInputType.number),
                  ],
                  const SizedBox(height: BaseSpacing.sm),
                  CustomTextField(
                    label: 'Minimum Payout Amount (${widget.controller.selectedCurrency.value})',
                    controller: _minimumCtrl,
                    isborder: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      Switch(value: _isEnabled, activeColor: AppColors.primaryColor, onChanged: (v) => setState(() => _isEnabled = v)),
                      CustomText(text: 'Automatic payouts enabled', fontSize: AppFontSize.verySmall, color: AppColors.black2, fontWeight: FontWeight.w600),
                    ],
                  ),
                  const SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isSavingSchedule.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
                        child: widget.controller.isSavingSchedule.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : CustomText(text: 'Save Schedule', color: AppColors.white, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
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
