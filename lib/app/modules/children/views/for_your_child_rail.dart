import 'package:book_store_app/app/data/repositories/children_repository.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/storefront/widgets/product_horizontal_section.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "For [child]" rail on Home (B4): products covering the first saved
/// child's class (GET products-by-category, `class` = slug). Hidden for
/// guests, without children, or when nothing matches.
class ForYourChildRail extends StatefulWidget {
  const ForYourChildRail({super.key});

  @override
  State<ForYourChildRail> createState() => _ForYourChildRailState();
}

class _ForYourChildRailState extends State<ForYourChildRail> {
  Child? _child;
  List<ProductModel> _products = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (!await AppPreferences.isLoggedIn()) return;
      final kids = await ChildrenRepository().list();
      final child = kids.firstWhereOrNull((c) => c.gradeLabel != null);
      if (child == null) return;
      final r = await ProductRepository().getProductsByCategory(classLevel: child.gradeLabel, limit: 10);
      if (!mounted) return;
      setState(() {
        _child = child;
        _products = r?.products ?? const [];
      });
    } catch (_) {
      // A personal rail never blocks Home.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_child == null || _products.isEmpty) return const SizedBox.shrink();
    return ProductHorizontalSection(key: const Key('forYourChild'), title: '${'For'.tr} ${_child!.name}', products: _products);
  }
}
