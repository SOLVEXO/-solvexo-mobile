import 'dart:io';

import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/store_verification_model.dart';
import 'package:book_store_app/app/data/repositories/store_verification_repository.dart';
import 'package:book_store_app/app/data/repositories/upload_repository.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Static option lists (mirrors backend enums for instant client feedback —
// the backend's own `documents[].required` flags in the GET response stay
// the authority for what documents are actually required) ──────────────────

const kBusinessTypes = ['individual', 'company', 'partnership'];
const kIdDocumentTypes = ['cnic', 'passport', 'national_id'];

extension VerificationLabels on String {
  String get businessTypeLabel {
    switch (this) {
      case 'individual':
        return 'Individual';
      case 'company':
        return 'Company';
      case 'partnership':
        return 'Partnership';
      default:
        return this;
    }
  }

  String get idDocumentTypeLabel {
    switch (this) {
      case 'cnic':
        return 'CNIC';
      case 'passport':
        return 'Passport';
      case 'national_id':
        return 'National ID';
      default:
        return this;
    }
  }

  String get documentTypeLabel {
    switch (this) {
      case 'business_registration':
        return 'Business Registration';
      case 'tax_registration':
        return 'Tax Registration';
      case 'address_proof':
        return 'Address Proof';
      case 'owner_id':
        return 'Owner ID';
      case 'authorization_proof':
        return 'Authorization Proof';
      default:
        return this;
    }
  }
}

class StoreVerificationController extends GetxController {
  StoreVerificationController({
    StoreVerificationRepository? repository,
    UploadRepository? uploadRepository,
  }) : _repo = repository ?? StoreVerificationRepository(),
       _uploadRepo = uploadRepository ?? UploadRepository();

  final StoreVerificationRepository _repo;
  final UploadRepository _uploadRepo;

  String storeId = '';

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isSubmitting = false.obs;

  // ── Editable fields ──────────────────────────────────────────────────────
  final RxString businessType = ''.obs;
  final RxString idDocumentType = ''.obs;
  late final TextEditingController legalBusinessNameCtrl;
  late final TextEditingController registrationNumberCtrl;
  late final TextEditingController taxIdCtrl;
  late final TextEditingController businessAddressCtrl;
  late final TextEditingController contactNameCtrl;
  late final TextEditingController contactDesignationCtrl;
  late final TextEditingController contactEmailCtrl;
  late final TextEditingController contactPhoneCtrl;

  // A cheap Rx counter so `Obx` blocks that depend on plain
  // TextEditingControllers (not Rx themselves) know to rebuild.
  final RxInt formRevision = 0.obs;
  void _bumpRevision() => formRevision.value++;

  // ── Server / read-only state ─────────────────────────────────────────────
  final RxList<VerificationDocumentModel> documents =
      <VerificationDocumentModel>[].obs;
  final RxList<VerificationHistoryEntryModel> history =
      <VerificationHistoryEntryModel>[].obs;
  /// The KYC review's own state — independent of [storeStatus] (marketplace
  /// listing lifecycle). See `store.schema.ts` (`VerificationStatus`).
  final RxString verificationStatus = ''.obs;
  final RxString storeStatus = ''.obs;
  final RxString rejectionReason = ''.obs;

  /// Document type currently mid-upload (pick → private-upload → attach) —
  /// used to show a per-row spinner instead of locking the whole screen.
  final RxSet<String> uploadingTypes = <String>{}.obs;

  // ── Computed ─────────────────────────────────────────────────────────────

  /// Mirrors the backend's own edit lock (`StoreService.updateVerification`/
  /// `submitVerification`): only `not_started`/`rejected` verification
  /// states may still edit — a submitted (`pending`/`under_review`) or
  /// already-`verified` store is locked, even while the store's marketplace
  /// `status` is still `pending`/`rejected`.
  bool get isEditable =>
      verificationStatus.value == 'not_started' ||
      verificationStatus.value == 'rejected';

  /// `determineVerificationLevel` mirrored client-side for instant feedback
  /// as the seller picks a business type — the backend independently
  /// recomputes this from the persisted value on every write, so this is
  /// UX only, never the security boundary.
  bool get isBusinessLevel =>
      businessType.value == 'company' || businessType.value == 'partnership';

  List<VerificationDocumentModel> get requiredDocs =>
      documents.where((d) => d.required).toList();

  List<VerificationDocumentModel> get optionalDocs =>
      documents.where((d) => !d.required).toList();

  bool get hasAllRequiredDocuments =>
      requiredDocs.every((d) => d.isUploaded);

