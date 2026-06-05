import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_notifications/controllers/seller_notifications_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerNotificationsView extends StatelessWidget {
  SellerNotificationsView({super.key});
  final SellerNotificationsController c = Get.put(SellerNotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Notifications'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _NotifSection(
            header: 'ORDER NOTIFICATIONS',
            tiles: [
              _NotifItem(emoji: '📦', title: 'New Orders', subtitle: 'Alert when a new order is placed', obs: c.newOrders),
              _NotifItem(emoji: '🚚', title: 'Order Shipped', subtitle: 'When an order is marked shipped', obs: c.orderShipped),
              _NotifItem(emoji: '❌', title: 'Order Cancelled', subtitle: 'When a buyer cancels an order', obs: c.orderCancelled),
            ],
          ),
          const SizedBox(height: 20),
          _NotifSection(
            header: 'STORE ALERTS',
            tiles: [
              _NotifItem(emoji: '💬', title: 'Customer Messages', subtitle: 'New messages from buyers', obs: c.customerMessages),
              _NotifItem(emoji: '⚠️', title: 'Low Stock', subtitle: 'When product stock runs low', obs: c.lowStockAlerts),
              _NotifItem(emoji: '⭐', title: 'Product Reviews', subtitle: 'When a buyer leaves a review', obs: c.productReviews),
            ],
          ),
          const SizedBox(height: 20),
          _NotifSection(
            header: 'PLATFORM',
            tiles: [
              _NotifItem(emoji: '💡', title: 'Tips & Insights', subtitle: 'Seller growth recommendations', obs: c.promotionalTips),
              _NotifItem(emoji: '🔔', title: 'Platform Updates', subtitle: 'New features and announcements', obs: c.platformUpdates),
            ],
          ),
        ]),
      ),
    );
  }
}

class _NotifSection extends StatelessWidget {
  final String header;
  final List<_NotifItem> tiles;
  const _NotifSection({required this.header, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: CustomText(text: header, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.8)),
      Container(
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius), boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: ListView.separated(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero,
          itemCount: tiles.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 54, color: AppColors.lightGrey2),
          itemBuilder: (_, i) => tiles[i],
        ),
      ),
    ]);
  }
}

class _NotifItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final RxBool obs;
  const _NotifItem({required this.emoji, required this.title, required this.subtitle, required this.obs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding, vertical: 12),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDimen.borderRadius)), alignment: Alignment.center, child: Text(emoji, style: const TextStyle(fontSize: 16))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText(text: title, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w500, color: AppColors.black),
          const SizedBox(height: 2),
          CustomText(text: subtitle, fontSize: AppFontSize.tiny, color: AppColors.grey),
        ])),
        Obx(() => Switch(value: obs.value, onChanged: (_) => obs.toggle(), activeColor: AppColors.primaryColor)),
      ]),
    );
  }
}
