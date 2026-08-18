import 'package:book_store_app/app/data/models/bookings/booking_model.dart';
import 'package:book_store_app/app/data/models/bookings/package_purchase_model.dart';
import 'package:book_store_app/app/data/repositories/bookings_repository.dart';
import 'package:get/get.dart';

class MyBookingsController extends GetxController {
  final BookingsRepository _repo = BookingsRepository();

  final RxBool isLoading = true.obs;

  /// Id of the booking an action (cancel/reschedule) is running for — empty
  /// when idle. Guards against double-taps and drives button spinners.
  final RxString actioningId = ''.obs;

  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxList<PackagePurchaseModel> packages = <PackagePurchaseModel>[].obs;

  final Rxn<String> statusFilter = Rxn<String>();
  final RxInt page = 1.obs;
  final RxInt totalPages = 1.obs;

  /// Booking currently shown in the details bottom sheet. Re-emitted after
  /// the detail fetch and after every successful action.
  final Rx<BookingModel?> selected = Rx<BookingModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    // Kick off both requests before awaiting so they run concurrently.
    final bookingsFuture = _repo.listMyBookings(status: statusFilter.value, page: page.value);
    final packagesFuture = _repo.listMyPackages();
    final result = await bookingsFuture;
    bookings.assignAll(result.bookings);
    totalPages.value = result.pages;
    packages.assignAll(await packagesFuture);
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _load();

  Future<void> setStatusFilter(String? status) async {
    if (statusFilter.value == status) return;
    statusFilter.value = status;
    page.value = 1;
    await _load();
  }

  Future<void> loadPage(int value) async {
    if (value < 1 || value > totalPages.value) return;
    page.value = value;
    await _load();
  }

  /// Selects [booking] for the details sheet and loads its full detail in
  /// the background.
  void select(BookingModel booking) {
    selected.value = booking;
    _repo.getMyBookingById(booking.id).then((detail) {
      if (detail != null && selected.value?.id == booking.id) {
        selected.value = detail;
      }
    });
  }

  Future<bool> cancelBooking(String id, {String? reason}) =>
      _runAction(id, () => _repo.cancelMyBooking(id, reason: reason));

  Future<bool> rescheduleBooking(String id, {required String date, required String startTime}) =>
      _runAction(id, () => _repo.rescheduleMyBooking(id, date: date, startTime: startTime));

  Future<bool> _runAction(String id, Future<bool> Function() action) async {
    if (actioningId.value.isNotEmpty) return false;
    actioningId.value = id;
    final ok = await action();
    if (ok) {
      await _load();
      if (selected.value?.id == id) {
        final detail = await _repo.getMyBookingById(id);
        if (detail != null) selected.value = detail;
      }
    }
    actioningId.value = '';
    return ok;
  }
}
