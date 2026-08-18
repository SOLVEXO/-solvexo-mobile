import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// One side-slot item (the 4 flat icon+label items either side of the
/// floating center button). [index] is the original tab index used by the
/// screen's GetX controller — it does not have to match this item's visual
/// position, so bars can reorder tabs visually without touching controllers.
class WaveNavItem {
  final Widget Function(bool active) iconBuilder;
  final String label;
  final int index;

  const WaveNavItem({
    required this.iconBuilder,
    required this.label,
    required this.index,
  });
}

/// A floating, fully-rounded bottom nav bar with a scooped notch under a
/// raised circular center button — 2 flat icon+label items on each side.
class WaveBottomNavBar extends StatelessWidget {
  final List<WaveNavItem> sideItems;
  final WaveNavItem centerItem;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final int centerBadgeCount;

  const WaveBottomNavBar({
    super.key,
    required this.sideItems,
    required this.centerItem,
    required this.activeIndex,
    required this.onTap,
    this.centerBadgeCount = 0,
  }) : assert(
         sideItems.length == 4,
         'WaveBottomNavBar needs exactly 4 side items',
       );

  static const double _barHeight = 64;
  static const double _centerSize = 64;
  static const double _centerLift = 30;
  static const double _cornerRadius = BaseRadius.xxl;
  static const double _notchGap = 10;

  double get _poke => _centerLift + _centerSize / 2;

  /// Total footprint from the screen's bottom edge (bar height + raised
  /// center button + bottom margin), excluding the device safe-area inset.
  /// Scrollable tabs behind this floating bar should reserve at least this
  /// much bottom clearance so their last item can scroll fully clear of it
  /// instead of resting permanently tucked behind it.
  static const double totalHeight =
      _barHeight + _centerLift + _centerSize / 2 + BaseSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final barWidth = width - BaseSpacing.md * 2;
    final notchRadius = _centerSize / 2 + _notchGap;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BaseSpacing.md,
          0,
          BaseSpacing.md,
          BaseSpacing.xs,
        ),
        child: SizedBox(
          height: _barHeight + _poke,
          width: barWidth,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barHeight,
                child: DecoratedBox(
                  // `foreground` so the border is painted on top of the
                  // notched white child below — with the default
                  // `background` position it sat *under* that opaque fill
                  // and was completely invisible.
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_cornerRadius),
                    border: BorderDirectional(
                      bottom: BorderSide(
                        color: AppColors.primaryColor,
                        width: 3,
                      ),
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_cornerRadius),
                      boxShadow: [
                        // Soft ambient halo so the shadow actually wraps the
                        // rounded/notched shape instead of just showing below
                        // it — a plain BoxDecoration shadow with no offset
                        // still renders as a rectangle without borderRadius.
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.10),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                        ...BaseShadows.forLevel(BaseElevation.level3),
                      ],
                    ),
                    child: ClipPath(
                      clipper: _NotchedBarClipper(
                        cornerRadius: _cornerRadius,
                        notchCenterX: barWidth / 2,
                        notchRadius: notchRadius,
                      ),
                      child: Container(
                        color: AppColors.white,
                        child: Row(
                          children: [
                            Expanded(child: _sideItem(sideItems[0])),
                            Expanded(child: _sideItem(sideItems[1])),
                            SizedBox(width: _centerSize + BaseSpacing.md),
                            Expanded(child: _sideItem(sideItems[2])),
                            Expanded(child: _sideItem(sideItems[3])),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: barWidth / 2 - _centerSize / 2,
                bottom: _barHeight - _centerSize / 14 - _centerLift,
                child: _centerButton(centerItem),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sideItem(WaveNavItem item) {
    final isActive = activeIndex == item.index;
    final color = isActive ? AppColors.primaryColor : AppColors.inactiveGrey;
    return InkWell(
      onTap: () => onTap(item.index),
      splashColor: AppColors.primaryColor.withOpacity(0.1),
      highlightColor: AppColors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.iconBuilder(isActive),
          const SizedBox(height: BaseSpacing.xxs),
          CustomText(
            text: item.label,
            fontSize: AppFontSize.tiny,
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ],
      ),
    );
  }

  Widget _centerButton(WaveNavItem item) {
    final isActive = activeIndex == item.index;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.primaryColor,
          shape: const CircleBorder(),
          elevation: 0,
          child: Container(
            width: _centerSize,
            height: _centerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: BaseShadows.glow(AppColors.primaryColor),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onTap(item.index),
              child: Center(child: item.iconBuilder(isActive)),
            ),
          ),
        ),
        if (centerBadgeCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: centerBadgeCount > 9 ? '9+' : centerBadgeCount.toString(),
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotchedBarClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double notchCenterX;
  final double notchRadius;

  const _NotchedBarClipper({
    required this.cornerRadius,
    required this.notchCenterX,
    required this.notchRadius,
  });

  @override
  Path getClip(Size size) {
    final barPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );
    final notchPath = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(notchCenterX, 0), radius: notchRadius),
      );
    return Path.combine(PathOperation.difference, barPath, notchPath);
  }

  @override
  bool shouldReclip(covariant _NotchedBarClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchCenterX != notchCenterX ||
        oldClipper.notchRadius != notchRadius;
  }
}
