import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
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
  final _repo = SellerRepository();
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
          emoji: AppIcons.profileIcon,
          title: 'Store Profile',
          trailing: storeName.value,
          onTap: () => Get.toNamed(Routes.sellerStoreProfile),
        ),
        SettingsTile(
          emoji: AppIcons.duePayment,
          title: 'Payment Methods',
          trailing: paymentMethods.value,
          onTap: () => Get.toNamed(Routes.sellerPaymentMethods),
        ),
        SettingsTile(
          emoji: AppIcons.truckIcon,
          title: 'Shipping',
          trailing: shippingZones.value,
          onTap: () => Get.toNamed(Routes.sellerShipping),
        ),
      ],
    ),
    SettingsSection(
      header: 'NOTIFICATIONS',
      tiles: [
        SettingsTile(
          emoji: AppIcons.notificationIcon,
          title: 'New Orders',
          trailing: newOrdersNotif.value ? 'On' : 'Off',
          onTap: () => Get.toNamed(Routes.sellerNotifications),
        ),
        SettingsTile(
          emoji: AppIcons.messageIcon,
          title: 'Customer Messages',
          trailing: customerMessagesNotif.value ? 'On' : 'Off',
          onTap: () => Get.toNamed(Routes.sellerNotifications),
        ),
        SettingsTile(
          emoji: AppIcons.alertIcon,
          title: 'Low Stock Alerts',
          trailing: lowStockNotif.value ? 'On' : 'Off',
          onTap: () => Get.toNamed(Routes.sellerNotifications),
        ),
      ],
    ),
    SettingsSection(
      header: 'ACCOUNT',
      tiles: [
        SettingsTile(
          emoji: AppIcons.privacy,
          title: 'Password & Security',
          onTap: () => Get.toNamed(Routes.sellerPasswordSecurity),
        ),
        SettingsTile(
          emoji: AppIcons.phoneIcon,
          title: 'Two-Factor Auth',
          trailing: twoFactorEnabled.value ? 'Enabled' : 'Disabled',
          onTap: () => Get.toNamed(Routes.sellerTwoFactor),
        ),
        SettingsTile(
          emoji: AppIcons.languageIcon,
          title: 'Language',
          trailing: language.value,
          onTap: () => Get.toNamed(Routes.sellerLanguage),
        ),
      ],
    ),
    SettingsSection(
      header: 'DANGER ZONE',
      tiles: [
        SettingsTile(
          emoji: AppIcons.logoutIcon,
          title: 'Sign Out',
          isDanger: true,
          onTap: signOut,
        ),
        SettingsTile(
          emoji: AppIcons.deleteIcon,
          title: 'Delete Account',
          isDanger: true,
        ),
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

    // ── User profile (reactive) ───────────────────────────────────────────
    try {
      final profileCtrl = Get.find<ProfileController>();
      _applyUser(profileCtrl.user.value);
      // Keep syncing if data hasn't arrived yet
      ever(profileCtrl.user, (UserModel? u) {
        if (u != null) _applyUser(u);
      });
    } catch (_) {}

    // ── Store data (awaited — ensures sections rebuild with correct name) ──
    await _loadStoreData();
    _applyUser(Get.find<ProfileController>().user.value);
    isLoading.value = false;
  }

  Future<void> _loadStoreData() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) return;
    final store = await _repo.getStoreById(storeId);
    if (store != null) storeName.value = store.name;
  }

  void _applyUser(UserModel? user) {
    if (user == null) return;
    if (user.name.isNotEmpty) name.value = user.name;
    if (user.email.isNotEmpty) email.value = user.email;
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      _applyUser(Get.find<ProfileController>().user.value);
    } catch (_) {}
    await _loadStoreData();
    isLoading.value = false;
  }

  String get initials {
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'S';
  }

  void signOut() {
    Get.offAllNamed(Routes.sellerStores);
  }
}