  bool get canSubmit =>
      isEditable &&
      legalBusinessNameCtrl.text.trim().isNotEmpty &&
      businessAddressCtrl.text.trim().isNotEmpty &&
      idDocumentType.value.isNotEmpty &&
      contactNameCtrl.text.trim().isNotEmpty &&
      contactEmailCtrl.text.trim().isNotEmpty &&
      contactPhoneCtrl.text.trim().isNotEmpty &&
      (!isBusinessLevel ||
          (registrationNumberCtrl.text.trim().isNotEmpty &&
              taxIdCtrl.text.trim().isNotEmpty)) &&
      hasAllRequiredDocuments;

  /// Human-readable reason the submit button is disabled — shown under it,
  /// mirroring the onboarding flow's `primaryButtonLabel` pattern.
  String get submitBlockedReason {
    if (!isEditable) {
      switch (verificationStatus.value) {
        case 'pending':
          return 'Submitted — awaiting review';
        case 'under_review':
          return 'Locked while under review';
        case 'verified':
          return 'Already verified';
        default:
          return 'Locked';
      }
    }
    if (legalBusinessNameCtrl.text.trim().isEmpty ||
        businessAddressCtrl.text.trim().isEmpty) {
      return 'Complete the business information section';
    }
    if (idDocumentType.value.isEmpty) return 'Select an ID document type';
    if (isBusinessLevel &&
        (registrationNumberCtrl.text.trim().isEmpty ||
            taxIdCtrl.text.trim().isEmpty)) {
      return 'Registration number and tax ID are required for a company/partnership';
    }
    if (contactNameCtrl.text.trim().isEmpty ||
        contactEmailCtrl.text.trim().isEmpty ||
        contactPhoneCtrl.text.trim().isEmpty) {
      return 'Complete the authorized contact section';
    }
    if (!hasAllRequiredDocuments) return 'Upload all required documents';
    return 'Ready to submit';
  }

  VerificationDocumentModel? documentFor(String type) =>
      documents.firstWhereOrNull((d) => d.type == type);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    legalBusinessNameCtrl = TextEditingController();
    registrationNumberCtrl = TextEditingController();
    taxIdCtrl = TextEditingController();
    businessAddressCtrl = TextEditingController();
    contactNameCtrl = TextEditingController();
    contactDesignationCtrl = TextEditingController();
    contactEmailCtrl = TextEditingController();
    contactPhoneCtrl = TextEditingController();

    for (final ctrl in [
      legalBusinessNameCtrl,
      businessAddressCtrl,
      contactNameCtrl,
      contactEmailCtrl,
      contactPhoneCtrl,
    ]) {
      ctrl.addListener(_bumpRevision);
    }

