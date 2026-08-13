import 'package:geocoding/geocoding.dart';

/// Structured result handed back by [MapPickerScreen] via `Get.back(result: ...)`.
///
/// Carries both a human-readable [formattedAddress] (for screens that only
/// display a location, e.g. the home "Delivery to" banner) and the individual
/// fields a proper address form needs — so picking a point on the map can
/// autofill every field of an [AddressModel] instead of dumping one string
/// into a single text box.
class PickedAddress {
  final String formattedAddress;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;

  /// ISO-3166 alpha-2 country code (e.g. 'US', 'PK') — matches
  /// `AddressModel.country`'s expected format.
  final String? countryCode;
  final double latitude;
  final double longitude;

  const PickedAddress({
    required this.formattedAddress,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  /// Builds a [PickedAddress] from a reverse/forward-geocoded [Placemark].
  factory PickedAddress.fromPlacemark(
    Placemark place, {
    required double latitude,
    required double longitude,
  }) {
    final streetLine =
        [
          place.subThoroughfare,
          place.thoroughfare,
        ].where((p) => p != null && p.trim().isNotEmpty).join(' ').trim();

    final addressLine1 = streetLine.isNotEmpty
        ? streetLine
        : (place.street?.trim().isNotEmpty == true
              ? place.street!.trim()
              : (place.name ?? '').trim());

    return PickedAddress(
      formattedAddress: _format(place),
      addressLine1: addressLine1,
      addressLine2: (place.subLocality ?? '').trim().isEmpty
          ? null
          : place.subLocality!.trim(),
      city: (place.locality?.trim().isNotEmpty == true
          ? place.locality!.trim()
          : (place.subAdministrativeArea ?? '').trim()),
      state: (place.administrativeArea ?? '').trim(),
      zipCode: (place.postalCode ?? '').trim(),
      countryCode: (place.isoCountryCode ?? '').trim().isEmpty
          ? null
          : place.isoCountryCode!.trim().toUpperCase(),
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String _format(Placemark place) {
    final parts = [
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ].where((p) => p != null && p.trim().isNotEmpty).map((p) => p!.trim());
    return parts.join(', ');
  }

  /// True when geocoding returned enough to populate a usable address form
  /// (a bare pair of coordinates with no locality/state isn't good enough).
  bool get hasUsableDetail => city.isNotEmpty || state.isNotEmpty;
}
