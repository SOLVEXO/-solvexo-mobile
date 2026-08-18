import 'dart:async';

import 'package:book_store_app/app/components/app_search_field.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_center_controller.dart';

class HelpSearchBar extends StatefulWidget {
  const HelpSearchBar({super.key});

  @override
  State<HelpSearchBar> createState() => _HelpSearchBarState();
}

class _HelpSearchBarState extends State<HelpSearchBar> {
  // Was a `TextEditingController()` created fresh inside `build()` on a
  // StatelessWidget — since this widget is reconstructed by its parent
  // (`HelpSearchBar()`) on every rebuild, that recreated the controller
  // every time too, silently discarding whatever the user had typed so
  // far. A State object survives across rebuilds, so creating it once
  // here in initState (and disposing it properly) keeps typed text intact.
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value, FaqController controller) {
    // Was setting `controller.searchQuery.value` directly with nothing ever
    // reading it back into `filteredFaqs` — typing here silently did not
    // filter the list. Debounced so we don't fire a network search request
    // on every keystroke.
    controller.searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => controller.searchFaqs(value));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
      child: Obx(
        () => AppSearchField(
          controller: _searchController,
          staticHint: 'Search an issue',
          onChanged: (v) => _onChanged(v, controller),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _debounce?.cancel();
                    controller.searchFaqs('');
                    _searchController.clear();
                  },
                  child: const SvgIcon(
                    assetName: AppIcons.cross,
                    color: AppColors.textPrimary,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
