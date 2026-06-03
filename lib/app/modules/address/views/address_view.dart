import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_effect.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/address/controllers/address_controller.dart';
import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressView extends StatelessWidget {
  AddressView({super.key});

  final controller = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    return BaseViewScreen(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      screenName: 'Address',
      showCustomAppBar: true,
      horizontalPadding: false,
      verticalPadding: true,
      customBottomBar: Obx(
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
      child: CustomRefreshWrapper(
        onRefresh: () => controller.refreshaddress(),
        child: Obx(() {
          // ── Shimmer loading ──────────────────────────────────────────
          if (controller.loading.value) {
            return const ShimmerEffect(itemCount: 2);
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
      ),
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
