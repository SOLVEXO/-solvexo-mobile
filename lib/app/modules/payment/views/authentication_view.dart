import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/payment/controllers/payment_verification_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AuthenticationView extends StatelessWidget {
  AuthenticationView({super.key});
  final pvController = Get.put(PaymentVerificationController());

  @override
  Widget build(BuildContext context) {
    // Was `"${date.day}, ${date.month}, ${date.year}"` — produced raw
    // numbers like "6, 7, 2026" instead of a readable date.
    final formattedDate = DateFormat('MMM d, yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Authentication"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
        child: Column(
          spacing: BaseSpacing.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "BANK OF AMERICA.",
                  style: BaseTypography.bodyMedium(color: AppColors.americanBlue).copyWith(fontWeight: FontWeight.w500),
                ),
                SvgIcon(assetName: AppIcons.bankIcon, size: 20),
                const Spacer(),
                SvgIcon(assetName: AppIcons.visaCardIcon, size: 50),
              ],
            ),
            const Divider(height: 0),
            Text(
              "Transaction Authentication",
              style: BaseTypography.titleMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w800),
            ),
            Text(formattedDate, style: BaseTypography.bodyMedium(color: AppColors.gray600)),
            Row(
              children: [
                Text("From card number: ", style: BaseTypography.bodyMedium(color: AppColors.gray600)),
                Text("XXXX XXXX XXXX ${pvController.method.last4}", style: BaseTypography.bodyMedium(color: AppColors.primaryColor)),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl, horizontal: BaseSpacing.xs),
              decoration: BoxDecoration(
                border: Border.all(width: 0.3),
                borderRadius: BorderRadius.circular(BaseRadius.lg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  transactionRowColumn("Transaction Amount:", "\$${pvController.amount.toStringAsFixed(2)}"),
                  transactionRowColumn("Merchant", pvController.method.title),
                ],
              ),
            ),
            Text(
              "To verify this transaction, enter the One Time Password (OTP) we sent via SMS to +xx xxx xxxx105",
              style: BaseTypography.bodyMedium(color: AppColors.black),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: BaseSpacing.xs,
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "Enter OTP",
                    isborder: true,
                    controller: pvController.otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    borderRadius: BorderRadius.circular(BaseRadius.sm),
                    onChanged: pvController.onOtpChanged,
                  ),
                ),
                Obx(
                  () => Expanded(
                    child: PrimaryButton(
                      label: pvController.isLoading.value ? "Submitting..." : "Submit",
                      isLoading: pvController.isLoading.value,
                      // Was unconditionally wired — could double-submit on
                      // a fast double-tap while a verification was already
                      // in flight.
                      onPressed: pvController.isLoading.value ? null : pvController.verifyOtp,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              spacing: BaseSpacing.xxs + 1,
              children: [
                Text("Remaining", style: BaseTypography.bodyMedium(color: AppColors.black)),
                Obx(
                  () => Text(
                    pvController.secondsLeft.toString(),
                    style: BaseTypography.bodyMedium(color: AppColors.orange),
                  ),
                ),
              ],
            ),
            Row(
              spacing: BaseSpacing.xl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GhostButton(label: "Cancel", onPressed: pvController.onClose),
                GhostButton(label: "Resend OTP", onPressed: pvController.startTimer),
              ],
            ),
            const Divider(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: BaseSpacing.xs,
              children: [
                Text("For assistance, please contact", style: BaseTypography.bodySmall(color: AppColors.black)),
                Text("BOA +92 322 2222222", style: BaseTypography.labelSmall(color: AppColors.primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column transactionRowColumn(String title, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: BaseTypography.bodyMedium(color: AppColors.gray600)),
        Text(subTitle, style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
