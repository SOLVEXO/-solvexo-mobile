import 'dart:async';

import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/modules/map_picker/models/picked_address_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerController extends GetxController {
  GoogleMapController? mapController;
  var currentAddress = 'Fetching location...'.obs;
  var currentPosition = LatLng(24.8607, 67.0011).obs; // Default: Karachi
  var selectedAddress = ''.obs;
  var isLoading = false.obs;
  var isMapReady = false.obs;
  var isPermissionPermanentlyDenied = false.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;
  final searchController = TextEditingController();

  /// Structured placemark backing the current [selectedAddress] string —
  /// this is what actually gets handed back to the caller on confirm.
  PickedAddress? _pickedAddress;

  Timer? _searchDebounce;
  Timer? _reverseGeocodeDebounce;

  /// Monotonically-increasing request tag so a slow, stale geocoding call
  /// can't clobber the result of a newer one that finished first.
  int _reverseGeocodeRequestId = 0;
  int _searchRequestId = 0;

  bool _hasCenteredOnDeviceLocation = false;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    isMapReady.value = true;
    if (_hasCenteredOnDeviceLocation) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(currentPosition.value),
      );
    }
  }

  Future<void> searchLocation(String query) async {
    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final requestId = ++_searchRequestId;
    isSearching.value = true;

    try {
      final locations = await locationFromAddress(query);

      final results = <Map<String, dynamic>>[];
      for (final location in locations.take(5)) {
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );
          if (placemarks.isEmpty) continue;

          final place = placemarks.first;
          final picked = PickedAddress.fromPlacemark(
            place,
            latitude: location.latitude,
            longitude: location.longitude,
          );

          results.add({
            'name': place.name?.trim().isNotEmpty == true
                ? place.name!.trim()
                : (picked.city.isNotEmpty ? picked.city : 'Unknown location'),
            'address': picked.formattedAddress,
            'picked': picked,
          });
        } catch (_) {
          // Skip a single unresolvable candidate rather than failing the
          // whole search.
        }
      }

      // A newer search (or the field being cleared) started while this one
      // was in flight — drop these results instead of overwriting.
      if (requestId != _searchRequestId) return;

      searchResults.assignAll(results);
      if (results.isEmpty) {
        CustomAppSnackbar.warning('No locations found for "$query"');
      }
    } catch (e) {
      if (requestId != _searchRequestId) return;
      searchResults.clear();
      CustomAppSnackbar.error('Could not search that location');
    } finally {
      if (requestId == _searchRequestId) {
        isSearching.value = false;
      }
    }
  }

  void selectSearchResult(Map<String, dynamic> location) {
    final picked = location['picked'] as PickedAddress?;
    if (picked == null) return;

    final target = LatLng(picked.latitude, picked.longitude);
    currentPosition.value = target;
    _applyPicked(picked);

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
    );

    searchResults.clear();
    searchController.clear();
    isSearching.value = false;
  }

  void onCameraMove(CameraPosition position) {
    currentPosition.value = position.target;
  }

  void onCameraIdle() {
    _reverseGeocodeDebounce?.cancel();
    _reverseGeocodeDebounce = Timer(const Duration(milliseconds: 300), () {
      getAddressFromLatLng(currentPosition.value);
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      isPermissionPermanentlyDenied.value = false;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress.value = 'Location services are disabled';
        CustomAppSnackbar.error('Please enable location services');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress.value = 'Location permission denied';
          CustomAppSnackbar.error('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress.value = 'Location permission denied permanently';
        isPermissionPermanentlyDenied.value = true;
        CustomAppSnackbar.error(
          'Location permission permanently denied. Please enable it from settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);
      _hasCenteredOnDeviceLocation = true;

      if (mapController != null && isMapReady.value) {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentPosition.value, zoom: 16),
          ),
        );
      }

      await getAddressFromLatLng(currentPosition.value);
    } catch (e) {
      currentAddress.value = 'Unable to get location';
      CustomAppSnackbar.error('Failed to get location: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    final requestId = ++_reverseGeocodeRequestId;
    isLoading.value = true;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // The map may have moved further while this call was in flight —
      // ignore a result that's no longer for the current position.
      if (requestId != _reverseGeocodeRequestId) return;

      if (placemarks.isNotEmpty) {
        final picked = PickedAddress.fromPlacemark(
          placemarks.first,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _applyPicked(picked);
      }
    } catch (e) {
      if (requestId != _reverseGeocodeRequestId) return;
      CustomAppSnackbar.error('Failed to get address for this location');
    } finally {
      if (requestId == _reverseGeocodeRequestId) {
        isLoading.value = false;
      }
    }
  }

  void _applyPicked(PickedAddress picked) {
    _pickedAddress = picked;
    selectedAddress.value = picked.formattedAddress;
    currentAddress.value = picked.formattedAddress;
  }

  /// Result handed back to the caller on "Confirm Location". Null when
  /// nothing has been resolved yet (caller should block confirming).
  PickedAddress? get confirmedAddress => _pickedAddress;

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _reverseGeocodeDebounce?.cancel();
    searchController.dispose();
    mapController?.dispose();
    super.onClose();
  }
}
