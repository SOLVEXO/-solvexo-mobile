import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerController extends GetxController {
  GoogleMapController? mapController;

  var currentPosition = LatLng(24.8607, 67.0011).obs; // Default: Karachi
  var selectedAddress = ''.obs;
  var isLoading = false.obs;
  var isMapReady = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapReady.value = true;
    // Move to current location after map is ready
    if (currentPosition.value.latitude != 24.8607) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(currentPosition.value),
      );
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(query);

      searchResults.clear();

      for (var location in locations.take(5)) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address =
              '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
                  .replaceAll(RegExp(r',\s*,'), ',')
                  .replaceAll(RegExp(r'^,\s*'), '')
                  .replaceAll(RegExp(r',\s*'), '');

          searchResults.add({
            'name': place.name ?? place.locality ?? 'Unknown',
            'address': address,
            'lat': location.latitude,
            'lng': location.longitude,
          });
        }
      }
    } catch (e) {
      print('Search error: $e');
    }
  }

  void selectSearchResult(Map<String, dynamic> location) {
    double lat = location['lat'];
    double lng = location['lng'];

    currentPosition.value = LatLng(lat, lng);
    selectedAddress.value = location['address'];

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );

    searchResults.clear();
    searchController.clear();
  }

  void onCameraMove(CameraPosition position) {
    currentPosition.value = position.target;
  }

  void onCameraIdle() {
    getAddressFromLatLng(currentPosition.value);
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Location permission denied',
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error',
          'Location permission permanently denied. Please enable from settings.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);

      if (mapController != null && isMapReady.value) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentPosition.value, zoom: 15),
          ),
        );
      }

      await getAddressFromLatLng(currentPosition.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    try {
      isLoading.value = true;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        selectedAddress.value =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'
                .replaceAll(RegExp(r',\s*,'), ',')
                .replaceAll(RegExp(r'^,\s*'), '')
                .replaceAll(RegExp(r',\s*$'), '');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get address');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}
