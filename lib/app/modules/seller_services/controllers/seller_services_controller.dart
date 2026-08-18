import 'package:book_store_app/app/data/models/bookings/bookable_service_model.dart';
import 'package:book_store_app/app/data/models/bookings/booking_model.dart';
import 'package:book_store_app/app/data/models/bookings/bookings_dashboard_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_availability_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_package_model.dart';
import 'package:book_store_app/app/data/repositories/bookings_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum ServicesTab { dashboard, services, bookings }

class SellerServicesController extends GetxController {
  final BookingsRepository _repo = BookingsRepository();

  String storeId = '';
  final Rx<ServicesTab> tab = ServicesTab.dashboard.obs;

  // ── Dashboard ────────────────────────────────────────────────────────────
  final RxBool isLoadingDashboard = true.obs;
  final Rx<BookingsDashboardModel> dashboard = Rx<BookingsDashboardModel>(BookingsDashboardModel.empty);

  // ── Services ─────────────────────────────────────────────────────────────
  final RxBool isLoadingServices = false.obs;
  final RxBool isSavingService = false.obs;
  final RxList<BookableServiceModel> services = <BookableServiceModel>[].obs;
  bool _servicesLoaded = false;

  // ── Availability (scoped to whichever service is currently being edited) ─
  final RxBool isLoadingAvailability = false.obs;
  final RxBool isSavingAvailability = false.obs;
  final Rx<ServiceAvailabilityModel> availability = Rx<ServiceAvailabilityModel>(ServiceAvailabilityModel.empty);

  // ── Packages (scoped to whichever service is currently being managed) ────
  final RxBool isLoadingPackages = false.obs;
  final RxBool isSavingPackage = false.obs;
  final RxList<ServicePackageModel> packages = <ServicePackageModel>[].obs;

