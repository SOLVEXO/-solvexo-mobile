import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsExportButton extends StatelessWidget {
  final SellerAnalyticsController controller;
  const AnalyticsExportButton({super.key, required this.controller});

  void _openSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.fromLTRB(0, BaseSpacing.sm, 0, MediaQuery.of(context).padding.bottom + BaseSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, margin: EdgeInsets.only(bottom: BaseSpacing.md), decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'Export Report',
                  color: AppColors.black2,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: BaseSpacing.xs),
            const Divider(height: 1, color: AppColors.lightGrey2),
            _Row(icon: Icons.picture_as_pdf_outlined, label: 'Full report (PDF)', onTap: () {
              Get.back();
              controller.exportPdf();
            }),
            _Row(icon: Icons.table_chart_outlined, label: 'Revenue (CSV)', onTap: () {
              Get.back();
              controller.exportCsv('revenue');
            }),
            _Row(icon: Icons.receipt_long_outlined, label: 'Orders (CSV)', onTap: () {
              Get.back();
              controller.exportCsv('orders');
            }),
            _Row(icon: Icons.inventory_2_outlined, label: 'Products (CSV)', onTap: () {
              Get.back();
              controller.exportCsv('products');
            }),
            _Row(icon: Icons.people_outline_rounded, label: 'Customers (CSV)', onTap: () {
              Get.back();
              controller.exportCsv('customers');
            }),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isExporting.value ? null : () => _openSheet(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.md)),
          alignment: Alignment.center,
          child: controller.isExporting.value
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor))
              : const Icon(Icons.ios_share_rounded, size: 18, color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Row({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg, vertical: BaseSpacing.sm + 1),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(BaseRadius.md)),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: AppColors.primaryColor),
            ),
            SizedBox(width: BaseSpacing.sm + 2),
            CustomText(
              text: label,
              color: AppColors.black2,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
