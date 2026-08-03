import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
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
  final _notificationsRepo = NotificationsRepository();
  final _authRepository = AuthRepository();
  final RxBool isLoading = false.obs;

  // ── Profile ─────────────────────────────────────────────────────────────────
  final RxString name = 'Alex Chen'.obs;
  final RxString profileImage = ''.obs;
  final RxString email = 'alex@myshop.com'.obs;
  final RxString plan = 'Professional Plan'.obs;

  // ── Notification toggles (mirror `NotificationPreference.prefs` — 'orders'
  // gates both new-order and low-stock alerts on the backend) ────────────────
  final RxBool newOrdersNotif = true.obs;
  final RxBool customerMessagesNotif = true.obs;
  final RxBool lowStockNotif = true.obs;

  // ── Store settings ──────────────────────────────────────────────────────────
  final RxString storeName = 'My Shop'.obs;
  final RxString shippingZones = '3 zones configured'.obs;

  // Only stores that opted into `in_person_pos` (via onboarding or Edit
  // Store) get a POS Management tile — digital-only stores never see it.
  final RxBool posEnabled = true.obs;

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
          emoji: AppIcons.starOutlined,
          title: 'Plan & Billing',
          onTap: () => Get.toNamed(Routes.sellerPlatformPlan),
        ),
        SettingsTile(
          emoji: AppIcons.billsIcon,
          title: 'Finance & Payouts',
          onTap: () => Get.toNamed(Routes.sellerFinance),
        ),
        SettingsTile(
          emoji: AppIcons.truckIcon,
          title: 'Shipping',
          trailing: shippingZones.value,
          onTap: () => Get.toNamed(Routes.sellerShipping),
        ),
        if (posEnabled.value)
          SettingsTile(
            emoji: AppIcons.posIcon,
            title: 'POS Management',
            onTap: () => Get.toNamed(Routes.sellerPosManagement),
          ),
        SettingsTile(
          emoji: AppIcons.reportIcon,
          title: 'Activity Log',
          onTap: () => Get.toNamed(Routes.sellerActivityLog),
        ),
      ],
    ),
    SettingsSection(
      header: 'GROWTH',
      tiles: [
        SettingsTile(
          emoji: AppIcons.saleIcon,
          title: 'Coupons & Discounts',
          onTap: () => Get.toNamed(Routes.sellerCoupons),
        ),
        SettingsTile(
          emoji: AppIcons.coinIcon,
          title: 'Loyalty & Rewards',
          onTap: () => Get.toNamed(Routes.sellerLoyalty),
        ),
        SettingsTile(
          emoji: AppIcons.cardIcon,
          title: 'Subscription Plans',
          onTap: () => Get.toNamed(Routes.sellerSubscriptionPlans),
        ),
        SettingsTile(
          emoji: AppIcons.dashboardIcon,
          title: 'Storefront Banners',
          onTap: () => Get.toNamed(Routes.sellerStoreBanners),
        ),
        SettingsTile(
          emoji: AppIcons.anylaticsIcon,
          title: 'Promotions',
          onTap: () => Get.toNamed(Routes.sellerPromotions),
        ),
        SettingsTile(
          emoji: AppIcons.aiStudioIcon,
          title: 'AI Studio',
          onTap: () => Get.toNamed(Routes.sellerAiStudio),
        ),
        SettingsTile(
          emoji: AppIcons.searchIcon,
          title: 'SEO',
          onTap: () => Get.toNamed(Routes.sellerSeo),
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
          emoji: AppIcons.editIcon,
          title: 'Edit Profile',
          onTap: () => Get.toNamed(Routes.sellerEditProfile),
        ),
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
      header: 'SUPPORT',
      tiles: [
        SettingsTile(
          emoji: AppIcons.emailIcon,
          title: 'Contact Us',
          onTap: () => Get.toNamed(Routes.contactUsView),
        ),
      ],
    ),
    SettingsSection(
      header: 'DANGER ZONE',
      tiles: [
        SettingsTile(
          emoji: AppIcons.logoutIcon,
          title: 'Logout',
          isDanger: true,
          onTap: () => Get.offAllNamed(Routes.sellerStores),
        ),
        SettingsTile(
          emoji: AppIcons.deleteIcon,
          title: 'Delete Account',
          isDanger: true,
          onTap: deleteAccount,
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
    await _loadNotificationPrefs();
    _applyUser(Get.find<ProfileController>().user.value);
    isLoading.value = false;
  }

  Future<void> _loadNotificationPrefs() async {
    final data = await _notificationsRepo.getPreferences();
    final prefs = data?['prefs'] as Map<String, dynamic>? ?? const {};
    newOrdersNotif.value = prefs['orders'] as bool? ?? true;
    customerMessagesNotif.value = prefs['messages'] as bool? ?? true;
    lowStockNotif.value = prefs['orders'] as bool? ?? true;
  }

  Future<void> _loadStoreData() async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId == null || storeId.isEmpty) return;
    final store = await _repo.getStoreById(storeId);
    if (store != null) {
      storeName.value = store.name;
      posEnabled.value = store.enabledTools.contains('pos_register');
    }
  }

  void _applyUser(UserModel? user) {
    if (user == null) return;
    if (user.name.isNotEmpty) name.value = user.name;
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      profileImage.value = user.profileImage!;
    }
    if (user.email.isNotEmpty) email.value = user.email;
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      _applyUser(Get.find<ProfileController>().user.value);
    } catch (_) {}
    await _loadStoreData();
    await _loadNotificationPrefs();
    isLoading.value = false;
  }

  String get initials {
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'S';
  }

  void signOut() {
    showCustomDialog(
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      leftButtonName: 'Cancel',
      rightButtonName: 'Logout',
      onLeftButtonTap: () => Get.back(),
      onRightButtonTap: () async {
        await Get.find<AuthController>().logout();
      },
    );
  }

  /// Delete account — also suspends all stores owned by this seller
  /// (backend: DELETE api/users/profile, branches on req.user.role).
  void deleteAccount() {
    showCustomDialog(
      title: 'Delete Account',
      content:
          'Are you sure you want to delete your account? This will also '
          'suspend your store(s). This action cannot be undone.',
      leftButtonName: 'Cancel',
      rightButtonName: 'Delete',
      requireDeleteConfirmation: true,
      onLeftButtonTap: () => Get.back(),
      onRightButtonTap: () async {
        await _performDeleteAccount();
      },
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      final token = await AppPreferences.getAccessTokenAsync();

      if (token == null || token.isEmpty) {
        ToastUtil.showToast('Session expired');
        return;
      }

      final success = await _authRepository.deleteAccount(token: token);

      if (success) {
        ToastUtil.showToast('Account deleted successfully');
        await Get.find<AuthController>().logout();
      } else {
        ToastUtil.showToast('Failed to delete account');
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      ToastUtil.showToast('Failed to delete account');
    }
  }
}
