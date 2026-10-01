import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class CustomActionCard extends StatelessWidget {
  const CustomActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.highlighted = false,
    this.onTap,
  });
  final String icon;
  final String label;
  final String? subtitle;

  /// Filled gradient hero style, used for the primary action.
  final bool highlighted;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? AppColors.white : AppColors.black;
    final subFg = highlighted
        ? AppColors.white.withOpacity(0.8)
        : AppColors.lightGrey5;

    return Material(
      color: AppColors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: highlighted ? null : AppColors.white,
          gradient: highlighted
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryColor, Color(0xFF5B9BDB)],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: highlighted
              ? null
              : Border.all(color: AppColors.primaryColorLight),
          // boxShadow: [
          //   BoxShadow(
          //     color: (highlighted ? AppColors.primaryColor : AppColors.black)
          //         .withOpacity(highlighted ? 0.28 : 0.05),
          //     blurRadius: highlighted ? 16 : 8,
          //     offset: const Offset(0, 6),
          //   ),
          // ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: highlighted ? _hero(fg, subFg) : _compact(fg, subFg),
          ),
        ),
      ),
    );
  }

  Widget _iconBadge({required bool onGradient, double size = 44}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onGradient
            ? AppColors.white.withOpacity(0.22)
            : AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: SvgIcon(
        assetName: icon,
        size: size * 0.5,
        color: onGradient ? AppColors.white : AppColors.primaryColor,
      ),
    );
  }

  Widget _hero(Color fg, Color subFg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _iconBadge(onGradient: true, size: 48),
            Icon(Icons.arrow_outward_rounded, color: fg, size: 20),
          ],
        ),
        const Spacer(),
        CustomText(
          text: label,
          color: fg,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          CustomText(text: subtitle!, color: subFg, fontSize: 11),
        ],
      ],
    );
  }

  Widget _compact(Color fg, Color subFg) {
    return Row(
      children: [
        _iconBadge(onGradient: false, size: 40),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                CustomText(
                  text: subtitle!,
                  color: subFg,
                  fontSize: 10.5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
