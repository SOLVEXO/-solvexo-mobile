import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/models/finance/tax_report_model.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Form to generate a new tax report for a year/period
/// (`POST .../tax-reports/generate`).
class FinanceGenerateTaxReportSheet extends StatefulWidget {
  final SellerFinanceController controller;
  const FinanceGenerateTaxReportSheet({super.key, required this.controller});

  static void show(BuildContext context, SellerFinanceController controller) {
    Get.bottomSheet(
      FinanceGenerateTaxReportSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<FinanceGenerateTaxReportSheet> createState() => _FinanceGenerateTaxReportSheetState();
}

class _FinanceGenerateTaxReportSheetState extends State<FinanceGenerateTaxReportSheet> {
  static const _periods = ['q1', 'q2', 'q3', 'q4', 'annual'];
  late final TextEditingController _yearCtrl;
  String _period = 'q1';

  @override
  void initState() {
    super.initState();
    _yearCtrl = TextEditingController(text: DateTime.now().year.toString());
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final year = int.tryParse(_yearCtrl.text.trim());
    if (year == null) {
      Get.snackbar('Invalid year', 'Enter a valid year.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final ok = await widget.controller.generateTaxReport(year: year, period: _period);
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
                  CustomText(text: 'Generate Tax Report', color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
                  const SizedBox(height: BaseSpacing.md),
                  CustomTextField(label: 'Year', controller: _yearCtrl, isborder: true, keyboardType: TextInputType.number),
                  const SizedBox(height: BaseSpacing.sm),
                  CustomText(text: 'Period', color: AppColors.black2, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _periods.map((p) {
                      final selected = _period == p;
                      return GestureDetector(
                        onTap: () => setState(() => _period = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryColor : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey11),
                          ),
                          child: CustomText(
                            text: p == 'annual' ? 'Annual' : p.toUpperCase(),
                            fontSize: AppFontSize.verySmall,
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.white : AppColors.lightGrey5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: BaseSpacing.lg),
                  Obx(
                    () => GestureDetector(
                      onTap: widget.controller.isGeneratingTaxReport.value ? null : _submit,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
                        child: widget.controller.isGeneratingTaxReport.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : CustomText(text: 'Generate', color: AppColors.white, fontSize: AppFontSize.small, fontWeight: FontWeight.w700),
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

/// Shows the aggregated figures behind a generated tax report. There is no
/// PDF generation implemented on the backend (`TaxReport.pdfUrl` is always
/// null today), so this dialog is the only way to see report contents —
/// per house rule, don't render a fake "download" for a file that doesn't exist.
void showTaxReportDetailDialog(BuildContext context, TaxReportModel report) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: CustomText(text: report.periodLabel, color: AppColors.black2, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportRow(label: 'Total Revenue', value: report.totalRevenue),
          _ReportRow(label: 'Total Fees', value: report.totalFees),
          _ReportRow(label: 'Total Refunds', value: report.totalRefunds),
          _ReportRow(label: 'Total Paid Out', value: report.totalPayouts),
          _ReportRow(label: 'Net Revenue', value: report.netRevenue),
          _ReportRow(label: 'Estimated Tax', value: report.estimatedTax),
          const SizedBox(height: 4),
          CustomText(text: '${report.transactionCount} transactions', color: AppColors.lightGrey5, fontSize: AppFontSize.tiny),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: CustomText(text: 'Close', color: AppColors.primaryColor, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ReportRow extends StatelessWidget {
  final String label;
  final double value;
  const _ReportRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, color: AppColors.lightGrey5, fontSize: AppFontSize.verySmall),
          CustomText(text: '\$${value.toStringAsFixed(2)}', color: AppColors.black2, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}
