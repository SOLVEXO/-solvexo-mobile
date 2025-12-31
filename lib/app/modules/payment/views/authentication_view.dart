import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/payment/controllers/payment_verification_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthenticationView extends StatelessWidget {
  AuthenticationView({super.key});
  final pvController = Get.put(PaymentVerificationController());

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Authentication"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(
                  text: "BANK OF AMERICA.",
                  color: AppColors.americanBlue,
                  fontWeight: FontWeight.w500,

                  fontSize: AppFontSize.small,
                ),
                SvgIcon(assetName: AppIcons.bankIcon, size: 20),
                Spacer(),
                SvgIcon(assetName: AppIcons.visaCardIcon, size: 50),
              ],
            ),
            Divider(height: 0),
            CustomText(
              text: "Transaction Authentication",
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w800,
            ),
            CustomText(
              text: "${date.day}, ${date.month}, ${date.year}",
              fontSize: AppFontSize.small,
              color: AppColors.gray600,
            ),
            Row(
              children: [
                CustomText(
                  text: "From card number: ",
                  fontSize: AppFontSize.small,
                  color: AppColors.gray600,
                ),
                CustomText(
                  text: "XXXX XXXX XXXX ${pvController.method.last4}",
                  fontSize: AppFontSize.small,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  transactionRowColumn(
                    "Transaction Amount:",
                    "\$${pvController.amount.toStringAsFixed(2)}",
                  ),

                  transactionRowColumn("Merchant", pvController.method.title),
                ],
              ),
            ),
            CustomText(
              text:
                  "To verify this transaction, enter One Time Password(OTP) That we have sent via SMS to +xx xxx xxxx105",
              fontSize: AppFontSize.small,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "Enter OTP",
                    isborder: true,
                    controller: pvController.otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    onChanged: pvController.onOtpChanged,
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: "Submit",
                    onPressed: () {
                      pvController.verifyOtp();
                    },
                  ),
                ),
              ],
            ),
            Row(
              spacing: 5,
              children: [
                CustomText(text: "Ramining", fontSize: AppFontSize.small),
                Obx(
                  () => CustomText(
                    text: pvController.secondsLeft.toString(),
                    color: AppColors.orange,
                    fontSize: AppFontSize.small,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    pvController.onClose();
                  },
                  child: CustomText(
                    text: "Cancle",
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.small,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    pvController.startTimer();
                  },
                  child: CustomText(
                    text: "Resend OTP",
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.small,
                  ),
                ),
              ],
            ),
            Divider(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                CustomText(
                  text: "For assisstance, please contact",
                  fontSize: AppFontSize.small2,
                ),
                CustomText(
                  text: "BOA +92 322 2222222",
                  color: AppColors.primaryColor,
                  fontSize: AppFontSize.verySmall,
                ),
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
        CustomText(
          text: title,
          fontSize: AppFontSize.small,
          color: AppColors.gray600,
        ),
        CustomText(
          text: subTitle,
          fontSize: AppFontSize.small,
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
