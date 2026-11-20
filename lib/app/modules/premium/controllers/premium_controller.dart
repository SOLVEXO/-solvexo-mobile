import 'dart:io';

import 'package:book_store_app/app/data/repositories/premium_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Edudeen Premium (B3, docs §2.5 / §5.12). Landing + plans (yearly
/// toggle), subscribe by platform bank transfer + proof, status, deals.
class PremiumController extends GetxController {
  PremiumController({PremiumRepository? repository}) : _repo = repository ?? PremiumRepository();
  final PremiumRepository _repo;

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  final RxBool signedIn = false.obs;
  final RxList<PremiumPlan> plans = <PremiumPlan>[].obs;
  final Rx<PremiumStatus?> status = Rx<PremiumStatus?>(null);
  final RxList<Map> deals = <Map>[].obs;

  final RxBool yearly = false.obs;

  /// PKR for Pakistan (docs: Premium page shows USD/PKR only).
  final RxString currency = 'PKR'.obs;
  final RxBool busy = false.obs;

  /// Bank details for an awaiting-proof payment (null = not loaded / not available).
  final Rx<Map?> bank = Rx<Map?>(null);
  final RxnString bankError = RxnString();

  final Rx<File?> proof = Rx<File?>(null);
  final reference = TextEditingController();
  final senderName = TextEditingController();

  String get interval => yearly.value ? 'yearly' : 'monthly';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    reference.dispose();
    senderName.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    try {
      signedIn.value = await AppPreferences.isLoggedIn();
      plans.assignAll(await _repo.plans());
      if (signedIn.value) {
        final s = await _repo.me();
        status.value = s;
        if (s.isPremium) deals.assignAll(await _repo.deals().catchError((_) => <Map>[]));
        final p = s.pendingPayment;
        if (p != null && (p['status'] == 'awaiting_proof' || p['status'] == 'rejected')) await loadBank();
      }
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }

  Future<void> loadBank() async {
    final r = await _repo.bankDetails();
    bank.value = r.data;
    bankError.value = r.error;
  }

  Future<void> subscribe(PremiumPlan plan) async {
    if (busy.value) return;
    busy.value = true;
    final r = await _repo.subscribe(plan.id, interval);
    busy.value = false;
    if (r.error != null) {
      ToastUtil.showToast(r.error!);
      return;
    }
    await load();
  }

  static String? validateProof(File? f) => f == null ? 'Add a photo of your transfer receipt.'.tr : null;

  Future<void> submitProof() async {
    final payment = status.value?.pendingPayment;
    final err = validateProof(proof.value);
    if (err != null) {
      ToastUtil.showToast(err);
      return;
    }
    if (payment == null || busy.value) return;
    busy.value = true;
    final r = await _repo.uploadProof('${payment['_id']}', proof.value!, reference: reference.text, senderName: senderName.text);
    busy.value = false;
    if (r.error != null) {
      ToastUtil.showToast(r.error!);
      return;
    }
    proof.value = null;
    ToastUtil.showToast("We're verifying your payment.".tr);
    await load();
  }

  Future<void> cancelOrResume() async {
    final m = status.value?.membership;
    if (m == null || busy.value) return;
    busy.value = true;
    final err = m['cancelAtPeriodEnd'] == true ? await _repo.resume() : await _repo.cancel();
    busy.value = false;
    if (err != null) ToastUtil.showToast(err);
    await load();
  }
}
