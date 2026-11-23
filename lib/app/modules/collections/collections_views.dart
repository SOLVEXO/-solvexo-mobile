import 'package:book_store_app/app/components/buyer_states.dart';
import 'package:book_store_app/app/data/repositories/collections_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/money.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Which shelf a [ShelfView] shows. Route args: {'kind': ShelfKind.name, 'slug': ...}.
enum ShelfKind { bundle, picks, learningPath }

/// Bundle / curated picks / learning path page (R2 deep-link targets:
/// /bundles/:slug, /picks/:slug, /learning-paths/:slug). Prices are the
/// server's (bundleQuote); nothing is calculated here.
class ShelfView extends StatefulWidget {
  const ShelfView({super.key, this.kind, this.slug, this.repo});
  final ShelfKind? kind;
  final String? slug;
  final CollectionsRepository? repo;

  @override
  State<ShelfView> createState() => _ShelfViewState();
}

class _ShelfViewState extends State<ShelfView> {
  late final CollectionsRepository _repo = widget.repo ?? CollectionsRepository();
  late final Map _args = Get.arguments is Map ? Get.arguments as Map : const {};
  late final ShelfKind _kind = widget.kind ?? ShelfKind.values.firstWhere((k) => k.name == _args['kind'], orElse: () => ShelfKind.picks);
  late final String _slug = widget.slug ?? '${_args['slug'] ?? ''}';
  Map? _data;
  bool _loading = true, _failed = false;

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
      final d = switch (_kind) {
        ShelfKind.bundle => await _repo.bundle(_slug),
        ShelfKind.picks => await _repo.picks(_slug),
        ShelfKind.learningPath => await _repo.learningPath(_slug),
      };
      if (mounted) setState(() => _data = d);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
    if (mounted) setState(() => _loading = false);
  }

  String get _fallbackTitle => switch (_kind) {
        ShelfKind.bundle => 'Bundle'.tr,
        ShelfKind.picks => 'Picks'.tr,
        ShelfKind.learningPath => 'Learning path'.tr,
      };

  static List<ProductModel> _products(Object? list) =>
      (list as List? ?? []).whereType<Map>().map((m) => ProductModel.fromJson(Map<String, dynamic>.from(m))).toList();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final d = _data;
    Widget body;
    if (_loading) {
      body = const BuyerSkeleton(rows: 4);
    } else if (_failed) {
      body = BuyerError(message: 'Could not load this page.'.tr, onRetry: _load);
    } else if (d == null) {
      body = BuyerEmpty(icon: Icons.link_off_rounded, title: 'This page is not available'.tr);
    } else {
      final children = <Widget>[
        if ((d['subtitle'] ?? '').toString().isNotEmpty) Text('${d['subtitle']}', style: t.textTheme.titleSmall),
        if ((d['ageLabel'] ?? '').toString().isNotEmpty) Text('${d['ageLabel']}', style: t.textTheme.bodySmall),
        if ((d['description'] ?? '').toString().isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 6), child: Text('${d['description']}')),
      ];
      if (_kind == ShelfKind.bundle) {
        children.add(Card(
          key: const Key('bundlePrice'),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            title: Text(Money.format(d['bundlePrice'] as num?, d['currency'] as String?), style: t.textTheme.titleLarge),
            subtitle: Text('${'Instead of'.tr} ${Money.format(d['totalPrice'] as num?, d['currency'] as String?)} · '
                '${'You save'.tr} ${Money.format(d['savings'] as num?, d['currency'] as String?)}'),
            trailing: d['storeName'] == null ? null : Text('${d['storeName']}', style: t.textTheme.bodySmall),
          ),
        ));
        children.add(Text('Buy all items in one order from this store to get the bundle price.'.tr, style: t.textTheme.bodySmall));
        children.addAll(_products(d['products']).map(_tile));
      } else if (_kind == ShelfKind.learningPath) {
        final steps = (d['steps'] as List? ?? []).whereType<Map>().toList();
        if (steps.isEmpty) children.add(BuyerEmpty(icon: Icons.route_outlined, title: 'Nothing here yet'.tr));
        for (var i = 0; i < steps.length; i++) {
          children.add(Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text('${'Step'.tr} ${i + 1}: ${steps[i]['title'] ?? ''}', style: t.textTheme.titleMedium),
          ));
          if ((steps[i]['note'] ?? '').toString().isNotEmpty) Text('${steps[i]['note']}', style: t.textTheme.bodySmall);
          children.addAll(_products(steps[i]['products']).map(_tile));
        }
      } else {
        final ps = _products(d['products']);
        if (ps.isEmpty) children.add(BuyerEmpty(icon: Icons.collections_bookmark_outlined, title: 'Nothing here yet'.tr));
        children.addAll(ps.map(_tile));
      }
      body = ListView(padding: const EdgeInsets.all(16), children: children);
    }
    return Scaffold(appBar: AppBar(title: Text('${d?['title'] ?? d?['name'] ?? _fallbackTitle}')), body: body);
  }

  Widget _tile(ProductModel p) => Card(
        child: ListTile(
          minTileHeight: 72,
          leading: p.images.isEmpty
              ? const Icon(Icons.image_outlined)
              : CachedNetworkImage(imageUrl: p.images.first, width: 56, height: 56, memCacheWidth: 168, fit: BoxFit.contain),
          title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: p.currency == null ? null : Text(Money.format(p.price, p.currency)),
          onTap: () => Get.toNamed(Routes.productDetailsView, arguments: {'productId': p.id}),
        ),
      );
}

/// All learning paths (/learning-paths).
class LearningPathsView extends StatefulWidget {
  const LearningPathsView({super.key, this.repo});
  final CollectionsRepository? repo;

  @override
  State<LearningPathsView> createState() => _LearningPathsViewState();
}

class _LearningPathsViewState extends State<LearningPathsView> {
  late final CollectionsRepository _repo = widget.repo ?? CollectionsRepository();
  List<Map>? _items;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _items = null;
      _failed = false;
    });
    try {
      final r = await _repo.learningPaths();
      if (mounted) setState(() => _items = r);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_failed) {
      body = BuyerError(message: 'Could not load this page.'.tr, onRetry: _load);
    } else if (_items == null) {
      body = const BuyerSkeleton(rows: 4);
    } else if (_items!.isEmpty) {
      body = BuyerEmpty(icon: Icons.route_outlined, title: 'No learning paths yet'.tr);
    } else {
      body = ListView(padding: const EdgeInsets.all(16), children: [
        for (final p in _items!)
          Card(
            child: ListTile(
              minTileHeight: 64,
              title: Text('${p['title'] ?? ''}'),
              subtitle: Text([p['ageLabel'], if (p['stepCount'] != null) '${p['stepCount']} ${'steps'.tr}'].whereType<Object>().join(' · ')),
              onTap: () => Get.toNamed(Routes.shelf, arguments: {'kind': ShelfKind.learningPath.name, 'slug': p['slug']}),
            ),
          ),
      ]);
    }
    return Scaffold(appBar: AppBar(title: Text('Learning paths'.tr)), body: body);
  }
}
