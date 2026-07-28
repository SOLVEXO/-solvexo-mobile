import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/notification/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Backs the buyer "Notification Preferences" screen with the real
/// `api/notifications/preferences` document (role: 'user').
class NotificationPreferencesController extends GetxController
    with WidgetsBindingObserver {
  final NotificationsRepository _repo = NotificationsRepository();

  final RxBool isLoading = true.obs;

  // Delivery channels
  final RxBool pushEnabled = true.obs;
  final RxBool emailEnabled = true.obs;

  // Categories — match `NotificationPreference.prefs` on the backend exactly.
  final RxBool orders = true.obs;
  final RxBool messages = true.obs;
  final RxBool promotions = true.obs;
  final RxBool loyalty = true.obs;
  final RxBool subscriptions = true.obs;

  // Real OS-level permission — the `pushEnabled` toggle above only gates
  // whether the backend *attempts* to send; this reflects whether push can
  // physically reach this device at all, so the UI can warn honestly
  // instead of showing "Push: ON" in a state where nothing will arrive.
  final Rx<AuthorizationStatus?> osPermissionStatus = Rx<AuthorizationStatus?>(
    null,
  );

  bool get isOsPermissionDenied =>
      osPermissionStatus.value == AuthorizationStatus.denied ||
      osPermissionStatus.value == AuthorizationStatus.notDetermined;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
    _checkOsPermission();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Re-checks the moment the user comes back from the system settings screen
  // (opened via [openSystemSettings]) — `openAppSettings()` itself returns
  // as soon as the settings screen launches, not when the user leaves it.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkOsPermission();
  }

  Future<void> _checkOsPermission() async {
    osPermissionStatus.value = await FcmService().getPermissionStatus();
  }

  Future<void> openSystemSettings() => FcmService().openNotificationSettings();

  Future<void> _loadPreferences() async {
    isLoading.value = true;
    final data = await _repo.getPreferences();
    if (data != null) {
      pushEnabled.value = data['pushEnabled'] as bool? ?? true;
      emailEnabled.value = data['emailEnabled'] as bool? ?? true;
      final prefs = data['prefs'] as Map<String, dynamic>? ?? const {};
      orders.value = prefs['orders'] as bool? ?? true;
      messages.value = prefs['messages'] as bool? ?? true;
      promotions.value = prefs['promotions'] as bool? ?? true;
      loyalty.value = prefs['loyalty'] as bool? ?? true;
      subscriptions.value = prefs['subscriptions'] as bool? ?? true;
    }
    isLoading.value = false;
  }

  Future<void> toggle(RxBool field, String key) async {
    final previous = field.value;
    field.value = !previous;
    final success = await _repo.updatePreferences({key: field.value});
    if (!success) field.value = previous;
  }
}
