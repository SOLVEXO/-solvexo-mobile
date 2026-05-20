import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/checkout/widgets/coupon_code_list_tile.dart';
import 'package:book_store_app/app/modules/map_picker/controllers/mappicker_controller.dart';
import 'package:book_store_app/app/modules/payment/controllers/payment_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends StatelessWidget {
  CheckoutView({super.key});

  final controller = Get.put(CheckoutController());
  final mapPickerController = Get.put(MapPickerController());
  final paymentController = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Checkout"),

      bottomNavigationBar: _bottomBar(size),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deliveryAddress(),
            _voucherSection(size),
            _orderList(),
            shippingSection(size),
            _summary(),
          ],
        ),
      ),
    );
  }

  // ---------------- DELIVERY ADDRESS ----------------

  Widget _deliveryAddress() {
    return _section(
      title: "Delivery Address",
      child: Obx(() {
        final defaultAddress = controller.addressController.defaultAddress;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Expanded(
            //   child: CustomText(
            //     text: controller.addressController.defaultAddress == null
            //         ? "You don’t have shipping address information"
            //         : "${defaultAddress!.addressLine1.toUpperCase()}, ${defaultAddress.zipCode}, ${defaultAddress.city.toUpperCase()}, ${defaultAddress.state.toUpperCase()}",
            //     color: AppColors.gray600,
            //     fontWeight: FontWeight.w700,
            //     fontSize: AppFontSize.small,
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: AppButton(
                  isOutlined: true,
                  onPressed: () {
                    Get.toNamed(Routes.addAddressView);
                    // controller.addAddress(
                    //   mapPickerController.selectedAddress.value,
                    // );
                  },
                  label: "Add",
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ---------------- VOUCHER ----------------

  Widget _voucherSection(size) {
    return _section(
      title: "Voucher and reward points",
      child: Column(
        spacing: 10,
        children: [
          Obx(
            () => CouponCodeListTile(
              isSubtitle: controller.voucherApplied.value,
              subTitle: "Get \$5.00 discount off",
              title: controller.voucherApplied.value
                  ? "GETFIVE"
                  : "Use Voucher",

              onTap: () {
                controller.useVoucher(size);
              },
            ),
          ),
          Obx(
            () => CouponCodeListTile(
              isSubtitle: controller.rewardPointsUsed.value,
              subTitle: "You have redeemed 150 points",
              title: "Reward Points",
              onTap: () {
                controller.useRewardPoints(size);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ORDER LIST ----------------

  Widget _orderList() {
    return _section(
      title: "Your Order",
      child: Obx(
        () => Column(
          children: controller.orderItems
              .map(
                (item) => ListTile(
                  leading: CommonImageView(url: item.image, width: 60),
                  title: CustomText(
                    text: item.name,
                    fontSize: AppFontSize.small,
                  ),
                  subtitle: CustomText(
                    text: "Color : ${item.color}\n${item.quantity} Item",
                    fontSize: AppFontSize.small,
                  ),
                  trailing: CustomText(
                    text:
                        "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.small,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ---------------- SHIPPING ----------------

  Widget shippingSection(Size size) {
    return Obx(() {
      final shipping = controller.selectedShipping.value;

      return _section(
        title: "Shipping Option",
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: shipping == null
              ? ListTile(
                  title: CustomText(
                    text: "Select Shipping Method",
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w600,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => controller.shippingOptionsBottomSheet(size),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: shipping.type,
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w700,
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.shippingOptionsBottomSheet(size),
                          child: const CustomText(
                            text: "Change",
                            color: AppColors.primaryColor,
                            fontSize: AppFontSize.small2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,

                      children: [
                        CustomText(
                          text: shipping.time,
                          color: AppColors.gray600,
                          fontSize: AppFontSize.small2,
                        ),
                        CustomText(
                          text: shipping.charges,
                          color: AppColors.primaryColor,
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
    });
  }

  // ---------------- SUMMARY ----------------

  Widget _summary() {
    return _section(
      title: "Summary",
      child: Obx(
        () => Column(
          children: [
            _summaryRow(
              "Subtotal (${controller.totalItems} items)",
              controller.subtotal.toStringAsFixed(2),
            ),
            _summaryRow(
              "Shipping Cost",
              controller.shippingCost.value.toStringAsFixed(2),
            ),
            controller.voucherApplied.value
                ? _summaryRow(
                    "Discount (GETFIVE)",
                    "- ${controller.discount.toStringAsFixed(2)}",
                  )
                : SizedBox(),
            const Divider(),
            _summaryRow(
              "Total",
              controller.total.toStringAsFixed(2),
              bold: true,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: "Get reward points 10",
              color: AppColors.lightGrey,
              fontSize: AppFontSize.small,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- BOTTOM BAR ----------------

  Widget _bottomBar(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: AppButton(
        label: "Select Payment",
        onPressed: () => paymentController.paymentMethodBottomSheet(size),
      ),
    );
  }

  // ---------------- REUSABLE ----------------

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: AppFontSize.regular,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            "\$$value",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
