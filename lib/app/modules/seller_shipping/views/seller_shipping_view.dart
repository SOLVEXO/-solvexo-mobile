import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_shipping/controllers/seller_shipping_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerShippingView extends StatelessWidget {
  SellerShippingView({super.key});
  final SellerShippingController c = Get.put(SellerShippingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Shipping'),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CustomText(text: 'SHIPPING ZONES', fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.8),
          const SizedBox(height: 12),
          ...c.zones.map((z) => _ZoneCard(zone: z, onDelete: () => c.deleteZone(z.id))),
          const SizedBox(height: 8),
          _AddZoneButton(),
        ]),
      )),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final ShippingZone zone;
  final VoidCallback onDelete;
  const _ZoneCard({required this.zone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryColor)),
          const SizedBox(width: 12),
          Expanded(child: CustomText(text: zone.name, fontSize: AppFontSize.small2, fontWeight: FontWeight.bold, color: AppColors.black)),
          _ActionBtn(icon: Icons.edit_outlined, onTap: () {}),
          const SizedBox(width: 6),
          _ActionBtn(icon: Icons.delete_outline_rounded, onTap: onDelete, isDestructive: true),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.lightGrey2),
        const SizedBox(height: 12),
        _InfoRow(Icons.public_rounded, 'Countries', zone.countries),
        const SizedBox(height: 8),
        _InfoRow(Icons.attach_money_rounded, 'Rate', zone.rate),
        const SizedBox(height: 8),
        _InfoRow(Icons.schedule_rounded, 'Delivery', zone.deliveryTime),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.grey),
      const SizedBox(width: 8),
      CustomText(text: '$label: ', fontSize: AppFontSize.tiny, color: AppColors.grey),
      Expanded(child: CustomText(text: value, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, color: AppColors.black2)),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  const _ActionBtn({required this.icon, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: isDestructive ? AppColors.lightRed : AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: isDestructive ? AppColors.red.withOpacity(0.3) : AppColors.lightGrey2)),
        child: Icon(icon, size: 15, color: isDestructive ? AppColors.red : AppColors.grey),
      ),
    );
  }
}

class _AddZoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius), border: Border.all(color: AppColors.primaryColor.withOpacity(0.4), width: 1.5)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.add_rounded, color: AppColors.primaryColor, size: 16)),
          const SizedBox(width: 10),
          const CustomText(text: 'Add Shipping Zone', fontSize: AppFontSize.small2, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
        ]),
      ),
    );
  }
}
