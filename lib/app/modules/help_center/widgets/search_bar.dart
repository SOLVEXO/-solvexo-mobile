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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FaqController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs + 1),
      child: Obx(
        () => AppSearchField(
          controller: _searchController,
          staticHint: 'Search an issue',
          onChanged: (v) => controller.searchQuery.value = v,
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.searchQuery.value = "";
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
