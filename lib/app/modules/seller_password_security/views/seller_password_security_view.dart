import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/seller_password_security/controllers/seller_password_security_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPasswordSecurityView extends StatelessWidget {
  SellerPasswordSecurityView({super.key});
  final SellerPasswordSecurityController c = Get.put(SellerPasswordSecurityController());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Password & Security'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SecurityInfoCard(),
          const SizedBox(height: 16),
          _ChangePasswordCard(c: c),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: _SaveBar(c: c, bottomInset: bottomInset),
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.greenContainerInnerColor, shape: BoxShape.circle), alignment: Alignment.center, child: const Icon(Icons.security_rounded, color: AppColors.darkGreen, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CustomText(text: 'Account Secured', fontSize: AppFontSize.small2, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
          const SizedBox(height: 3),
          CustomText(text: 'Last sign-in: Today at 9:00 AM', fontSize: AppFontSize.tiny, color: AppColors.grey),
        ])),
      ]),
    );
  }
}

class _ChangePasswordCard extends StatelessWidget {
  final SellerPasswordSecurityController c;
  const _ChangePasswordCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(left: 4, bottom: 12), child: CustomText(text: 'CHANGE PASSWORD', fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.8)),
        const Divider(height: 1, color: AppColors.lightGrey2),
        const SizedBox(height: 16),
        _PwdField(label: 'Current Password', ctrl: c.currentCtrl, obs: c.currentPwd, visible: c.currentVisible),
        const SizedBox(height: 16),
        _PwdField(label: 'New Password', ctrl: c.newCtrl, obs: c.newPwd, visible: c.newVisible),
        const SizedBox(height: 8),
        Obx(() => _StrengthBar(label: c.strengthLabel, color: c.strengthColor)),
        const SizedBox(height: 16),
        _PwdField(label: 'Confirm New Password', ctrl: c.confirmCtrl, obs: c.confirmPwd, visible: c.confirmVisible),
        Obx(() {
          if (c.confirmPwd.value.isNotEmpty && c.newPwd.value != c.confirmPwd.value) {
            return const Padding(padding: EdgeInsets.only(top: 6), child: CustomText(text: 'Passwords do not match', fontSize: AppFontSize.tiny, color: AppColors.red));
          }
          return const SizedBox.shrink();
        }),
      ]),
    );
  }
}

class _PwdField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final RxString obs;
  final RxBool visible;
  const _PwdField({required this.label, required this.ctrl, required this.obs, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(text: label, fontSize: AppFontSize.verySmall, fontWeight: FontWeight.w600, color: AppColors.black2),
      const SizedBox(height: 6),
      Obx(() => CustomTextField(
        controller: ctrl,
        onChanged: (v) => obs.value = v,
        hintText: '••••••••',
        isborder: true,
        fillColor: AppColors.textfldFillColor,
        obscureText: !visible.value,
        suffixIcon: GestureDetector(
          onTap: () => visible.toggle(),
          child: Icon(visible.value ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20, color: AppColors.grey),
        ),
      )),
    ]);
  }
}

class _StrengthBar extends StatelessWidget {
  final String? label;
  final Color color;
  const _StrengthBar({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox.shrink();
    return Row(children: [
      Expanded(child: LinearProgressIndicator(
        value: label == 'Weak' ? 0.25 : label == 'Fair' ? 0.5 : label == 'Good' ? 0.75 : 1.0,
        color: color, backgroundColor: AppColors.lightGrey2, minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      )),
      const SizedBox(width: 10),
      CustomText(text: label!, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w600, color: color),
    ]);
  }
}

class _SaveBar extends StatelessWidget {
  final SellerPasswordSecurityController c;
  final double bottomInset;
  const _SaveBar({required this.c, required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 12, AppDimen.allPadding, 12 + bottomInset),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, -3))]),
      child: GestureDetector(
        onTap: c.canSave && !c.isSaving.value ? c.save : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(color: c.canSave ? AppColors.primaryColor : AppColors.primaryColor.withOpacity(0.38), borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius)),
          alignment: Alignment.center,
          child: c.isSaving.value
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white))
              : const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_reset_rounded, color: AppColors.white, size: 18),
                  SizedBox(width: 8),
                  CustomText(text: 'Change Password', fontSize: AppFontSize.small2, fontWeight: FontWeight.w600, color: AppColors.white),
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
