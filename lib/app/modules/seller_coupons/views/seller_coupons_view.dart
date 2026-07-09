import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/data/models/marketing/coupon_model.dart';
import 'package:book_store_app/app/modules/seller_coupons/controllers/seller_coupons_controller.dart';
import 'package:book_store_app/app/modules/seller_coupons/widgets/coupon_card.dart';
import 'package:book_store_app/app/modules/seller_coupons/widgets/coupon_form_sheet.dart';
import 'package:book_store_app/app/modules/seller_coupons/widgets/coupons_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerCouponsView extends StatelessWidget {
  SellerCouponsView({super.key});

  final SellerCouponsController controller = Get.put(SellerCouponsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Coupons & Discounts'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CouponFormSheet.show(context, controller),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text('New Coupon', style: BaseTypography.bodySmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _FilterTabs(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const CouponsShimmer();

              final items = controller.filteredCoupons;
              if (items.isEmpty) return _EmptyState(filter: controller.filter.value);

              return CustomRefreshWrapper(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm, BaseSpacing.md, BaseSpacing.xxl * 2),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
                  itemBuilder: (_, i) {
                    final coupon = items[i];
                    return CouponCard(
                      coupon: coupon,
                      onEdit: () => CouponFormSheet.show(context, controller, existing: coupon),
                      onToggleActive: () => controller.toggleActive(coupon),
                      onDelete: () => _confirmDelete(context, coupon),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CouponModel coupon) {
    CustomConfirmDialog.show(
      context,
      title: 'Delete "${coupon.code}"?',
      message: 'This coupon will no longer be usable. This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.red,
      onConfirm: () => controller.deleteCoupon(coupon),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final SellerCouponsController controller;
  const _FilterTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm, BaseSpacing.md, BaseSpacing.sm),
      child: Obx(
        () => Row(
          children: [
            _Tab(label: 'All', selected: controller.filter.value == CouponFilter.all, onTap: () => controller.setFilter(CouponFilter.all)),
            SizedBox(width: BaseSpacing.xs),
            _Tab(label: 'Active', selected: controller.filter.value == CouponFilter.active, onTap: () => controller.setFilter(CouponFilter.active)),
            SizedBox(width: BaseSpacing.xs),
            _Tab(label: 'Expired', selected: controller.filter.value == CouponFilter.expired, onTap: () => controller.setFilter(CouponFilter.expired)),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BaseMotion.normal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.lightGrey10,
          borderRadius: BorderRadius.circular(BaseRadius.pill),
        ),
        child: Text(
          label,
          style: BaseTypography.labelSmall(color: selected ? AppColors.white : AppColors.gray600).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final CouponFilter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      CouponFilter.all => 'Create your first coupon to offer discounts to buyers.',
      CouponFilter.active => 'No active coupons right now.',
      CouponFilter.expired => 'No expired or inactive coupons.',
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryColor.withOpacity(0.12), AppColors.accentColor.withOpacity(0.06)]),
              borderRadius: BorderRadius.circular(BaseRadius.xxl),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.local_offer_outlined, size: 34, color: AppColors.primaryColor),
          ),
          SizedBox(height: BaseSpacing.md),
          Text('No coupons found', style: BaseTypography.titleMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: BaseSpacing.xxs + 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxl),
            child: Text(message, style: BaseTypography.bodySmall(color: AppColors.gray600), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
