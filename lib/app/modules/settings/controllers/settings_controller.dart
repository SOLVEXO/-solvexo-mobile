import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SettingsTile {
  final String icon;
  final String title;
  final String? trailing;
  final bool isDanger;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.icon,
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

class SettingsController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxString name = ''.obs;
  final RxString email = ''.obs;

  List<SettingsSection> get sections => [
    SettingsSection(
      header: 'ACCOUNT',
      tiles: [
        SettingsTile(
          icon: AppIcons.editIcon,
          title: 'Edit Profile',
          onTap: () => Get.toNamed(Routes.editProfileView),
        ),
        SettingsTile(
          icon: AppIcons.changePassword,
          title: 'Change Password',
          onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
        ),
        SettingsTile(
          icon: AppIcons.locationIcon,
          title: 'My Addresses',
          onTap: () => Get.toNamed(Routes.addressView),
        ),
        SettingsTile(
          icon: AppIcons.ordersIcon,
          title: 'My Orders',
          onTap: () => Get.toNamed(Routes.myOrdersView),
        ),
      ],
    ),
    SettingsSection(
      header: 'PREFERENCES',
      tiles: [
        SettingsTile(
          icon: AppIcons.notificationIcon,
          title: 'Notifications',
          onTap: () {},
        ),
        SettingsTile(
          icon: AppIcons.languageIcon,
          title: 'Language',
          trailing: 'English',
          onTap: () {},
        ),
      ],
    ),
    SettingsSection(
      header: 'SUPPORT',
      tiles: [
        SettingsTile(
          icon: AppIcons.privacy,
          title: 'Privacy Policy',
          onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
        ),
        SettingsTile(
          icon: AppIcons.aboutIcon,
          title: 'About App',
          onTap: () => Get.toNamed(Routes.ABOUT),
        ),
      ],
    ),
    SettingsSection(
      header: 'DANGER ZONE',
      tiles: [
        SettingsTile(
          icon: AppIcons.logoutIcon,
          title: 'Sign Out',
          isDanger: true,
          onTap: signOut,
        ),
        SettingsTile(
          icon: AppIcons.deleteIcon,
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
    await Future.delayed(const Duration(milliseconds: 400));
    final n = await AppPreferences.getUserName();
    final e = await AppPreferences.getUserEmail();
    name.value = n ?? '';
    email.value = e ?? '';
    isLoading.value = false;
  }

  Future<void> refreshData() => _loadProfile();

  String get initials {
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  void signOut() {
    AppPreferences.clearAccessToken();
    Get.offAllNamed(Routes.welcome);
  }
}
