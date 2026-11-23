import 'package:book_store_app/app/data/models/common_models/user_model.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/seller/utils/plan_lapse.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/services/account_switch_prompt.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/custom_alert_dialog_util.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:book_store_app/app/modules/seller/utils/store_currency.dart';
import 'package:book_store_app/app/services/legal_links.dart';
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

  // ── Profile (real data only; empty = the block is hidden) ──────────────────
  final RxString name = ''.obs;
  final RxString profileImage = ''.obs;
  final RxString email = ''.obs;
  /// Platform plan name from GET /api/platform-plans/:storeId.
  final RxString plan = ''.obs;

  // ── Notification toggles (mirror `NotificationPreference.prefs` — 'orders'
  // gates both new-order and low-stock alerts on the backend) ────────────────
  final RxBool newOrdersNotif = true.obs;
  final RxBool customerMessagesNotif = true.obs;
  final RxBool lowStockNotif = true.obs;

  // ── Store settings ──────────────────────────────────────────────────────────
  final RxString storeName = ''.obs;

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
          emoji: AppIcons.dashboardIcon,
          title: 'Storefront Banners',
          onTap: () => Get.toNamed(Routes.sellerStoreBanners),
        ),
        SettingsTile(
          emoji: AppIcons.dashboardIcon,
          title: 'Store settings',
          onTap: () => Get.toNamed(Routes.sellerStoreSettings),
        ),
        SettingsTile(
          emoji: AppIcons.dashboardIcon,
          title: 'Shipping',
          onTap: () => Get.toNamed(Routes.sellerShipping),
        ),
        SettingsTile(
          emoji: AppIcons.dashboardIcon,
          title: 'Students',
          onTap: () => Get.toNamed(Routes.sellerStudents),
        ),
        SettingsTile(
          emoji: AppIcons.dashboardIcon,
          title: 'Inventory',
          onTap: () => Get.toNamed(Routes.sellerInventory),
        ),
        SettingsTile(
          emoji: AppIcons.anylaticsIcon,
          title: 'Platform sales',
          onTap: () => Get.toNamed(Routes.sellerPlatformSales),
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
        // Checklist #5: switch-to-buyer (or create-buyer-account).
        SettingsTile(
          emoji: AppIcons.shoppingBag,
          title: 'Switch to buyer account',
          onTap: AccountSwitchPrompt.toBuyer,
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
    // R7: store-compliance pages (seller panel stays English).
    SettingsSection(
      header: 'LEGAL',
      tiles: [
        SettingsTile(
          emoji: AppIcons.privacy,
          title: 'Privacy Policy',
          onTap: () => LegalLinks.open(LegalLinks.privacyPolicy),
        ),
        SettingsTile(
          emoji: AppIcons.privacy,
          title: 'Terms of Service',
          onTap: () => LegalLinks.open(LegalLinks.termsOfService),
        ),
        SettingsTile(
          emoji: AppIcons.deleteIcon,
          title: 'Delete account on the website',
          onTap: () => LegalLinks.open(LegalLinks.deleteAccount),
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
          onTap: signOut,
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
    await Future.wait([_loadStoreData(), _loadNotificationPrefs(), _loadPlan()]);
    try {
      _applyUser(Get.find<ProfileController>().user.value);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _loadPlan() async {
    final check = await PlanGate.check();
    plan.value = check.planName ?? '';
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
    await Future.wait([_loadStoreData(), _loadNotificationPrefs(), _loadPlan()]);
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
        Get.back();
        await logout();
      },
    );
  }

  /// Real sign-out (same as the buyer's): FCM sign-out, POST logout, clear
  /// tokens + session prefs, close sockets; then the Login screen on top of
  /// guest Home. The old tile only went back to the store list.
  Future<void> logout() async {
    await _authRepository.logout();
    StoreCurrency.code.value = '';
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().currentUser.value = null;
    }
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().user.value = null;
    }
    Get.offAllNamed(Routes.mainHome);
    Get.toNamed(Routes.authTabView);
    ToastUtil.showToast('Logged out successfully');
  }

  /// Delete account (DELETE /api/users/profile {confirm:'DELETE', password?}).
  /// Backend 5adba44: an account with a password must send it (400 "Enter
  /// your password to delete your account."); open orders, pending payouts
  /// or a wallet balance -> 409 with the server's message, shown as-is.
  /// Same dialog as the buyer one, English (seller panel).
  Future<void> deleteAccount() async {
    final confirmCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final busy = false.obs;
    final error = RxnString();
    await Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This permanently deletes your account and suspends your store. '
                  'Open orders, pending payouts and any wallet balance must be settled first.'),
              const SizedBox(height: 16),
              TextField(
                key: const Key('deleteConfirm'),
                controller: confirmCtrl,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Type DELETE to confirm'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('deletePassword'),
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password (if your account has one)'),
              ),
              Obx(() => error.value == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(error.value!, key: const Key('deleteError'), style: TextStyle(color: Get.theme.colorScheme.error)),
                    )),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('deleteCancel'),
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => FilledButton(
                key: const Key('deleteSubmit'),
                style: FilledButton.styleFrom(backgroundColor: Get.theme.colorScheme.error, minimumSize: const Size(64, 48)),
                onPressed: busy.value
                    ? null
                    : () async {
                        if (confirmCtrl.text.trim() != 'DELETE') {
                          error.value = 'Type DELETE to confirm';
                          return;
                        }
                        busy.value = true;
                        error.value = null;
                        final result = await _authRepository.deleteAccount(password: passwordCtrl.text);
                        busy.value = false;
                        if (result.ok) {
                          Get.back();
                          ToastUtil.showToast('Account deleted successfully');
                          await Get.find<AuthController>().logout();
                        } else {
                          error.value = result.message ?? 'Failed to delete account';
                        }
                      },
                child: const Text('Delete'),
              )),
        ],
      ),
    );
    confirmCtrl.dispose();
    passwordCtrl.dispose();
  }
}