    _load();
  }

  @override
  void onClose() {
    legalBusinessNameCtrl.dispose();
    registrationNumberCtrl.dispose();
    taxIdCtrl.dispose();
    businessAddressCtrl.dispose();
    contactNameCtrl.dispose();
    contactDesignationCtrl.dispose();
    contactEmailCtrl.dispose();
    contactPhoneCtrl.dispose();
    super.onClose();
  }

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    isLoading.value = true;
    // Prefer the storeId passed as a route argument (e.g. from
    // StoreVerificationCard's CTA); fall back to the active seller store
    // (AppPreferences.getStoreId()) same as other seller screens.
    final argId = Get.arguments is String ? Get.arguments as String : null;
    final id = (argId != null && argId.isNotEmpty)
        ? argId
        : await AppPreferences.getStoreId();
    if (id == null || id.isEmpty) {
      isLoading.value = false;
      return;
    }
    storeId = id;
    final result = await _repo.getVerification(id);
    if (result != null) _applyModel(result);
    isLoading.value = false;
  }

  Future<void> refreshData() => _load();

  void _applyModel(StoreVerificationModel m) {
    businessType.value = m.businessType ?? '';
    idDocumentType.value = m.idDocumentType ?? '';
    legalBusinessNameCtrl.text = m.legalBusinessName ?? '';
    registrationNumberCtrl.text = m.registrationNumber ?? '';
    taxIdCtrl.text = m.taxId ?? '';
    businessAddressCtrl.text = m.businessAddress ?? '';
    contactNameCtrl.text = m.authorizedContact.name ?? '';
    contactDesignationCtrl.text = m.authorizedContact.designation ?? '';
    contactEmailCtrl.text = m.authorizedContact.email ?? '';
    contactPhoneCtrl.text = m.authorizedContact.phone ?? '';
    documents.assignAll(m.documents);
    history.assignAll(m.history);
    verificationStatus.value = m.verificationStatus;
    storeStatus.value = m.storeStatus;
    rejectionReason.value = m.rejectionReason ?? '';
    _bumpRevision();
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

  void pickBusinessType() {
    if (!isEditable) return;
    Get.bottomSheet(
      _SimplePickerSheet(
        title: 'Business Type',
        items: kBusinessTypes,
        labelOf: (v) => v.businessTypeLabel,
        selected: businessType.value,
        onSelect: (v) => businessType.value = v,
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void pickIdDocumentType() {
    if (!isEditable) return;
    Get.bottomSheet(
      _SimplePickerSheet(
        title: 'ID Document Type',
        items: kIdDocumentTypes,
        labelOf: (v) => v.idDocumentTypeLabel,
        selected: idDocumentType.value,
        onSelect: (v) => idDocumentType.value = v,
      ),
      backgroundColor: Colors.transparent,
    );
  }

  // ── Save (draft) ─────────────────────────────────────────────────────────

  Future<void> saveDraft() async {
    if (storeId.isEmpty || isSaving.value || !isEditable) return;
    isSaving.value = true;

    final body = <String, dynamic>{
      if (businessType.value.isNotEmpty) 'businessType': businessType.value,
      'legalBusinessName': legalBusinessNameCtrl.text.trim(),
      'registrationNumber': registrationNumberCtrl.text.trim(),
      'taxId': taxIdCtrl.text.trim(),
      'businessAddress': businessAddressCtrl.text.trim(),
      if (idDocumentType.value.isNotEmpty)
        'idDocumentType': idDocumentType.value,
      'authorizedContact': {
        'name': contactNameCtrl.text.trim(),
        'designation': contactDesignationCtrl.text.trim(),
        'email': contactEmailCtrl.text.trim(),
        'phone': contactPhoneCtrl.text.trim(),
      },
    };

    final updated = await _repo.updateVerification(storeId, body);
    isSaving.value = false;
    if (updated == null) return;

    _applyModel(updated);
    ToastUtil.showToast('Verification details saved.');
  }

  // ── Documents ────────────────────────────────────────────────────────────

  Future<void> pickAndUploadDocument(String type) async {
    if (!isEditable || uploadingTypes.contains(type)) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    uploadingTypes.add(type);

    final data = await _uploadRepo.uploadPrivateFile(
      File(path),
      purpose: 'kyc_document',
    );

    if (data == null) {
      uploadingTypes.remove(type);
      ToastUtil.showToast('Upload failed. Please try again.');
      return;
    }

    final publicId = data['publicId'] as String? ?? '';
    final resourceType = data['resourceType'] as String? ?? '';
    final fileName = data['fileName'] as String? ?? result.files.first.name;

    final ok = await _repo.attachDocument(
      storeId,
      type: type,
      publicId: publicId,
      resourceType: resourceType,
      fileName: fileName,
    );

    uploadingTypes.remove(type);

    if (!ok) return;

    // Preserve the `required` flag the backend's checklist already assigned
    // this type (present even before upload — see `documentFor`); only the
    // state/fileName/uploadedAt actually changed by this upload.
    final wasRequired = documentFor(type)?.required ?? true;
    documents.removeWhere((d) => d.type == type);
    documents.add(
      VerificationDocumentModel(
        type: type,
        required: wasRequired,
        state: 'uploaded',
        fileName: fileName,
        uploadedAt: DateTime.now(),
      ),
    );
    ToastUtil.showToast('Document uploaded.');
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (storeId.isEmpty || isSubmitting.value || !canSubmit) return;
    isSubmitting.value = true;
    final ok = await _repo.submitVerification(storeId);
    isSubmitting.value = false;
    if (!ok) return;
    ToastUtil.showToast('Submitted for review.');
    await _load();
  }
}

// ── Reusable picker bottom sheet ────────────────────────────────────────────

class _SimplePickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String Function(String) labelOf;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SimplePickerSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGrey2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: CustomText(
              text: title,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey2),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 20,
                color: AppColors.lightGrey2,
              ),
              itemBuilder: (_, i) {
                final isSelected = items[i] == selected;
                return ListTile(
                  title: CustomText(
                    text: labelOf(items[i]),
                    fontSize: 15,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.black,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primaryColor,
                          size: 18,
                        )
                      : null,
                  onTap: () {
                    onSelect(items[i]);
                    Get.back();
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
