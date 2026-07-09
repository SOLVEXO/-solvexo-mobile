import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/checkout/widgets/coupon_code_list_tile.dart';
import 'package:book_store_app/app/modules/map_picker/controllers/mappicker_controller.dart';
import 'package:book_store_app/app/modules/payment/controllers/payment_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends StatelessWidget {
  CheckoutView({super.key});

  // Fresh per navigation is correct here — a new checkout needs its own
  // state (matches ProductDetailController's pattern).
  final controller = Get.put(CheckoutController());

  // These two are shared controllers used by other standalone screens
  // (MapPickerView, PaymentView) — was unconditional `Get.put(...)` here
  // too, which replaced their live singleton every time Checkout opened.
  MapPickerController get mapPickerController {
    if (!Get.isRegistered<MapPickerController>()) Get.put(MapPickerController());
    return Get.find<MapPickerController>();
  }

  PaymentController get paymentController {
    if (!Get.isRegistered<PaymentController>()) Get.put(PaymentController());
    return Get.find<PaymentController>();
  }

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
                SizedBox(height: BaseSpacing.xl),
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
            padding: EdgeInsets.fromLTRB(BaseSpacing.sm, 0, BaseSpacing.sm, BaseSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(width: 0.3),
              borderRadius: BorderRadius.circular(BaseRadius.lg),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "Please select the address",
                    style: BaseTypography.bodyMedium(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: BaseSpacing.xxl - 2),
                    child: OutlineButton(
                      onPressed: () => Get.toNamed(Routes.addressView),
                      label: "Add",
                      compact: true,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: EdgeInsets.fromLTRB(BaseSpacing.sm, 0, BaseSpacing.sm, BaseSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(BaseRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: BaseSpacing.xxs + 2,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: BaseSpacing.xxs + 2,
                    children: [
                      SvgIcon(assetName: AppIcons.locationIcon, size: 16),
                      Text(address.label, style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  GhostButton(
                    label: "Change",
                    onPressed: () => Get.toNamed(Routes.addressView),
                  ),
                ],
              ),
              Text(address.recipientName, style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w600)),
              Text(address.phoneNumber, style: BaseTypography.bodySmall(color: AppColors.gray600)),
              Text(
                [
                  address.addressLine1,
                  if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) address.addressLine2!,
                  address.city,
                  address.state,
                  address.zipCode,
                ].join(', '),
                style: BaseTypography.bodySmall(color: AppColors.gray600),
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
        spacing: BaseSpacing.sm,
        children: [
          Obx(
            () => CouponCodeListTile(
              isSubtitle: controller.voucherApplied.value,
              subTitle: "Get \$5.00 discount off",
              title: controller.voucherApplied.value ? "GETFIVE" : "Use Voucher",
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
          spacing: BaseSpacing.xxs / 2,
          children: controller.orderItems
              .map(
                (item) => Container(
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xxs + 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(BaseRadius.md),
                  ),
                  child: ListTile(
                    leading: CommonImageView(url: item.image, width: 60),
                    title: Text(item.name, style: BaseTypography.bodyMedium(color: AppColors.black)),
                    subtitle: Row(
                      spacing: BaseSpacing.xxs + 2,
                      children: [
                        Text("${item.quantity} Item", style: BaseTypography.bodyMedium(color: AppColors.black)),
                        _ProductTypeBadge(type: item.productType),
                      ],
                    ),
                    trailing: Text(
                      "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                      style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold),
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
          padding: EdgeInsets.all(BaseSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(BaseRadius.lg),
          ),
          child: shipping == null
              ? ListTile(
                  title: Text(
                    "Select Shipping Method",
                    style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => controller.shippingOptionsBottomSheet(size),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: BaseSpacing.xxs + 2,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(shipping.type, style: BaseTypography.bodyMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w700)),
                        GhostButton(
                          label: "Change",
                          onPressed: () => controller.shippingOptionsBottomSheet(size),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(shipping.time, style: BaseTypography.bodySmall(color: AppColors.gray600)),
                        Text(
                          shipping.charges,
                          style: BaseTypography.bodyMedium(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.bold),
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
            _summaryRow("Subtotal (${controller.totalItems} items)", controller.subtotal.toStringAsFixed(2)),
            _summaryRow("Shipping Cost", controller.shippingCost.value.toStringAsFixed(2)),
            if (controller.voucherApplied.value)
              _summaryRow("Discount (GETFIVE)", "- ${controller.discount.toStringAsFixed(2)}"),
            const Divider(),
            _summaryRow("Total", controller.total.toStringAsFixed(2), bold: true, color: AppColors.primaryColor),
            SizedBox(height: BaseSpacing.xs),
            Text("Get reward points 10", style: BaseTypography.bodyMedium(color: AppColors.lightGrey)),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _section({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.all(BaseSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BaseTypography.titleMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: BaseSpacing.xs),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: BaseTypography.bodyMedium(color: AppColors.black)),
          Text(
            "\$$value",
            style: BaseTypography.bodyMedium(color: color ?? AppColors.black).copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
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
        padding: EdgeInsets.fromLTRB(BaseSpacing.xl, BaseSpacing.sm + 2, BaseSpacing.xl, BaseSpacing.xxl - 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3)),
          ],
        ),
        child: Row(
          spacing: BaseSpacing.sm,
          children: [
            if (controller.canPayCOD)
              Expanded(
                child: OutlineButton(
                  label: "Cash on Delivery",
                  isLoading: isPlacing,
                  onPressed: isPlacing ? null : controller.placeCodOrder,
                ),
              ),
            if (controller.canPayOnline)
              Expanded(
                child: PrimaryButton(
                  label: "Pay Online",
                  icon: const Icon(Icons.lock_outline_rounded),
                  onPressed: () => paymentController.paymentMethodBottomSheet(size),
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
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs + 2, vertical: BaseSpacing.xxs / 2),
      decoration: BoxDecoration(
        color: isDigital ? AppColors.primaryColor.withOpacity(0.1) : AppColors.darkGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(BaseRadius.xs),
      ),
      child: Text(
        isDigital ? 'Digital' : 'Physical',
        style: BaseTypography.labelSmall(
          color: isDigital ? AppColors.primaryColor : AppColors.darkGreen,
        ).copyWith(fontWeight: FontWeight.w600),
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
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerSection(
              child: Column(
                spacing: BaseSpacing.xs,
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
            SizedBox(height: BaseSpacing.xxs),

            _ShimmerSection(
              child: Column(spacing: BaseSpacing.xxs + 2, children: [_shimmerTile(), _shimmerTile()]),
            ),
            SizedBox(height: BaseSpacing.xxs),

            _ShimmerSection(
              child: Column(spacing: BaseSpacing.xs, children: [_shimmerOrderItem(), _shimmerOrderItem()]),
            ),
            SizedBox(height: BaseSpacing.xxs),

            _ShimmerSection(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: BaseSpacing.xs,
                    children: [
                      Skeleton(width: 120, height: 14),
                      Skeleton(width: 80, height: 12),
                    ],
                  ),
                  Skeleton(width: 60, height: 14),
                ],
              ),
            ),
            SizedBox(height: BaseSpacing.xxs),

            _ShimmerSection(
              child: Column(
                spacing: BaseSpacing.xxs + 2,
                children: [
                  _shimmerSummaryRow(),
                  _shimmerSummaryRow(),
                  const Divider(),
                  _shimmerSummaryRow(bold: true),
                ],
              ),
            ),
            SizedBox(height: BaseSpacing.xl),
          ],
        ),
      ),
    );
  }

  static Widget _shimmerTile() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.md - 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey2, width: 0.5),
        borderRadius: BorderRadius.circular(BaseRadius.md),
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
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(BaseRadius.md),
      ),
      child: Row(
        spacing: BaseSpacing.sm,
        children: [
          Skeleton(width: 60, height: 60, cornerRadius: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: BaseSpacing.xs,
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
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: BaseSpacing.xs,
        children: [Skeleton(width: 140, height: 15, cornerRadius: 4), child],
      ),
    );
  }
}
