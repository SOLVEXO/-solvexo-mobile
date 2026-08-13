import 'package:book_store_app/app/components/app_search_field.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/map_picker/controllers/mappicker_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatelessWidget {
  MapPickerScreen({super.key});

  final controller = Get.put(MapPickerController());

  static const double _pinSize = 46;
  static const double _searchBarHeight = 50;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + AppDimen.bottomPadding;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentPosition.value,
                zoom: 16,
              ),
              onMapCreated: controller.onMapCreated,
              onCameraMove: controller.onCameraMove,
              onCameraIdle: controller.onCameraIdle,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // Center marker — shifted up by half its height so the pin's tip
          // (not its visual centroid) points at the map's actual center,
          // i.e. the coordinate that gets reverse-geocoded.
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -_pinSize / 2),
                child: Icon(
                  Icons.location_pin,
                  color: AppColors.red,
                  size: _pinSize,
                ),
              ),
            ),
          ),

          // Back button + search bar
          Positioned(
            top: topInset,
            left: 20,
            right: 20,
            child: SizedBox(
              height: _searchBarHeight,
              child: Row(
                spacing: AppDimen.bottomPadding,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGrey, width: 0.3),
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                    ),
                    child: CustomIconButton(
                      onPressed: () => Get.back(),
                      assetName: AppIcons.chevronLeft,
                      size: 35,
                    ),
                  ),
                  Expanded(
                    child: AppSearchField(
                      controller: controller.searchController,
                      staticHint: 'Search location...',
                      onChanged: controller.searchLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search results / searching indicator
          Positioned(
            top: topInset + _searchBarHeight + 12,
            left: 20,
            right: 20,
            child: Obx(() {
              if (controller.isSearching.value) {
                return _panel(
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        CustomText(text: 'Searching...'),
                      ],
                    ),
                  ),
                );
              }
              if (controller.searchResults.isEmpty) return const SizedBox();
              return _panel(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final location = controller.searchResults[index];
                      return ListTile(
                        leading: SvgIcon(
                          size: 26,
                          assetName: AppIcons.locationIcon,
                          color: AppColors.red,
                        ),
                        title: CustomText(
                          text: location['name'] ?? '',
                          fontWeight: FontWeight.w500,
                        ),
                        subtitle: CustomText(
                          text: location['address'] ?? '',
                          fontSize: 12,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => controller.selectSearchResult(location),
                      );
                    },
                  ),
                ),
              );
            }),
          ),

          // My-location button — hidden while the search panel covers this
          // part of the map so it can't sit underneath an unreachable tap
          // target.
          Positioned(
            top: topInset + _searchBarHeight + 20,
            right: 20,
            child: Obx(() {
              final hidden =
                  controller.isSearching.value ||
                  controller.searchResults.isNotEmpty;
              if (hidden) return const SizedBox();
              return FloatingActionButton(
                heroTag: 'map_picker_my_location',
                backgroundColor: AppColors.white,
                onPressed: controller.getCurrentLocation,
                child: Icon(
                  Icons.my_location,
                  color: AppColors.primaryColor,
                  size: 26,
                ),
              );
            }),
          ),

          // Permanently-denied permission banner
          Positioned(
            top: topInset + _searchBarHeight + 20,
            left: 20,
            right: 90,
            child: Obx(
              () => controller.isPermissionPermanentlyDenied.value
                  ? _panel(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomText(
                                text:
                                    'Location permission is off. Enable it to use your current location.',
                                fontSize: AppFontSize.tiny,
                              ),
                            ),
                            TextButton(
                              onPressed: controller.openLocationSettings,
                              child: const CustomText(text: 'Settings'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),

          // Address display card
          Positioned(
            bottom: bottomInset + 90,
            left: 20,
            right: 20,
            child: Obx(
              () => _panel(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: controller.isLoading.value
                      ? Row(
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            CustomText(text: 'Loading address...'),
                          ],
                        )
                      : CustomText(
                          text: controller.selectedAddress.value.isEmpty
                              ? 'Move the map to select a location'
                              : controller.selectedAddress.value,
                          fontSize: AppFontSize.small,
                        ),
                ),
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: bottomInset + 30,
            left: 20,
            right: 20,
            child: Obx(
              () => AppButton(
                label: 'Confirm Location',
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (controller.confirmedAddress != null) {
                          Get.back(result: controller.confirmedAddress);
                        } else {
                          CustomAppSnackbar.error('Please select a location');
                        }
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Card(
      color: AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: child,
    );
  }
}
