import 'package:book_store_app/app/data/repositories/collections_repository.dart';
import 'package:book_store_app/app/modules/collections/collections_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Live 2026-11-23: GET /api/bundles/public?limit=3, /api/curated-collections/home and
// /api/learning-paths all return {success:true, data:[]} (none published yet), so the
// detail shapes below follow bundles.service.ts (bundleQuote), curated-collections.service.ts
// and learning-paths.service.ts at 5adba44. Unknown slug -> 404 -> "not available".
class _Repo extends CollectionsRepository {
  _Repo(this.d);
  final Map? d;
  @override
  Future<Map?> bundle(String slug) async => d;
  @override
  Future<Map?> picks(String slug) async => d;
  @override
  Future<Map?> learningPath(String slug) async => d;
}

Widget _app(Widget w) => GetMaterialApp(home: w);

void main() {
  testWidgets('bundle shows the server bundle price, total and savings', (t) async {
    await t.pumpWidget(_app(ShelfView(kind: ShelfKind.bundle, slug: 's', repo: _Repo({
      'name': 'Starter set', 'storeName': 'Jami Store', 'currency': 'PKR',
      'totalPrice': 2000, 'bundlePrice': 1800, 'savings': 200, 'discountPercent': 10, 'products': [],
    }))));
    await t.pumpAndSettle();
    expect(find.text('Starter set'), findsOneWidget);
    expect(find.text('Rs 1,800'), findsOneWidget);
    expect(find.textContaining('Rs 2,000'), findsOneWidget);
    expect(find.textContaining('Rs 200'), findsOneWidget);
  });

  testWidgets('learning path lists steps; unknown slug -> not available', (t) async {
    await t.pumpWidget(_app(ShelfView(kind: ShelfKind.learningPath, slug: 's', repo: _Repo({
      'title': 'Grade 1', 'steps': [{'title': 'Alphabet', 'note': 'Start here', 'products': []}],
    }))));
    await t.pumpAndSettle();
    expect(find.text('Step 1: Alphabet'), findsOneWidget);
    await t.pumpWidget(_app(ShelfView(key: const Key('b'), kind: ShelfKind.picks, slug: 'x', repo: _Repo(null))));
    await t.pumpAndSettle();
    expect(find.text('This page is not available'), findsOneWidget);
  });
}
