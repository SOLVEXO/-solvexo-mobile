import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:book_store_app/app/modules/payment/models/payment_method_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_sounds.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final checkoutController = Get.put(CheckoutController());
  Rx<PaymentMethod?> selectedPaymentMethod = Rx<PaymentMethod?>(null);

  RxList<PaymentMethod> paymentMethods = <PaymentMethod>[
    PaymentMethod(id: "gpay", type: PaymentType.gpay, title: "Pay with GPay"),
    PaymentMethod(
      id: "applepay",
      type: PaymentType.applePay,
      title: "Pay with Apple Pay",
    ),
    PaymentMethod(
      id: "visa_3121",
      type: PaymentType.card,
      title: "VISA",
      brand: "visa",
      last4: "3121",
      isDefault: true,
    ),
    PaymentMethod(
      id: "master_5423",
      type: PaymentType.card,
      title: "MasterCard",
      brand: "master",
      last4: "5423",
    ),
  ].obs;

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  void paymentMethodBottomSheet(Size size) {
    Get.bottomSheet(
      CustomBottomSheet(
        // height: size.height / 1.8,
        title: "Select Payment",
        widget: Column(
          spacing: 15,
          children: [
            ...paymentMethods.map(
              (method) => Obx(() {
                final isSelected = selectedPaymentMethod.value?.id == method.id;

                return GestureDetector(
                  onTap: () => selectPaymentMethod(method),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        width: isSelected ? 1.4 : 0.3,
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.greyDefault,
                      ),
                    ),
                    child: ListTile(
                      leading: paymentIcon(method),
                      title: CustomText(
                        text: method.type == PaymentType.card
                            ? "${method.title} •••• ${method.last4}"
                            : method.title,
                        fontWeight: FontWeight.w600,
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),

            /// ADD CARD
            GestureDetector(
              onTap: () => addNewCardBottomSheet(size),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text("+ Add")),
              ),
            ),
            AppButton(
              label: "Pay (\$${checkoutController.total.toStringAsFixed(2)})",
              onPressed: proceedToPayment,
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentIcon(PaymentMethod method) {
    switch (method.type) {
      case PaymentType.gpay:
        return SvgIcon(assetName: AppIcons.googlePayIcon);
      case PaymentType.applePay:
        return SvgIcon(assetName: AppIcons.appleIcon);
      case PaymentType.card:
        return const Icon(Icons.credit_card);
    }
  }

  void addNewCardBottomSheet(Size size) {
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    Get.bottomSheet(
      CustomBottomSheet(
        title: "Add new card",
        widget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              CustomText(text: "Card Holder Name", fontSize: AppFontSize.small),
              CustomTextField(
                controller: nameCtrl,
                hintText: "Card Holder Name",
                isborder: true,
                fillColor: AppColors.background,
                filled: true,
                borderRadius: BorderRadius.circular(15),
              ),
              CustomText(text: "Card Number", fontSize: AppFontSize.small),
              CustomTextField(
                controller: numberCtrl,
                hintText: "Card Number",
                isborder: true,
                fillColor: AppColors.background,
                filled: true,
                borderRadius: BorderRadius.circular(15),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Expire date",
                          fontSize: AppFontSize.small2,
                        ),
                        CustomTextField(
                          controller: expCtrl,
                          hintText: "MM/YY",
                          isborder: true,
                          fillColor: AppColors.background,
                          filled: true,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "CVV code",
                          fontSize: AppFontSize.small2,
                        ),
                        CustomTextField(
                          controller: cvvCtrl,
                          hintText: "CVV",
                          isborder: true,
                          fillColor: AppColors.background,
                          filled: true,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (value) => value = true),
                  CustomText(text: "Save card", fontSize: AppFontSize.small),
                ],
              ),
              AppButton(
                label: "Save",
                onPressed: () {
                  paymentMethods.add(
                    PaymentMethod(
                      id: DateTime.now().toString(),
                      type: PaymentType.card,
                      title: "VISA",
                      brand: "visa",
                      last4: numberCtrl.text.substring(
                        numberCtrl.text.length - 4,
                      ),
                    ),
                  );
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void proceedToPayment() {
    if (selectedPaymentMethod.value == null) {
      CustomAppSnackbar.show(
        soundPath: AppSounds.warningSound,
        title: "Payment Required",
        message: "Please select a payment method",
      );

      return;
    }

    // 🔐 Future: Navigate to OTP / Auth screen
    Get.toNamed(
      Routes.authenticationView,
      arguments: {
        "amount": checkoutController.total,
        "method": selectedPaymentMethod.value,
      },
    );
  }
}
