import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
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
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Payment"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl, vertical: BaseSpacing.xl),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = controller.paymentMethods[index];
                  return Container(
                    margin: EdgeInsets.only(top: BaseSpacing.xs),
                    padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs / 2),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.3),
                      borderRadius: BorderRadius.circular(BaseRadius.md),
                    ),
                    child: ListTile(
                      leading: controller.paymentIcon(method),
                      title: CustomText(
                        text: method.title,
                        color: AppColors.black,
                        fontSize: AppFontSize.extraSmall,
                        fontWeight: FontWeight.w700,
                      ),
                      // NOTE (incomplete feature): "Connect" has no handler
                      // wired up — tapping it does nothing. Not implementing
                      // new business logic here since the intended behavior
                      // (OAuth flow? saved-card linking?) isn't specified
                      // anywhere in this controller; flagging rather than
                      // guessing at what it should do.
                      trailing: GhostButton(label: "Connect", onPressed: () {}),
                    ),
                  );
                },
              ),
            ),
            PrimaryButton(
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
