import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/app/modules/pos_home/widgets/pos_cart_item_tile.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosCartSheet extends StatelessWidget {
  final PosHomeController c;
  const PosCartSheet({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(children: [
        // ── Handle ────────────────────────────────────────────────
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.lightGrey2,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // ── Header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const CustomText(
              text: 'Cart Summary',
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.bold,
              color: AppColors.black2,
            ),
            const SizedBox(width: 8),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomText(
                text: '${c.itemCount}',
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            )),
            const Spacer(),
            GestureDetector(
              onTap: () { c.clearSale(); Get.back(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CustomText(
                  text: 'Clear All',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppColors.lightGrey2),

        // ── Cart items ────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (c.cartItems.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 36,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const CustomText(
                    text: 'Your cart is empty',
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black2,
                  ),
                  const SizedBox(height: 5),
                  const CustomText(
                    text: 'Tap a product to add it',
                    fontSize: AppFontSize.tiny,
                    color: AppColors.iosGrey,
                  ),
                ]),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: c.cartItems.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppColors.lightGrey2,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (_, i) => PosCartItemTile(c: c, item: c.cartItems[i]),
            );
          }),
        ),

        _CartFooter(c: c),
      ]),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _CartFooter extends StatelessWidget {
  final PosHomeController c;
  const _CartFooter({required this.c});

  static const Map<String, String> _payIcons = {
    'Card': AppIcons.cardIcon,
    'Cash': AppIcons.cashIcon,
    'Tap': AppIcons.barcodeIcon,
    'Split': AppIcons.bankIcon,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.lightGrey2)),
      ),
      padding: EdgeInsets.fromLTRB(
        16, 14, 16, 14 + MediaQuery.of(context).padding.bottom,
      ),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Order summary ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              _TotalRow(
                label: 'Subtotal',
                value: '\$${c.subtotal.toStringAsFixed(2)}',
                bold: false,
              ),
              const SizedBox(height: 6),
              _TotalRow(
                label: 'Tax (${(PosHomeController.taxRate * 100).toStringAsFixed(0)}%)',
                value: '\$${c.tax.toStringAsFixed(2)}',
                bold: false,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: AppColors.lightGrey2),
              ),
              Row(children: [
                const CustomText(
                  text: 'Total',
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black2,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomText(
                    text: '\$${c.total.toStringAsFixed(2)}',
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Payment methods ─────────────────────────────────────
          Row(
            children: c.paymentMethods.map((method) {
              final isSelected = c.selectedPayment.value == method;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => c.selectPayment(method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2,
                        ),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        SvgIcon(
                          assetName: _payIcons[method] ?? AppIcons.duePayment,
                          size: 18,
                          color: isSelected ? AppColors.white : AppColors.iosGrey,
                        ),
                        const SizedBox(height: 3),
                        CustomText(
                          text: method,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.white : AppColors.iosGrey,
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // ── Charge button ───────────────────────────────────────
          GestureDetector(
            onTap: c.hasItems ? () {} : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 54,
              decoration: BoxDecoration(
                gradient: c.hasItems
                    ? const LinearGradient(
                        colors: [Color(0xFFd97757), Color(0xFFE8956A)],
                      )
                    : null,
                color: c.hasItems ? null : AppColors.buttonDisableColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: c.hasItems
                    ? [BoxShadow(color: AppColors.primaryColor.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : [],
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SvgIcon(
                  assetName: _payIcons[c.selectedPayment.value] ?? AppIcons.duePayment,
                  color: AppColors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                CustomText(
                  text: c.hasItems
                      ? 'Charge \$${c.total.toStringAsFixed(2)} · ${c.selectedPayment.value}'
                      : 'Add items to charge',
                  color: AppColors.white,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.bold,
                ),
              ]),
            ),
          ),
        ],
      )),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _TotalRow({required this.label, required this.value, required this.bold});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CustomText(
        text: label,
        fontSize: AppFontSize.verySmall,
        color: bold ? AppColors.black2 : AppColors.iosGrey,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
      ),
      const Spacer(),
      CustomText(
        text: value,
        fontSize: AppFontSize.verySmall,
        fontWeight: FontWeight.w500,
        color: bold ? AppColors.primaryColor : AppColors.black2,
      ),
    ]);
  }
}
