import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/models/storefront/storefront_model.dart';
import 'package:book_store_app/app/modules/seller_storefront/controllers/seller_storefront_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The storefront's hero header: a rounded cover photo, an overlapping
/// hexagonal logo with a verified badge, name/type/badges, a stat-box row,
/// an "ABOUT" card, and the follow/message actions.
class StorefrontHeader extends StatelessWidget {
  final StorefrontModel store;
  final SellerStorefrontController c;

  const StorefrontHeader({super.key, required this.store, required this.c});

  static const double _coverHeight = 180;
  static const double _logoSize = 92;
  static const double _coverRadius = BaseRadius.xxl;

  bool get _isVerified =>
      store.badges.any((b) => b.toLowerCase().contains('verified'));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cover + back/share buttons + overlapping logo ───────────────────
        SizedBox(
          height: _coverHeight + _logoSize / 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _Cover(store: store),
              Positioned(
                top: MediaQuery.of(context).padding.top + BaseSpacing.xs + 2,
                left: BaseSpacing.md,
                child: _RoundIconButton(
                  icon: AppIcons.chevronLeft,
                  onTap: () => Get.back(),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + BaseSpacing.xs + 2,
                right: BaseSpacing.md,
                child: _RoundIconButton(
                  icon: AppIcons.shareIcon,
                  onTap: c.shareStore,
                ),
              ),
              Positioned(
                bottom: 0,
                left: BaseSpacing.lg,
                child: _HexagonAvatar(
                  store: store,
                  size: _logoSize,
                  isVerified: _isVerified,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: BaseSpacing.xs),

        // ── Name + sellerType ────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: store.name,
                fontWeight: FontWeight.w800,
                fontSize: AppFontSize.medium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (store.sellerType != null && store.sellerType!.isNotEmpty) ...[
                SizedBox(height: BaseSpacing.xs),
                _Pill(
                  text: _prettify(store.sellerType!),
                  icon: Icons.storefront_rounded,
                ),
              ],

              SizedBox(height: BaseSpacing.md),

              // ── Stat boxes ────────────────────────────────────────────────
              Row(
                children: [
                  Obx(
                    () => Expanded(
                      child: _StatBox(
                        label: 'Products',
                        value: '${c.totalProducts.value}',
                      ),
                    ),
                  ),
                  SizedBox(width: BaseSpacing.sm),
                  // `store` is a plain snapshot (not an Rx) — the parent's
                  // Obx already rebuilds this whole header when it changes,
                  // so no inner Obx is needed here.
                  Expanded(
                    child: _StatBox(
                      label: 'Followers',
                      value: '${store.followersCount}',
                    ),
                  ),
                ],
              ),

              SizedBox(height: BaseSpacing.md),

              // ── Actions ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _FollowButton(c: c)),
                  SizedBox(width: BaseSpacing.sm),
                  _MessageButton(c: c),
                ],
              ),
            ],
          ),
        ),

        if (store.description != null &&
            store.description!.trim().isNotEmpty) ...[
          SizedBox(height: BaseSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg),
            child: _AboutCard(description: store.description!),
          ),
        ],

        if (store.badges.isNotEmpty) ...[
          SizedBox(height: BaseSpacing.sm + 2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg),
            child: Wrap(
              spacing: BaseSpacing.xs,
              runSpacing: BaseSpacing.xs,
              children: store.badges
                  .map(
                    (b) =>
                        _Pill(text: _prettify(b), icon: Icons.verified_rounded),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  String _prettify(String raw) => raw
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class _Cover extends StatelessWidget {
  final StorefrontModel store;
  const _Cover({required this.store});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(StorefrontHeader._coverRadius),
        bottomRight: Radius.circular(StorefrontHeader._coverRadius),
      ),
      child: SizedBox(
        height: StorefrontHeader._coverHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            store.coverImage != null && store.coverImage!.isNotEmpty
                ? CommonImageView(url: store.coverImage!, fit: BoxFit.cover)
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryColor, AppColors.accentColor],
                      ),
                    ),
                  ),
            // Subtle top scrim so the back/share buttons stay legible on
            // bright cover photos.
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withOpacity(0.28),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.32),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SvgIcon(assetName: icon, size: 20, color: AppColors.white),
      ),
    );
  }
}