  // ── Bookings ─────────────────────────────────────────────────────────────
  final RxBool isLoadingBookings = false.obs;
  final RxBool isUpdatingBooking = false.obs;
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxInt bookingsPage = 1.obs;
  final RxInt bookingsTotalPages = 1.obs;
  final RxInt bookingsTotal = 0.obs;
  final Rxn<String> bookingStatusFilter = Rxn<String>();
  final Rxn<DateTime> bookingDateFilter = Rxn<DateTime>();
  final Rxn<String> bookingServiceFilter = Rxn<String>();
  bool _bookingsLoaded = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerServicesController: no storeId in prefs');
      isLoadingDashboard.value = false;
      return;
    }
    await loadDashboard();
  }

  void changeTab(ServicesTab value) {
    tab.value = value;
    switch (value) {
      case ServicesTab.dashboard:
        loadDashboard();
        break;
      case ServicesTab.services:
        if (!_servicesLoaded) loadServices();
        break;
      case ServicesTab.bookings:
        if (!_bookingsLoaded) loadBookings();
        break;
    }
  }

  @override
  Future<void> refresh() async {
    switch (tab.value) {
      case ServicesTab.dashboard:
        await loadDashboard();
        break;
      case ServicesTab.services:
        await loadServices();
        break;
      case ServicesTab.bookings:
        await _refreshBookings();
        break;
    }
  }

  // ── Dashboard ────────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    if (storeId.isEmpty) return;
    isLoadingDashboard.value = true;
    dashboard.value = await _repo.getSellerDashboard(storeId);
    isLoadingDashboard.value = false;
  }

  // ── Services ─────────────────────────────────────────────────────────────

  Future<void> loadServices() async {
    if (storeId.isEmpty) return;
    isLoadingServices.value = true;
    final result = await _repo.listSellerServices(storeId);
    services.assignAll(result);
    _servicesLoaded = true;
    isLoadingServices.value = false;
  }

  Future<BookableServiceModel?> createService(Map<String, dynamic> body) async {
    isSavingService.value = true;
    final created = await _repo.createService(storeId, body);
    isSavingService.value = false;
    if (created != null) {
      services.insert(0, created);
    }
    return created;
  }

  Future<bool> updateService(BookableServiceModel existing, Map<String, dynamic> body) async {
    isSavingService.value = true;
    final updated = await _repo.updateService(storeId, existing.id, body);
    isSavingService.value = false;
    if (updated != null) {
      final index = services.indexWhere((s) => s.id == existing.id);
      if (index != -1) services[index] = updated;
      return true;
    }
    return false;
  }

  Future<bool> archiveService(BookableServiceModel service) async {
    final ok = await _repo.archiveService(storeId, service.id);
    if (ok) await loadServices();
    return ok;
  }

  // ── Availability ─────────────────────────────────────────────────────────

  Future<void> loadAvailability(String serviceId) async {
    isLoadingAvailability.value = true;
    availability.value = await _repo.getAvailability(storeId, serviceId);
    isLoadingAvailability.value = false;
  }

  Future<bool> saveAvailability(String serviceId, List<WeeklyRuleModel> weeklyRules) async {
    isSavingAvailability.value = true;
    final ok = await _repo.setAvailability(storeId, serviceId, {
      'weeklyRules': weeklyRules.map((r) => r.toJson()).toList(),
    });
    isSavingAvailability.value = false;
    if (ok) {
      availability.value = ServiceAvailabilityModel(weeklyRules: weeklyRules, exceptions: availability.value.exceptions);
      // Refreshes each service's `hasAvailability` flag so the "not bookable
      // yet" badge disappears immediately instead of waiting for a manual pull.
      await loadServices();
    }
    return ok;
  }

  // ── Packages ─────────────────────────────────────────────────────────────

  Future<void> loadPackages(String serviceId) async {
    isLoadingPackages.value = true;
    packages.assignAll(await _repo.listPackages(storeId, serviceId));
    isLoadingPackages.value = false;
  }

  Future<bool> createPackage(String serviceId, Map<String, dynamic> body) async {
    isSavingPackage.value = true;
    final created = await _repo.createPackage(storeId, serviceId, body);
    isSavingPackage.value = false;
    if (created != null) {
      packages.insert(0, created);
      return true;
    }
    return false;
  }

  Future<bool> updatePackage(String serviceId, ServicePackageModel existing, Map<String, dynamic> body) async {
    isSavingPackage.value = true;
    final updated = await _repo.updatePackage(storeId, serviceId, existing.id, body);
    isSavingPackage.value = false;
    if (updated != null) {
      final index = packages.indexWhere((p) => p.id == existing.id);
      if (index != -1) packages[index] = updated;
      return true;
    }
    return false;
  }

  Future<bool> archivePackage(String serviceId, ServicePackageModel package) async {
    final ok = await _repo.archivePackage(storeId, serviceId, package.id);
    if (ok) await loadPackages(serviceId);
    return ok;
  }

  // ── Bookings ─────────────────────────────────────────────────────────────

  Future<void> loadBookings({String? status, DateTime? date, String? serviceId, int page = 1}) async {
    if (storeId.isEmpty) return;
    isLoadingBookings.value = true;
    bookingStatusFilter.value = status;
    bookingDateFilter.value = date;
    bookingServiceFilter.value = serviceId;
    final result = await _repo.listSellerBookings(
      storeId,
      page: page,
      status: status,
      serviceId: serviceId,
      date: date != null ? DateFormat('yyyy-MM-dd').format(date) : null,
    );
    bookings.assignAll(result.bookings);
    bookingsPage.value = page;
    bookingsTotalPages.value = result.pages;
    bookingsTotal.value = result.total;
    _bookingsLoaded = true;
    isLoadingBookings.value = false;
  }

  Future<void> _refreshBookings() => loadBookings(
        status: bookingStatusFilter.value,
        date: bookingDateFilter.value,
        serviceId: bookingServiceFilter.value,
        page: bookingsPage.value,
      );

  Future<bool> confirmBooking(String id) async {
    isUpdatingBooking.value = true;
    final ok = await _repo.confirmBooking(storeId, id);
    isUpdatingBooking.value = false;
    if (ok) await _refreshBookings();
    return ok;
  }

  Future<bool> completeBooking(String id) async {
    isUpdatingBooking.value = true;
    final ok = await _repo.completeBooking(storeId, id);
    isUpdatingBooking.value = false;
    if (ok) await _refreshBookings();
    return ok;
  }

  Future<bool> cancelBooking(String id, {String? reason}) async {
    isUpdatingBooking.value = true;
    final ok = await _repo.sellerCancelBooking(storeId, id, reason: reason);
    isUpdatingBooking.value = false;
    if (ok) await _refreshBookings();
    return ok;
  }

  Future<bool> rescheduleBooking(String id, {required String date, required String startTime}) async {
    isUpdatingBooking.value = true;
    final ok = await _repo.sellerRescheduleBooking(storeId, id, date: date, startTime: startTime);
    isUpdatingBooking.value = false;
    if (ok) await _refreshBookings();
    return ok;
  }

  Future<bool> setMeetingLink(String id, String meetingLink) async {
    isUpdatingBooking.value = true;
    final ok = await _repo.setMeetingLink(storeId, id, meetingLink);
    isUpdatingBooking.value = false;
    if (ok) await _refreshBookings();
    return ok;
  }
}
