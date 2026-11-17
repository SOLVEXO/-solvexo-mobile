import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller/utils/store_currency.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Price field prefix from the store's baseCurrency ("Rs" for PKR, "$" for
/// USD). Shows nothing until the currency is known.
class StoreCurrencyPrefix extends StatelessWidget {
  const StoreCurrencyPrefix({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final symbol = StoreCurrency.symbol;
      if (symbol.isEmpty) return const SizedBox(width: 14);
      return Padding(
        padding: const EdgeInsets.only(left: 14, right: 6),
        child: CustomText(
          text: symbol,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        ),
      );
    });
  }
}
