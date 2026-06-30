import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/checkout/widgets/coupon_code_list_tile.dart';
import 'package:book_store_app/app/modules/map_picker/controllers/mappicker_controller.dart';
import 'package:book_store_app/app/modules/payment/controllers/payment_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
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
    return BaseViewScreen(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      screenName: "Checkout",
      showCustomAppBar: true,
      customBottomBar: _BottomBar(
        controller: controller,
        paymentController: paymentController,
        size: size,
      ),
      horizontalPadding: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const _CheckoutShimmer();
        }
        return CustomRefreshWrapper(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _deliveryAddress(),
                _voucherSection(size),
                _orderList(),
                shippingSection(size),
                _summary(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Delivery Address ─────────────────────────────────────────────────────

  Widget _deliveryAddress() {
    return _section(
      title: "Delivery Address",
      child: Obx(() {
        final address = controller.addressController.defaultAddress.value;

        if (address == null) {
          return Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            decoration: BoxDecoration(
              border: Border.all(width: 0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CustomText(
                    text: "Please select the address",
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSize.small,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: AppButton(
                      isOutlined: true,
                      onPressed: () => Get.toNamed(Routes.addressView),
                      label: "Add",
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          decoration: BoxDecoration(
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      SvgIcon(assetName: AppIcons.locationIcon, size: 16),
                      CustomText(
                        text: address.label,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.addressView),
                    child: const CustomText(
                      text: "Change",
                      color: AppColors.primaryColor,
                      fontSize: AppFontSize.small2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              CustomText(
                text: address.recipientName,
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.w600,
              ),
              CustomText(
                text: address.phoneNumber,
                color: AppColors.gray600,
                fontSize: AppFontSize.small2,
              ),
              CustomText(
                text: [
                  address.addressLine1,
                  if (address.addressLine2 != null &&
                      address.addressLine2!.isNotEmpty)
                    address.addressLine2!,
                  address.city,
                  address.state,
                  address.zipCode,
                ].join(', '),
                color: AppColors.gray600,
                fontSize: AppFontSize.small2,
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Voucher ───────────────────────────────────────────────────────────────

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
              onTap: () => controller.useVoucher(size),
            ),
          ),
          Obx(
            () => CouponCodeListTile(
              isSubtitle: controller.rewardPointsUsed.value,
              subTitle: "You have redeemed 150 points",
              title: "Reward Points",
              onTap: () => controller.useRewardPoints(size),
            ),
          ),
        ],
      ),
    );
  }

  // ── Order list ────────────────────────────────────────────────────────────

  Widget _orderList() {
    return _section(
      title: "Your Order",
      child: Obx(
        () => Column(
          spacing: 2,
          children: controller.orderItems
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CommonImageView(url: item.image, width: 60),
                    title: CustomText(
                      text: item.name,
                      fontSize: AppFontSize.small,
                    ),
                    subtitle: Row(
                      spacing: 6,
                      children: [
                        CustomText(
                          text: "${item.quantity} Item",
                          fontSize: AppFontSize.small,
                        ),
                        _ProductTypeBadge(type: item.productType),
                      ],
                    ),
                    trailing: CustomText(
                      text:
                          "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSize.small,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ── Shipping ──────────────────────────────────────────────────────────────

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

  // ── Summary ───────────────────────────────────────────────────────────────

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
            if (controller.voucherApplied.value)
              _summaryRow(
                "Discount (GETFIVE)",
                "- ${controller.discount.toStringAsFixed(2)}",
              ),
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

  // ── Helpers ───────────────────────────────────────────────────────────────

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

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final CheckoutController controller;
  final PaymentController paymentController;
  final Size size;

  const _BottomBar({
    required this.controller,
    required this.paymentController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isPlacing = controller.isPlacingOrder.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
                spacing: 12,
                children: [
                  if (controller.canPayCOD)
                    Expanded(
                      child: AppButton(
                        label: "Cash on Delivery",
                        isOutlined: true,
                        onPressed: isPlacing ? null : controller.placeCodOrder,
                      ),
                    ),
                  if (controller.canPayOnline)
                    Expanded(
                      child: AppButton(
                        label: "Pay Online",
                        icon: Icons.lock_outline_rounded,
                        onPressed: () =>
                            paymentController.paymentMethodBottomSheet(size),
                      ),
                    ),
                ],
              ),
      );
    });
  }
}

// ── Product type badge ────────────────────────────────────────────────────────

class _ProductTypeBadge extends StatelessWidget {
  final String type;
  const _ProductTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDigital = type == 'digital';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDigital
            ? AppColors.primaryColor.withOpacity(0.1)
            : AppColors.darkGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText(
        text: isDigital ? 'Digital' : 'Physical',
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: isDigital ? AppColors.primaryColor : AppColors.darkGreen,
      ),
    );
  }
}

// ── Full-page shimmer ─────────────────────────────────────────────────────────

class _CheckoutShimmer extends StatelessWidget {
  const _CheckoutShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address section
            _ShimmerSection(
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Skeleton(width: 120, height: 14),
                      Skeleton(width: 60, height: 14),
                    ],
                  ),
                  Skeleton(width: 160, height: 14),
                  Skeleton(width: double.infinity, height: 12),
                  Skeleton(width: double.infinity, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Voucher section
            _ShimmerSection(
              child: Column(
                spacing: 10,
                children: [_shimmerTile(), _shimmerTile()],
              ),
            ),
            const SizedBox(height: 4),

            // Order list section
            _ShimmerSection(
              child: Column(
                spacing: 8,
                children: [_shimmerOrderItem(), _shimmerOrderItem()],
              ),
            ),
            const SizedBox(height: 4),

            // Shipping section
            _ShimmerSection(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Skeleton(width: 120, height: 14),
                      Skeleton(width: 80, height: 12),
                    ],
                  ),
                  Skeleton(width: 60, height: 14),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Summary section
            _ShimmerSection(
              child: Column(
                spacing: 10,
                children: [
                  _shimmerSummaryRow(),
                  _shimmerSummaryRow(),
                  const Divider(),
                  _shimmerSummaryRow(bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey2, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Skeleton(width: 130, height: 13),
          Skeleton(width: 28, height: 28, cornerRadius: 8),
        ],
      ),
    );
  }

  static Widget _shimmerOrderItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        spacing: 12,
        children: [
          Skeleton(width: 60, height: 60, cornerRadius: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Skeleton(width: double.infinity, height: 13),
                Skeleton(width: 80, height: 11),
              ],
            ),
          ),
          Skeleton(width: 50, height: 13),
        ],
      ),
    );
  }

  static Widget _shimmerSummaryRow({bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Skeleton(width: bold ? 60 : 140, height: bold ? 15 : 12),
        Skeleton(width: 50, height: bold ? 15 : 12),
      ],
    );
  }
}

// ── Shimmer section wrapper ───────────────────────────────────────────────────

class _ShimmerSection extends StatelessWidget {
  final Widget child;
  const _ShimmerSection({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [Skeleton(width: 140, height: 15, cornerRadius: 4), child],
      ),
    );
  }
}
