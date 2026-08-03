import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_request_payout_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinanceBalanceCard extends StatelessWidget {
  final SellerFinanceController controller;
  const FinanceBalanceCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => controller.availableCurrencies.length > 1 ? _CurrencySwitcher(controller: controller) : const SizedBox.shrink()),
        Obx(() => controller.isFlaggedForReview ? _FlaggedBalanceBanner(reason: controller.flaggedReason) : const SizedBox.shrink()),
        _balanceCard(),
      ],
    );
  }

  Widget _balanceCard() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D1117), Color(0xFF1C2333)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Decorative circle
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Available Balance',
                        fontSize: AppFontSize.verySmall,
                        color: AppColors.lightGrey8,
                        fontWeight: FontWeight.w500,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const CustomText(
                              text: 'Active',
                              fontSize: AppFontSize.tiny,
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomText(
                    text: controller.amountLabel(controller.availableBalance),
                    fontSize: AppFontSize.large,
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTextStyles.monoFontFamily,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _MetaChip(
                        icon: AppIcons.cross,
                        label: 'Pending',
                        value: controller.amountLabel(controller.pendingBalance),
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: AppIcons.calenderIcon,
                        label: 'Next payout',
                        value: controller.nextPayoutDate,
                        valueColor: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: AppIcons.bankIcon,
                        label: 'Method',
                        value: controller.paymentMethod,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _RequestPayoutButton(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color valueColor;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFFCBD5E1),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(assetName: icon, size: 11, color: AppColors.lightGrey8),
            const SizedBox(width: 4),
            CustomText(
              text: label,
              fontSize: 10,
              color: AppColors.lightGrey8,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
        const SizedBox(height: 3),
        CustomText(
          text: value,
          fontSize: AppFontSize.verySmall,
          color: valueColor,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

class _RequestPayoutButton extends StatelessWidget {
  final SellerFinanceController controller;
  const _RequestPayoutButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FinanceRequestPayoutSheet.show(context, controller),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.payments_rounded, color: AppColors.white, size: 17),
            SizedBox(width: 8),
            CustomText(
              text: 'Request Payout',
              fontSize: AppFontSize.small2,
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}

/// Lets a seller who earns in more than one currency (e.g. USD via Stripe
/// and PKR via manual bank transfer) switch which wallet the whole Finance
/// screen — balance, stats, transactions, schedule — is currently showing.
class _CurrencySwitcher extends StatelessWidget {
  final SellerFinanceController controller;
  const _CurrencySwitcher({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
          child: Row(
            children: controller.availableCurrencies.map((currency) {
              final selected = controller.selectedCurrency.value == currency;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.selectCurrency(currency),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryColor : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.primaryColor : AppColors.lightGrey11),
                    ),
                    child: CustomText(
                      text: currency,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.white : AppColors.lightGrey5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

/// Shown above the balance card when a refund/chargeback exceeded what the
/// seller still had on hand (they'd already withdrawn it) — the negative
/// balance is real debt against future earnings, not a bug, so this makes it
/// visible instead of the seller only noticing an odd number in their history.
class _FlaggedBalanceBanner extends StatelessWidget {
  final String? reason;
  const _FlaggedBalanceBanner({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 15, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: 'Account flagged for review',
                  color: AppColors.error,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: reason ?? 'A refund exceeded your available balance — this will be deducted from future earnings.',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