// ─── Hexagon avatar ──────────────────────────────────────────────────────────

class _HexagonClipper extends CustomClipper<Path> {
  const _HexagonClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HexagonAvatar extends StatelessWidget {
  final StorefrontModel store;
  final double size;
  final bool isVerified;

  const _HexagonAvatar({
    required this.store,
    required this.size,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = store.logo != null && store.logo!.isNotEmpty;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // `PhysicalShape` clips AND shadows to the exact hexagon path —
          // a plain circular `Container` behind a hexagon `ClipPath` left
          // round white bulges peeking out past the hexagon's flat edges.
          PhysicalShape(
            clipper: const _HexagonClipper(),
            color: AppColors.white,
            elevation: 3,
            shadowColor: AppColors.black.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipPath(
                clipper: const _HexagonClipper(),
                child: Container(
                  color: AppColors.primaryColor.withOpacity(0.08),
                  child: hasLogo
                      ? CommonImageView(url: store.logo!, fit: BoxFit.cover)
                      : Center(
                          child: CustomText(
                            text: store.initials,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (isVerified)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stat box ────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSpacing.sm,
        vertical: BaseSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(BaseRadius.md),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: BaseSpacing.xxs / 2),
          Text(
            value,
            style: BaseTypography.titleMedium(
              color: AppColors.primaryColor,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

// ─── About card ──────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final String description;
  const _AboutCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: BaseSpacing.sm + 2,
        vertical: BaseSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.md),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        border: Border(
          left: BorderSide(color: AppColors.primaryColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT',
            style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontSize: 10.5,
            ),
          ),
          SizedBox(height: BaseSpacing.xxs + 1),
          Text(
            description,
            style: BaseTypography.bodySmall(color: AppColors.black2),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  final SellerStorefrontController c;
  const _MessageButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: c.isStartingChat.value ? null : c.messageStore,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.md),
            border: Border.all(color: AppColors.lightGrey2),
          ),
          alignment: Alignment.center,
          child: c.isStartingChat.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                )
              : const SvgIcon(
                  assetName: AppIcons.messageIcon,
                  size: 22,
                  color: AppColors.primaryColor,
                ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  const _Pill({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSpacing.sm - 1,
        vertical: BaseSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(BaseRadius.pill),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.primaryColor),
            SizedBox(width: BaseSpacing.xxs),
          ],
          Text(
            text.toUpperCase(),
            style: BaseTypography.labelSmall(color: AppColors.primaryColor)
                .copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final SellerStorefrontController c;
  const _FollowButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final following = c.isFollowing.value;
      final loading = c.isFollowLoading.value;
      return GestureDetector(
        onTap: loading ? null : c.toggleFollow,
        child: AnimatedContainer(
          duration: BaseMotion.normal,
          height: 46,
          decoration: BoxDecoration(
            gradient: following
                ? null
                : const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.accentColor],
                  ),
            color: following ? AppColors.white : null,
            borderRadius: BorderRadius.circular(BaseRadius.md),
            border: Border.all(
              color: following ? AppColors.primaryColor : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: following
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: loading
              ? SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: following ? AppColors.primaryColor : AppColors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      following ? Icons.check_rounded : Icons.add_rounded,
                      size: 17,
                      color: following
                          ? AppColors.primaryColor
                          : AppColors.white,
                    ),
                    SizedBox(width: BaseSpacing.xxs + 2),
                    Text(
                      following ? 'Following' : 'Follow Store',
                      style: BaseTypography.bodySmall(
                        color: following
                            ? AppColors.primaryColor
                            : AppColors.white,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
