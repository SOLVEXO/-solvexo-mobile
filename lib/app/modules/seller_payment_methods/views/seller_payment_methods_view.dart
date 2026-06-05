import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_payment_methods/controllers/seller_payment_methods_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPaymentMethodsView extends StatelessWidget {
  SellerPaymentMethodsView({super.key});

  final SellerPaymentMethodsController c =
      Get.put(SellerPaymentMethodsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Payment Methods'),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimen.allPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  label: 'ACCEPTED PAYMENTS',
                  subtitle: 'Enable the payment methods you want to accept in your store.',
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
                    boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: c.methods.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 64, color: AppColors.lightGrey2),
                    itemBuilder: (_, i) => _PaymentTile(method: c.methods[i], onToggle: () => c.toggle(c.methods[i].id)),
                  ),
                ),
                const SizedBox(height: 20),
                _InfoBanner(),
              ],
            ),
          )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final String subtitle;
  const _SectionHeader({required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(text: label, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.8),
      const SizedBox(height: 4),
      CustomText(text: subtitle, fontSize: AppFontSize.verySmall, color: AppColors.grey),
    ]);
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;
  final VoidCallback onToggle;
  const _PaymentTile({required this.method, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding, vertical: 12),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppDimen.borderRadius)),
          alignment: Alignment.center,
          child: Text(method.emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText(text: method.name, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w600, color: AppColors.black),
          const SizedBox(height: 2),
          CustomText(text: method.description, fontSize: AppFontSize.tiny, color: AppColors.grey),
        ])),
        Switch(value: method.isEnabled, onChanged: (_) => onToggle(), activeColor: AppColors.primaryColor),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.languageBg, borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius), border: Border.all(color: AppColors.primaryColor.withOpacity(0.2))),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.primaryColor, size: 18),
        const SizedBox(width: 10),
        const Expanded(child: CustomText(text: 'Payment gateway integrations can be configured from your store dashboard.', fontSize: AppFontSize.tiny, color: AppColors.primaryColor)),
      ]),
    );
  }
}
