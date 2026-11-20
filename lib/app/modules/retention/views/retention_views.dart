import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/data/repositories/retention_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

/// Wishlist share link + alerts (B6). Opened from the Wishlist app bar.
/// Alerts = the `promotions` notification preference: wishlist price-drop /
/// back-in-stock alerts are sent in that category (notification.types.ts).
class WishlistShareSheet extends StatefulWidget {
  const WishlistShareSheet({super.key, this.repo, this.prefs});
  final RetentionRepository? repo;
  final NotificationsRepository? prefs;

  static Future<void> open() => Get.bottomSheet(const WishlistShareSheet(), isScrollControlled: true, backgroundColor: Get.theme.colorScheme.surface);

  @override
  State<WishlistShareSheet> createState() => _WishlistShareSheetState();
}

class _WishlistShareSheetState extends State<WishlistShareSheet> {
  late final RetentionRepository _repo = widget.repo ?? RetentionRepository();
  late final NotificationsRepository _prefs = widget.prefs ?? NotificationsRepository();
  WishlistShare? _share;
  bool? _alerts;
  bool _loading = true, _failed = false, _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final share = await _repo.myShare();
      final p = await _prefs.getPreferences();
      final prefs = p?['prefs'] is Map ? p!['prefs'] as Map : const {};
      setState(() {
        _share = share;
        _alerts = prefs['promotions'] as bool? ?? true;
      });
    } catch (_) {
      setState(() => _failed = true);
    }
    setState(() => _loading = false);
  }

  Future<void> _run(Future<WishlistShare> Function() call) async {
    setState(() => _busy = true);
    try {
      final s = await call();
      setState(() => _share = s);
    } catch (_) {
      ToastUtil.showToast('Something went wrong. Please try again.'.tr);
    }
    setState(() => _busy = false);
  }

  Future<void> _toggleAlerts(bool v) async {
    final before = _alerts;
    setState(() => _alerts = v);
    if (!await _prefs.updatePreferences({'promotions': v})) setState(() => _alerts = before);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final s = _share;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
            : _failed
                ? SizedBox(height: 220, child: BuyerError(message: 'Could not load your share link.'.tr, onRetry: _load))
                : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('Share your wishlist'.tr, style: t.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('Anyone with the link can see the items in your wishlist.'.tr, style: t.textTheme.bodySmall),
                    const SizedBox(height: 12),
                    if (s?.active == true && s?.url != null) ...[
                      SelectableText(s!.url!, key: const Key('shareUrl')),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: s.url!));
                              ToastUtil.showToast('Link copied'.tr);
                            },
                            icon: const Icon(Icons.copy_rounded),
                            label: Text('Copy'.tr),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('shareWishlist'),
                            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                            onPressed: () => SharePlus.instance.share(ShareParams(text: s.url!)),
                            icon: const Icon(Icons.share_rounded),
                            label: Text('Share'.tr),
                          ),
                        ),
                      ]),
                      TextButton(
                        key: const Key('stopSharing'),
                        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                        onPressed: _busy ? null : () => _run(_repo.revokeShare),
                        child: Text('Turn off the link'.tr),
                      ),
                    ] else
                      FilledButton(
                        key: const Key('createShare'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        onPressed: _busy ? null : () => _run(_repo.createShare),
                        child: Text('Create a share link'.tr),
                      ),
                    const Divider(height: 24),
                    SwitchListTile(
                      key: const Key('wishlistAlerts'),
                      contentPadding: EdgeInsets.zero,
                      value: _alerts ?? true,
                      onChanged: _toggleAlerts,
                      title: Text('Price drop and back-in-stock alerts'.tr),
                      subtitle: Text('Part of your offers notifications.'.tr),
                    ),
                  ]),
      ),
    );
  }
}

/// Public shared wishlist (/wishlist/shared, args {token}; deep link
/// /wishlist/shared/:token). No sign-in needed.
class SharedWishlistView extends StatefulWidget {
  const SharedWishlistView({super.key, this.repo, this.token});
  final RetentionRepository? repo;
  final String? token;

  @override
  State<SharedWishlistView> createState() => _SharedWishlistViewState();
}

