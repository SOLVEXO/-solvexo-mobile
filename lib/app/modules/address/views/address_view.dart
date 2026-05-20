import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class AddressView extends StatelessWidget {
  AddressView({super.key});

  final controller = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Address'),
      bottomNavigationBar: Obx(
        () => controller.addresses.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: AppButton(
                  label: 'Add',
                  onPressed: () {
                    controller.clearForm();
                    Get.toNamed(Routes.addAddressView);
                  },
                ),
              ),
      ),
      body: Obx(() {
        // ── Shimmer loading ──────────────────────────────────────────
        if (controller.loading.value) {
          return const _AddressShimmer();
        }

        // ── Empty state ──────────────────────────────────────────────
        if (controller.addresses.isEmpty) {
          return _emptyState();
        }

        // ── Address list ─────────────────────────────────────────────
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          itemCount: controller.addresses.length,
          itemBuilder: (_, i) {
            final a = controller.addresses[i];
            return _addressCard(a, i);
          },
        );
      }),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(assetName: AppIcons.mapsIcon, size: 80),
          CustomText(
            textAlign: TextAlign.center,
            text: "You don't have shipping address",
            fontSize: AppFontSize.large,
          ),
          AppButton(
            label: 'Add Address',
            onPressed: () {
              controller.clearForm();
              Get.toNamed(Routes.addAddressView);
            },
          ),
        ],
      ),
    );
  }

  // ─── Address card ─────────────────────────────────────────────────────────

  Widget _addressCard(AddressModel a, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customcontainer(
                Row(
                  children: [
                    SvgIcon(
                      assetName: AppIcons.locationIcon,
                      color: AppColors.primaryColor,
                    ),
                    CustomText(text: a.label, fontWeight: FontWeight.w500),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.startEditing(a);
                  Get.toNamed(Routes.addAddressView);
                },
                child: customcontainer(
                  CustomText(text: 'Edit', fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: a.recipientName,
                      fontSize: AppFontSize.regular,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      text:
                          '${a.addressLine1.toUpperCase()}, ${a.city.toUpperCase()}, ${a.state.toUpperCase()}, ${a.zipCode}',
                      fontSize: AppFontSize.small,
                    ),
                    CustomText(
                      text: a.phoneNumber,
                      fontSize: AppFontSize.small,
                    ),
                  ],
                ),
              ),
              CustomIconButton(
                assetName: AppIcons.checkIcon,
                size: 30,
                color: a.isDefault ? AppColors.primaryColor : AppColors.gray600,
                onPressed: () {
                  if (a.id != null) controller.setDefault(a.id!);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget customcontainer(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(width: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

// ─── Address Shimmer ───────────────────────────────────────────────────────

class _AddressShimmer extends StatelessWidget {
  const _AddressShimmer();

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);
  static const Color _shape = Color(0xFFD4D4D4);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      period: const Duration(milliseconds: 1400),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => _ShimmerCard(shape: _shape),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Color shape;
  const _ShimmerCard({required this.shape});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: label chip + edit chip ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label chip (icon + text)
              _shimmerChip(
                child: Row(
                  children: [
                    _box(shape, width: 18, height: 18, radius: 4),
                    const SizedBox(width: 6),
                    _box(shape, width: 44, height: 13),
                  ],
                ),
              ),
              // Edit chip
              _shimmerChip(child: _box(shape, width: 28, height: 13)),
            ],
          ),

          const SizedBox(height: 10),

          // ── Body row: text block + check icon ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipient name
                    _box(shape, width: 160, height: 15),
                    const SizedBox(height: 6),
                    // Address line — long
                    _box(shape, width: double.infinity, height: 13),
                    const SizedBox(height: 5),
                    // Address line — shorter
                    _box(shape, width: 200, height: 13),
                    const SizedBox(height: 5),
                    // Phone number
                    _box(shape, width: 120, height: 13),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Check icon placeholder
              _box(shape, width: 30, height: 30, radius: 15),
            ],
          ),
        ],
      ),
    );
  }

  // Mimics customcontainer border + padding
  Widget _shimmerChip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Widget _box(
    Color color, {
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      constraints: width == double.infinity
          ? const BoxConstraints(minWidth: double.infinity)
          : null,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
