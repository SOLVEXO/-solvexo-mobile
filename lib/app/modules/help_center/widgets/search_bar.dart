import 'package:book_store_app/app/components/custom_text_field.dart';
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
      child: CustomTextField(
        controller: _searchController,
        isborder: true,
        hintText: "Search an issue",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.searchQuery.value = "";
                    _searchController.clear();
                  },
                )
              : const SizedBox(),
        ),
        onChanged: (v) => controller.searchQuery.value = v,
      ),
    );
  }
}
