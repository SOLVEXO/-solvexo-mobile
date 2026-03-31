import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.currentPosition.value,
                zoom: 20,
              ),
              onMapCreated: controller.onMapCreated,
              onCameraMove: controller.onCameraMove,
              onCameraIdle: controller.onCameraIdle,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // Center marker
          Center(
            child: Icon(Icons.location_pin, color: AppColors.red, size: 50),
          ),

          // Search bar
          Positioned(
            top: 80,
            left: 20,
            right: 20,
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
                    onPressed: () {
                      Get.back();
                    },
                    assetName: AppIcons.chevronLeft,
                    size: 35,
                  ),
                ),
                Expanded(
                  child: CustomTextField(
                    isborder: true,
                    borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                    hintText: 'Search location...',
                    prefixIcon: SvgIcon(
                      assetName: AppIcons.searchIcon,
                      color: AppColors.gray600,
                      size: 20,
                    ),
                    controller: controller.searchController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.searchLocation(value);
                      } else {
                        controller.searchResults.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Search results
          Positioned(
            top: 140,
            left: 20,
            right: 20,
            child: Obx(
              () => controller.searchResults.isNotEmpty
                  ? Card(
                      color: AppColors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimen.borderRadius,
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.searchResults.length,
                        itemBuilder: (context, index) {
                          final location = controller.searchResults[index];
                          return ListTile(
                            leading: SvgIcon(
                              size: 30,
                              assetName: AppIcons.locationIcon,
                              color: AppColors.red,
                            ),
                            title: CustomText(
                              text: location['name'] ?? '',
                              fontWeight: FontWeight.w500,
                            ),
                            subtitle: Text(
                              location['address'] ?? '',
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              controller.selectSearchResult(location);
                            },
                          );
                        },
                      ),
                    )
                  : SizedBox(),
            ),
          ),

          // Address display card
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: Obx(
              () => Card(
                color: AppColors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                            Text('Loading address...'),
                          ],
                        )
                      : CustomText(
                          text: controller.selectedAddress.value.isEmpty
                              ? 'Move map to select location'
                              : controller.selectedAddress.value,
                          fontSize: AppFontSize.small,
                        ),
                ),
              ),
            ),
          ),

          // My location button
          Positioned(
            top: 140,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: controller.getCurrentLocation,
              child: Icon(
                Icons.my_location,
                color: AppColors.primaryColor,
                size: 30,
              ),
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: AppButton(
              label: 'Confirm Location',
              onPressed: () {
                if (controller.selectedAddress.value.isNotEmpty) {
                  Get.back(result: controller.selectedAddress.value);
                } else {
                  CustomAppSnackbar.error('Please select a location');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
