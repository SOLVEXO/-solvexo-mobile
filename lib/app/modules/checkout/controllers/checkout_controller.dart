import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';
import 'package:book_store_app/app/modules/checkout/models/order_request_model.dart';
import 'package:book_store_app/app/modules/checkout/models/shipping_options_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/checkout_item_model.dart';

class CheckoutController extends GetxController {
  /// Order Items (coming from Cart)
  RxList<CheckoutItem> orderItems = <CheckoutItem>[].obs;
  final rewardController = TextEditingController();
  final voucherController = TextEditingController();
  final RxString rewardPointCode = "123".obs;
  final RxString voucherCode = "456".obs;

  /// Address
  RxString address = "".obs;

  /// Voucher & Rewards
  RxBool voucherApplied = false.obs;
  RxBool rewardPointsUsed = false.obs;
  static const double voucherDiscount = 5.0;
  static const double rewardPointDiscount = 0.0; // optional for future

  RxDouble shippingCost = 9.0.obs;
  Rx<ShippingOption?> selectedShipping = Rx<ShippingOption?>(null);

  final List<ShippingOption> shippingOptions = [
    ShippingOption(
      type: "Free Delivery",
      charges: "Free",
      amount: 0,
      time: "Flat rate (Estimate delivery: 6 Days)",
    ),
    ShippingOption(
      type: "Standard Delivery",
      charges: "\$9.90",
      amount: 9.90,
      time: "Flat rate (Estimate delivery: 4 Days)",
    ),
    ShippingOption(
      type: "Express Delivery",
      charges: "\$14.90",
      amount: 14.90,
      time: "Flat rate (Estimate delivery: 2 Days)",
    ),
  ];
  final AddressController addressController = Get.put(AddressController());

  @override
  void onInit() {
    super.onInit();

    final List<CartItem> cartItems = (Get.arguments as List<CartItem>? ?? []);

    orderItems.assignAll(
      cartItems
          .map(
            (item) => CheckoutItem(
              id: item.product.id,
              name: item.product.name,
              color: "${item.selectedVariant}",
              image: item.product.images.first,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
    );
    final defaultAddr = addressController.defaultAddress;
    if (defaultAddr != null) {
      address.value = defaultAddr.addressLine1;
    }
  }

  final OrderRepository _orderRepository = OrderRepository();

  RxBool isPlacingOrder = false.obs;

  Future<void> placeOrder() async {
    try {
      final defaultAddr = addressController.defaultAddress;
      if (defaultAddr == null) {
        ToastUtil.showToast("Please select a delivery address");
        return;
      }

      isPlacingOrder.value = true;

      final request = OrderRequestModel(
        orderItems: orderItems.map((e) {
          return OrderItemRequest(
            product: e.id!,
            name: e.name,
            quantity: e.quantity,
            price: e.price,
            image: e.image,
          );
        }).toList(),
        shippingAddress: ShippingAddressRequest(
          fullName: defaultAddr.fullName,
          phone: defaultAddr.phone,
          addressLine1: defaultAddr.addressLine1,
          addressLine2: defaultAddr.addressLine2,
          city: defaultAddr.city,
          state: defaultAddr.state,
          zipCode: defaultAddr.zipCode,
          country: defaultAddr.country,
        ),
        paymentMethod: "cash_on_delivery",
        itemsPrice: subtotal,
        shippingPrice: shippingCost.value,
        taxPrice: 0,
        totalPrice: total,
      );

      await _orderRepository.placeOrder(request);

      Get.find<CartController>().clearCart();
      Get.offAllNamed(Routes.paymentSuccessView);
    } catch (e) {
      ToastUtil.showToast("Failed to place order");
    } finally {
      isPlacingOrder.value = false;
    }
  }

  void selectShippingOption(ShippingOption option) {
    selectedShipping.value = option;
    shippingCost.value = option.amount;
    Get.back();
  }

  void useRewardPoints(Size size) {
    useCouponBottomSheet(size, rewardController, "Reward Points", true, () {
      applyRewardPoints(size);
    });
  }

  void useVoucher(Size size) {
    useCouponBottomSheet(
      size,
      voucherController,
      "Enter Coupon code",
      false,
      () {
        applyVoucher(size);
      },
    );
  }

  void applyRewardPoints(Size size) {
    if (rewardController.text == rewardPointCode.value) {
      rewardPointsUsed.value = true;
      rewardController.clear();
      Get.back();
    } else {
      rewardPointsUsed.value = false;
      Get.back();
    }
  }

  void applyVoucher(Size size) {
    if (voucherController.text == voucherCode.value) {
      voucherApplied.value = true;
      Get.back();
      voucherController.clear();
    } else {
      voucherApplied.value = false;
      Get.back();
    }
  }

  void shippingOptionsBottomSheet(Size size) {
    Get.bottomSheet(
      CustomBottomSheet(
        height: size.height / 2.5,
        title: "Shipping Options",
        widget: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            spacing: 15,
            children: List.generate(shippingOptions.length, (i) {
              final item = shippingOptions[i];

              return Obx(() {
                final isSelected = selectedShipping.value?.type == item.type;

                return GestureDetector(
                  onTap: () => selectShippingOption(item),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: isSelected ? 1.2 : 0.3,
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: CustomText(
                        text: item.type,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w800,
                      ),
                      subtitle: CustomText(
                        text: item.time,
                        color: AppColors.gray600,
                        fontSize: AppFontSize.small,
                      ),
                      trailing: CustomText(
                        text: item.charges,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                );
              });
            }),
          ),
        ),
      ),
    );
  }

  void useCouponBottomSheet(
    Size size,
    TextEditingController? controller,
    String title,
    bool isRewardPoint,
    Function() onPressed,
  ) {
    Get.bottomSheet(
      CustomBottomSheet(
        height: size.height / 3.1,
        title: title,
        widget: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              CustomText(text: "Reward Points", fontSize: AppFontSize.small2),
              CustomTextField(
                controller: controller,
                isborder: true,
                borderRadius: BorderRadius.circular(15),
                filled: true,
                fillColor: AppColors.background,
                hintText: "Enter your Coupon code",
              ),
              isRewardPoint
                  ? Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.local_offer_outlined),
                        CustomText(
                          text: "Your point is 1500. 1 point = \$0.2",
                          fontSize: AppFontSize.small2,
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: isRewardPoint ? 15 : 30),
              AppButton(label: "Apply", onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }

  double get discount {
    double totalDiscount = 0.0;

    if (voucherApplied.value) {
      totalDiscount += voucherDiscount;
    }

    // Future extension
    if (rewardPointsUsed.value) {
      totalDiscount += rewardPointDiscount;
    }

    return totalDiscount;
  }

  double get subtotal =>
      orderItems.fold(0, (sum, e) => sum + e.price * e.quantity);

  double get total {
    final calculatedTotal = subtotal + shippingCost.value - discount;

    return calculatedTotal < 0 ? 0 : calculatedTotal;
  }

  int get totalItems => orderItems.fold(0, (sum, e) => sum + e.quantity);

  void addAddress(String value) {
    address.value = value;
  }
}
