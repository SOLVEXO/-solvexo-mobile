import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/storefront/storefront_model.dart';
import 'package:book_store_app/app/modules/seller_storefront/controllers/seller_storefront_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The storefront's hero header: a rounded cover photo, an overlapping
/// circular logo with a verified badge, name/type/badges, a follow-count
/// stats row, an "About" card, and the follow/share actions.
class StorefrontHeader extends StatelessWidget {
  final StorefrontModel store;
  final SellerStorefrontController c;

  const StorefrontHeader({super.key, required this.store, required this.c});

  static const double _coverHeight = 200;
  static const double _logoSize = 88;
  static const double _coverRadius = 28;

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
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                child: _RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Get.back(),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: _RoundIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: c.shareStore,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 20,
                child: Container(
                  width: _logoSize,
                  height: _logoSize,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.14),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_logoSize / 2),
                        child: store.logo != null && store.logo!.isNotEmpty
                            ? CommonImageView(url: store.logo!, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                alignment: Alignment.center,
                                child: CustomText(
                                  text: store.initials,
                                  fontSize: AppFontSize.veryLarge,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                      ),
                      if (_isVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
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
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Name + sellerType ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomText(
                      text: store.name,
                      fontSize: AppFontSize.large,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (store.sellerType != null && store.sellerType!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _Pill(text: _prettify(store.sellerType!), icon: Icons.storefront_rounded),
              ],

              const SizedBox(height: 14),

              // ── Stats row ─────────────────────────────────────────────────
              Row(
                children: [
                  Obx(
                    () => _StatChip(
                      icon: Icons.grid_view_rounded,
                      label: 'Products',
                      value: c.totalProducts.value.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // `store` is a plain snapshot (not an Rx) — the parent's
                  // Obx already rebuilds this whole header when it changes,
                  // so no inner Obx is needed (and none would have anything
                  // observable to read).
                  _StatChip(
                    icon: Icons.people_alt_rounded,
                    label: 'Followers',
                    value: '${store.followersCount}',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Actions ───────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _FollowButton(c: c)),
                  const SizedBox(width: 10),
                  _MessageButton(c: c),
                ],
              ),
            ],
          ),
        ),

        if (store.description != null && store.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightGrey3,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'About the store',
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600,
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    text: store.description!,
                    fontSize: AppFontSize.verySmall,
                    color: AppColors.black2,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],

        if (store.badges.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: store.badges
                  .map((b) => _Pill(text: _prettify(b), icon: Icons.verified_rounded))
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
                  colors: [AppColors.black.withOpacity(0.28), Colors.transparent],
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
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.32),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: AppColors.white),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          CustomText(
            text: value,
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w700,
            color: AppColors.black2,
          ),
          const SizedBox(width: 4),
          CustomText(
            text: label,
            fontSize: AppFontSize.tiny,
            color: AppColors.gray600,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey2),
          ),
          alignment: Alignment.center,
          child: c.isStartingChat.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                )
              : const Icon(Icons.chat_bubble_outline_rounded, size: 19, color: AppColors.primaryColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.primaryColor),
            const SizedBox(width: 4),
          ],
          CustomText(
            text: text,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
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
          duration: const Duration(milliseconds: 180),
          height: 44,
          decoration: BoxDecoration(
            gradient: following
                ? null
                : const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.accentColor],
                  ),
            color: following ? AppColors.white : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: following ? AppColors.lightGrey2 : Colors.transparent,
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
                      color: following ? AppColors.black2 : AppColors.white,
                    ),
                    const SizedBox(width: 6),
                    CustomText(
                      text: following ? 'Following' : 'Follow Store',
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w700,
                      color: following ? AppColors.black2 : AppColors.white,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
