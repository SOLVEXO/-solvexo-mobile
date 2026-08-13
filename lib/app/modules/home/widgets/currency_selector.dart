import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/services/currency_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Flag + code shown for each currency [CurrencyController] supports.
/// UI-only display metadata — kept next to the widget rather than on the
/// controller, which only deals in currency codes.
const Map<String, _CurrencyDisplay> _currencyDisplay = {
  'PKR': _CurrencyDisplay(flag: '🇵🇰', name: 'Pakistani Rupee'),
  'USD': _CurrencyDisplay(flag: '🇺🇸', name: 'US Dollar'),
};

class _CurrencyDisplay {
  final String flag;
  final String name;
  const _CurrencyDisplay({required this.flag, required this.name});
}

/// Quick currency switcher — same 40px-tall footprint as the notification/
/// message [IconBadge]s it sits next to, so it lines up in the Home header
/// row. Changing it updates every converted price shown via
/// [CurrencyController] (currently: the Home products grid) and, for
/// logged-in buyers, persists the choice server-side.
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  CurrencyController get _controller {
    if (!Get.isRegistered<CurrencyController>()) {
      Get.put(CurrencyController(), permanent: true);
    }
    return Get.find<CurrencyController>();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Obx(() {
      final selected = controller.selectedCurrency.value;
      final selectedFlag = _currencyDisplay[selected]?.flag ?? '';

      return PopupMenuButton<String>(
        initialValue: selected,
        onSelected: controller.setCurrency,
        offset: const Offset(0, 50),
        elevation: 6,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseRadius.md),
          side: BorderSide(color: AppColors.lightGrey2),
        ),
        itemBuilder: (context) => CurrencyController.supportedCurrencies
            .map((currency) => _buildMenuItem(currency, selected))
            .toList(),
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.md),
            border: Border.all(color: AppColors.lightGrey2),
            boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(text: selectedFlag, fontSize: 18),
              SizedBox(width: BaseSpacing.xxs),
              CustomText(
                text: selected,
                color: AppColors.black2,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(width: BaseSpacing.xxs / 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.gray600,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }

  PopupMenuItem<String> _buildMenuItem(String currency, String selected) {
    final display = _currencyDisplay[currency];
    final isSelected = currency == selected;

    return PopupMenuItem<String>(
      value: currency,
      height: 48,
      child: Row(
        children: [
          CustomText(text: display?.flag ?? '', fontSize: 20),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: currency,
                  color: isSelected ? AppColors.primaryColor : AppColors.black2,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                if (display != null)
                  CustomText(
                    text: display.name,
                    color: AppColors.gray600,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryColor,
              size: 18,
            ),
        ],
      ),
    );
  }
}
