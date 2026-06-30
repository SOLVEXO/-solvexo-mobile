import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/shimmer/trip_shimmer.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/data/repositories/checkout_repository.dart';
import 'package:book_store_app/app/data/repositories/shipping_repository.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/checkout/models/create_checkout_response.dart';
import 'package:book_store_app/app/modules/checkout/models/order_request_model.dart';
import 'package:book_store_app/app/modules/checkout/models/shipping_options_model.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/checkout_item_model.dart';

class CheckoutController extends GetxController {
  final ShippingRepository _shippingRepository = ShippingRepository();
  final CheckoutRepository _checkoutRepository = CheckoutRepository();

  String _checkoutId = '';

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

  RxDouble shippingCost = 0.0.obs;
  final RxList<ShippingOption> shippingOptions = <ShippingOption>[].obs;
  final Rx<ShippingOption?> selectedShipping = Rx<ShippingOption?>(null);
  final RxBool isLoadingShipping = false.obs;
  final RxBool isLoading = true.obs;
  final AddressController addressController = Get.put(AddressController());

  // Allowed payment methods from the create-checkout API response
  final RxList<String> _allowedPaymentMethods = <String>[].obs;

  bool get canPayCOD =>
      _allowedPaymentMethods.isEmpty ||
      _allowedPaymentMethods.contains('cash_on_delivery');

  bool get canPayOnline =>
      _allowedPaymentMethods.isEmpty ||
      _allowedPaymentMethods.contains('stripe');

  /// True when every item is digital (kept for fallback display logic).
  bool get isAllDigital =>
      orderItems.isNotEmpty &&
      orderItems.every((item) => item.productType == 'digital');

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;

    final response = Get.arguments as CreateCheckoutResponse?;
    if (response != null) {
      _checkoutId = response.checkout.id;
      orderItems.assignAll(
        response.checkout.items.map((e) => e.toCheckoutItem()).toList(),
      );
      shippingCost.value = response.checkout.shippingFee;
      _allowedPaymentMethods.assignAll(response.allowedPaymentMethods);
    }

    await fetchShippingZones();
    isLoading.value = false;
  }

  @override
  Future<void> refresh() async {
    isLoading.value = true;
    await fetchShippingZones();
    isLoading.value = false;
  }

  Future<void> fetchShippingZones() async {
    try {
      isLoadingShipping.value = true;

      final zones = await _shippingRepository.getShippingZones();

      // Filter only active zones and map to ShippingOption
      final options = zones
          .where((z) => z.status == 'active' && !z.isDelete)
          .map((z) => z.toShippingOption())
          .toList();

      shippingOptions.assignAll(options);

      // Auto-select first option and apply its price
      if (options.isNotEmpty) {
        selectedShipping.value = options.first;
        shippingCost.value = options.first.amount;
      }
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
    } catch (e) {
      ToastUtil.showToast('Failed to load shipping options');
    } finally {
      isLoadingShipping.value = false;
    }
  }

  final OrderRepository _orderRepository = OrderRepository();

  RxBool isPlacingOrder = false.obs;

  /// Shows a confirmation dialog then calls POST /api/payment/cod-payment.
  Future<void> placeCodOrder() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: const CustomText(
          text: 'Confirm Order',
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.w700,
          color: AppColors.black2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Cash on Delivery',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.w700,
              color: AppColors.black2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text:
                  'Your order will be placed immediately on your one tap. The delivery agent will collect payment on arrival.',
              fontSize: AppFontSize.verySmall,
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  isOutlined: true,
                  onPressed: () => Get.back(result: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Place Order',
                  onPressed: () => Get.back(result: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isPlacingOrder.value = true;
    try {
      final success = await _checkoutRepository.placeCodOrder(_checkoutId);
      if (success) {
        Get.find<CartController>().clearCart();
        Get.offAllNamed(Routes.paymentSuccessView);
      }
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<void> placeOrder() async {
    try {
      // final defaultAddr = addressController.defaultAddress;

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
          fullName: '',
          phone: '',
          addressLine1: '',
          city: '',
          state: '',
          zipCode: '',
          // fullName: defaultAddr.,
          // phone: defaultAddr.phoneNumber,
          // addressLine1: defaultAddr.addressLine1,
          // addressLine2: defaultAddr.addressLine2,
          // city: defaultAddr.city,
          // state: defaultAddr.state,
          // zipCode: defaultAddr.zipCode,

          // country: defaultAddr.country,
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

  Future<void> selectShippingOption(ShippingOption option) async {
    // Optimistic update — close sheet and reflect selection immediately
    selectedShipping.value = option;
    shippingCost.value = option.amount;
    Get.back();

    if (_checkoutId.isEmpty) return;

    isLoadingShipping.value = true;
    try {
      final result = await _checkoutRepository.addShippingToCheckout(
        checkoutId: _checkoutId,
        shippingZoneId: option.id,
      );
      if (result != null) {
        shippingCost.value = result.shippingFee;
      }
    } finally {
      isLoadingShipping.value = false;
    }
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
          // ✅ Single top-level Obx wraps everything — rebuilds when
          //    shippingOptions or isLoadingShipping changes
          child: Obx(() {
            if (isLoadingShipping.value) {
              return TripShimmer(itemCount: 3); // ✅ return added
            }

            if (shippingOptions.isEmpty) {
              return const Center(
                child: CustomText(
                  text: "No shipping options available",
                  fontSize: AppFontSize.small,
                ),
              );
            }

            return Column(
              spacing: 15,
              children: List.generate(shippingOptions.length, (i) {
                final item = shippingOptions[i];
                final isSelected = selectedShipping.value?.type == item.type;

                return GestureDetector(
                  onTap: () => selectShippingOption(item),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: isSelected ? 1.2 : 0.3,
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.greyDefault,
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
              }),
            );
          }),
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
