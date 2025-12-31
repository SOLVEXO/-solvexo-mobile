import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/payment_controller.dart';

class PaymentView extends StatelessWidget {
  PaymentView({super.key});
  final controller = Get.put(PaymentController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Payment"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = controller.paymentMethods[index];
                  return Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: controller.paymentIcon(method),
                      title: CustomText(
                        text: method.title,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w700,
                      ),
                      trailing: TextButton(
                        onPressed: () {},
                        child: CustomText(
                          text: "Connect",
                          color: AppColors.primaryColor,
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AppButton(
              label: "+ Add new Card",
              onPressed: () {
                controller.addNewCardBottomSheet(size);
              },
            ),
          ],
        ),
      ),
    );
  }
}