class _SharedWishlistViewState extends State<SharedWishlistView> {
  late final RetentionRepository _repo = widget.repo ?? RetentionRepository();
  late final String _token = widget.token ?? (Get.arguments is Map ? '${(Get.arguments as Map)['token'] ?? ''}' : '');
  List<Map>? _items;
  bool _failed = false, _gone = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _failed = _gone = false;
    });
    try {
      final items = await _repo.sharedWishlist(_token);
      setState(() => _items = items);
    } catch (e) {
      final gone = (e is DioException && e.response?.statusCode == 404) || '$e'.contains('404');
      setState(() => gone ? _gone = true : _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_gone) {
      body = BuyerEmpty(icon: Icons.link_off_rounded, title: 'This link is not available'.tr);
    } else if (_failed) {
      body = BuyerError(message: 'Could not load this wishlist.'.tr, onRetry: _load);
    } else if (_items == null) {
      body = const BuyerSkeleton();
    } else if (_items!.isEmpty) {
      body = BuyerEmpty(icon: Icons.favorite_border_rounded, title: 'This wishlist is empty'.tr);
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final p = ProductModel.fromJson(Map<String, dynamic>.from(_items![i]));
          return Card(
            child: ListTile(
              minTileHeight: 72,
              leading: p.images.isEmpty ? const Icon(Icons.image_outlined) : CachedNetworkImage(imageUrl: p.images.first, width: 56, height: 56, fit: BoxFit.contain),
              title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: p.sellerName == null ? null : Text(p.sellerName!),
              onTap: () => Get.toNamed(Routes.productDetailsView, arguments: {'productId': p.id}),
            ),
          );
        },
      );
    }
    return Scaffold(appBar: AppBar(title: Text('Shared wishlist'.tr)), body: body);
  }
}

/// Referrals (/account/referrals): your code and link, the reward, stats,
/// and "Have a code?" for new buyers. All values from GET /api/referrals/me.
class ReferralsView extends StatefulWidget {
  const ReferralsView({super.key, this.repo});
  final RetentionRepository? repo;

  @override
  State<ReferralsView> createState() => _ReferralsViewState();
}

class _ReferralsViewState extends State<ReferralsView> {
  late final RetentionRepository _repo = widget.repo ?? RetentionRepository();
  final _code = TextEditingController();
  ReferralInfo? _info;
  bool _failed = false, _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _info = null;
      _failed = false;
    });
    try {
      final i = await _repo.myReferral();
      setState(() => _info = i);
    } catch (_) {
      setState(() => _failed = true);
    }
  }

  Future<void> _apply() async {
    if (_code.text.trim().isEmpty) return setState(() => _error = 'Enter a code.'.tr);
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await _repo.applyReferral(_code.text);
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) {
      ToastUtil.showToast('Referral code added'.tr);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final i = _info;
    Widget body;
    if (_failed) {
      body = BuyerError(message: 'Could not load referrals.'.tr, onRetry: _load);
    } else if (i == null) {
      body = const BuyerSkeleton(rows: 3);
    } else if (!i.enabled) {
      body = BuyerEmpty(icon: Icons.card_giftcard_outlined, title: 'Referrals are not available right now'.tr);
    } else {
      body = ListView(padding: const EdgeInsets.all(16), children: [
        Text('${'Invite a friend and get'.tr} ${i.reward['label'] ?? ''}', style: t.textTheme.titleMedium),
        if (i.reward['friendLabel'] != null) Text('${'Your friend gets'.tr} ${i.reward['friendLabel']}'),
        const SizedBox(height: 12),
        if (i.code != null) SelectableText(i.code!, key: const Key('referralCode'), style: t.textTheme.headlineSmall),
        if (i.shareUrl != null)
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => SharePlus.instance.share(ShareParams(text: i.shareUrl!)),
            icon: const Icon(Icons.share_rounded),
            label: Text('Share your link'.tr),
          ),
        const SizedBox(height: 12),
        Text('${'Waiting'.tr}: ${i.stats['pending'] ?? 0} · ${'Rewarded'.tr}: ${i.stats['rewarded'] ?? 0} / ${i.stats['cap'] ?? ''}'),
        if (!i.referredByAnyone) ...[
          const Divider(height: 32),
          Text('Have a referral code?'.tr, style: t.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(key: const Key('referralInput'), controller: _code, decoration: InputDecoration(labelText: 'Code'.tr, errorText: _error, border: const OutlineInputBorder())),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: _busy ? null : _apply,
            child: Text('Apply'.tr),
          ),
        ],
      ]);
    }
    return Scaffold(appBar: AppBar(title: Text('Invite friends'.tr)), body: body);
  }
}
