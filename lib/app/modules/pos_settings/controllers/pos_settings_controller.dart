import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Models ─────────────────────────────────────────────────────────────────────

class PosSettingsTile {
  final String emoji;
  final String title;
  final String? trailing;
  final bool isDanger;
  final VoidCallback? onTap;

  const PosSettingsTile({
    required this.emoji,
    required this.title,
    this.trailing,
    this.isDanger = false,
    this.onTap,
  });
}

class PosSettingsSection {
  final String header;
  final List<PosSettingsTile> tiles;

  const PosSettingsSection({required this.header, required this.tiles});
}

// ── Controller ─────────────────────────────────────────────────────────────────

class PosSettingsController extends GetxController {
  final RxBool isLoading = false.obs;

  // Profile
  final RxString name = 'Alex Chen'.obs;
  final RxString role = 'Cashier'.obs;
  final RxString registerName = 'Register 1'.obs;
  final RxString shiftSince = '9:00 AM'.obs;

  // Register
  final RxString taxRate = '8%'.obs;
  final RxString printerStatus = 'Connected'.obs;
  final RxString cardReaderStatus = 'Square · Connected'.obs;

  // Shift
  final RxDouble todaySales = 842.50.obs;
  final RxDouble openingFloat = 200.00.obs;

  // Preferences
  final RxBool soundEffects = true.obs;
  final RxString autoLock = '5 min'.obs;
  final RxBool darkMode = false.obs;

  // ── Sections ──────────────────────────────────────────────────────────────────
  List<PosSettingsSection> get sections => [
    PosSettingsSection(
      header: 'REGISTER',
      tiles: [
        PosSettingsTile(
          emoji: AppIcons.profileIcon,
          title: 'Register Name',
          trailing: registerName.value,
        ),
        PosSettingsTile(
          emoji: AppIcons.taxesIcon,
          title: 'Tax Rate',
          trailing: taxRate.value,
        ),
        PosSettingsTile(
          emoji: AppIcons.printerIcon,
          title: 'Receipt Printer',
          trailing: printerStatus.value,
        ),
        PosSettingsTile(
          emoji: AppIcons.cardIcon,
          title: 'Card Reader',
          trailing: cardReaderStatus.value,
        ),
      ],
    ),
    PosSettingsSection(
      header: 'SHIFT',
      tiles: [
        PosSettingsTile(
          emoji: AppIcons.anylaticsIcon,
          title: "Today's Sales",
          trailing: '\$${todaySales.value.toStringAsFixed(2)}',
          onTap: () => Get.toNamed(Routes.sellerAnalytics),
        ),
        PosSettingsTile(
          emoji: AppIcons.cashIcon,
          title: 'Opening Float',
          trailing: '\$${openingFloat.value.toStringAsFixed(2)}',
        ),
        PosSettingsTile(
          emoji: AppIcons.changePassword,
          title: 'Close Shift',
          onTap: () {},
        ),
      ],
    ),
    PosSettingsSection(
      header: 'PREFERENCES',
      tiles: [
        PosSettingsTile(
          emoji: AppIcons.notificationIcon,
          title: 'Sound Effects',
          trailing: soundEffects.value ? 'On' : 'Off',
        ),
        PosSettingsTile(
          emoji: AppIcons.lockPassword,
          title: 'Auto-Lock',
          trailing: autoLock.value,
        ),
        // PosSettingsTile(
        //   emoji: '🌙',
        //   title: 'Dark Mode',
        //   trailing: darkMode.value ? 'On' : 'Off',
        // ),
      ],
    ),
  ];

  String get initials {
    final parts = name.value.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'P';
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final profileCtrl = Get.find<ProfileController>();
      final user = profileCtrl.user.value;
      if (user != null && user.name.isNotEmpty) {
        name.value = user.name;
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> refreshData() async => _load();

  void closeShiftAndLogOut() {
    // AppPreferences.clearAccessToken();
    Get.offAllNamed(Routes.sellerHome);
  }
}
