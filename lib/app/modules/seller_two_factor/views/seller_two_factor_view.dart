import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_two_factor/controllers/seller_two_factor_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerTwoFactorView extends StatelessWidget {
  SellerTwoFactorView({super.key});
  final SellerTwoFactorController c = Get.put(SellerTwoFactorController());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Two-Factor Auth'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _EnableCard(c: c),
          const SizedBox(height: 16),
          Obx(() => c.isEnabled.value
              ? _MethodCard(c: c)
              : const SizedBox.shrink()),
          const SizedBox(height: 16),
          Obx(() => c.isEnabled.value
              ? _SetupInstructions(c: c)
              : const SizedBox.shrink()),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: _SaveBar(c: c, bottomInset: bottomInset),
    );
  }
}

// ── Enable toggle card ────────────────────────────────────────────────────────

class _EnableCard extends StatelessWidget {
  final SellerTwoFactorController c;
  const _EnableCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Obx(() => Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: c.isEnabled.value ? AppColors.greenContainerInnerColor : AppColors.background,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(c.isEnabled.value ? Icons.shield_rounded : Icons.shield_outlined,
              color: c.isEnabled.value ? AppColors.darkGreen : AppColors.grey, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomText(
            text: c.isEnabled.value ? '2FA Enabled' : '2FA Disabled',
            fontSize: AppFontSize.small2, fontWeight: FontWeight.bold,
            color: c.isEnabled.value ? AppColors.darkGreen : AppColors.black,
          ),
          const SizedBox(height: 3),
          CustomText(
            text: c.isEnabled.value
                ? 'Your account has an extra layer of protection'
                : 'Enable for stronger account security',
            fontSize: AppFontSize.tiny, color: AppColors.grey,
          ),
        ])),
        Switch(
          value: c.isEnabled.value,
          onChanged: (_) => c.isEnabled.toggle(),
          activeColor: AppColors.darkGreen,
        ),
      ])),
    );
  }
}

// ── Method selection ──────────────────────────────────────────────────────────

class _MethodCard extends StatelessWidget {
  final SellerTwoFactorController c;
  const _MethodCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 8),
        child: CustomText(text: 'VERIFICATION METHOD', fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.8),
      ),
      Container(
        decoration: _cardDeco(),
        child: Obx(() {
          final currentMethod = c.selectedMethod.value; // register dependency
          return ListView.separated(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero,
          itemCount: TwoFAMethod.values.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 54, color: AppColors.lightGrey2),
          itemBuilder: (_, i) {
            final method = TwoFAMethod.values[i];
            final isSelected = currentMethod == method;
            return GestureDetector(
              onTap: () => c.selectMethod(method),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding, vertical: 14),
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                    ),
                    alignment: Alignment.center,
                    child: Text(SellerTwoFactorController.methodEmojis[method]!, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CustomText(text: SellerTwoFactorController.methodLabels[method]!, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primaryColor : AppColors.black),
                    const SizedBox(height: 2),
                    CustomText(text: SellerTwoFactorController.methodDescriptions[method]!, fontSize: AppFontSize.tiny, color: AppColors.grey),
                  ])),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primaryColor : AppColors.white,
                      border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.lightGrey2, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: isSelected ? const Icon(Icons.check_rounded, size: 12, color: AppColors.white) : null,
                  ),
                ]),
              ),
            );
          },
        ); }),
      ),
    ]);
  }
}

// ── Setup instructions ────────────────────────────────────────────────────────

class _SetupInstructions extends StatelessWidget {
  final SellerTwoFactorController c;
  const _SetupInstructions({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final method = c.selectedMethod.value;
      final steps = method == TwoFAMethod.app
          ? ['Download Google Authenticator or Microsoft Authenticator', 'Scan the QR code from your account settings', 'Enter the 6-digit code to verify']
          : method == TwoFAMethod.sms
              ? ['Make sure your phone number is up to date', 'You will receive a 6-digit code via SMS on every sign-in', 'Enter the code to complete login']
              : ['Make sure your email is up to date', 'You will receive a 6-digit code by email on every sign-in', 'Enter the code to complete login'];

      return Container(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: BoxDecoration(
          color: AppColors.languageBg,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Text('✨', style: TextStyle(fontSize: 14)),
            SizedBox(width: 6),
            CustomText(text: 'How it works', fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
          ]),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: CustomText(text: '${e.key + 1}', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              const SizedBox(width: 10),
              Expanded(child: CustomText(text: e.value, fontSize: AppFontSize.verySmall, color: AppColors.black2)),
            ]),
          )),
        ]),
      );
    });
  }
}

// ── Save bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final SellerTwoFactorController c;
  final double bottomInset;
  const _SaveBar({required this.c, required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 12, AppDimen.allPadding, 12 + bottomInset),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -3))]),
      child: GestureDetector(
        onTap: c.isSaving.value ? null : c.save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius)),
          alignment: Alignment.center,
          child: c.isSaving.value
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.save_rounded, color: AppColors.white, size: 18),
                  SizedBox(width: 8),
                  CustomText(text: 'Save Settings', fontSize: AppFontSize.small2, fontWeight: FontWeight.w600, color: AppColors.white),
                ]),
        ),
      ),
    ));
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: AppColors.white,
  borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
);
