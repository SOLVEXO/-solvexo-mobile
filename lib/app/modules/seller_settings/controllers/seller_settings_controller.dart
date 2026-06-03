import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SettingsTile {
  final String emoji;
  final String title;
  final String? trailing;
  final bool isDanger;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.emoji,
    required this.title,
    this.trailing,
    this.isDanger = false,
    this.onTap,
  });
}

class SettingsSection {
  final String header;
  final List<SettingsTile> tiles;

  const SettingsSection({required this.header, required this.tiles});
}

class SellerSettingsController extends GetxController {
  final RxBool isLoading = false.obs;

  // ── Profile ─────────────────────────────────────────────────────────────────
  final RxString name = 'Alex Chen'.obs;
  final RxString email = 'alex@myshop.com'.obs;
  final RxString plan = 'Professional Plan'.obs;

  // ── Notification toggles ────────────────────────────────────────────────────
  final RxBool newOrdersNotif = true.obs;
  final RxBool customerMessagesNotif = true.obs;
  final RxBool lowStockNotif = true.obs;

  // ── Store settings ──────────────────────────────────────────────────────────
  final RxString storeName = 'My Shop'.obs;
  final RxString paymentMethods = 'Card, Cash, PayPal'.obs;
  final RxString shippingZones = '3 zones configured'.obs;

  // ── Account settings ────────────────────────────────────────────────────────
  final RxBool twoFactorEnabled = true.obs;
  final RxString language = 'English'.obs;

  // ── Sections ─────────────────────────────────────────────────────────────────
  List<SettingsSection> get sections => [
    SettingsSection(
      header: 'STORE',
      tiles: [
        SettingsTile(
          emoji: '🏪',
          title: 'Store Profile',
          trailing: storeName.value,
        ),
        SettingsTile(
          emoji: '💳',
          title: 'Payment Methods',
          trailing: paymentMethods.value,
        ),
        SettingsTile(
          emoji: '🚚',
          title: 'Shipping',
          trailing: shippingZones.value,
        ),
      ],
    ),
    SettingsSection(
      header: 'NOTIFICATIONS',
      tiles: [
        SettingsTile(
          emoji: '🔔',
          title: 'New Orders',
          trailing: newOrdersNotif.value ? 'On' : 'Off',
        ),
        SettingsTile(
          emoji: '💬',
          title: 'Customer Messages',
          trailing: customerMessagesNotif.value ? 'On' : 'Off',
        ),
        SettingsTile(
          emoji: '⚠️',
          title: 'Low Stock Alerts',
          trailing: lowStockNotif.value ? 'On' : 'Off',
        ),
      ],
    ),
    SettingsSection(
      header: 'ACCOUNT',
      tiles: [
        const SettingsTile(emoji: '🔒', title: 'Password & Security'),
        SettingsTile(
          emoji: '📱',
          title: 'Two-Factor Auth',
          trailing: twoFactorEnabled.value ? 'Enabled' : 'Disabled',
        ),
        SettingsTile(emoji: '🌐', title: 'Language', trailing: language.value),
      ],
    ),
    SettingsSection(
      header: 'DANGER ZONE',
      tiles: [
        SettingsTile(
          emoji: '🚪',
          title: 'Sign Out',
          isDanger: true,
          onTap: signOut,
        ),
        SettingsTile(emoji: '🗑️', title: 'Delete Account', isDanger: true),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    // Sync with ProfileController if available
    try {
      final profileCtrl = Get.find<ProfileController>();
      final user = profileCtrl.user.value;
      if (user != null) {
        if (user.name.isNotEmpty) name.value = user.name;
        if (user.email.isNotEmpty) email.value = user.email;
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> refreshData() async => _loadProfile();

  String get initials {
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'S';
  }

  void signOut() {
    AppPreferences.clearAccessToken();
    Get.offAllNamed(Routes.authTabView);
  }
}
