import 'package:flutter/foundation.dart';

/// Seller business/KYC verification details for a store.
///
/// Mirrors `GET /api/store/:storeId/verification` 1:1. Intentionally separate
/// from `StoreModel` (`common_models/store_model.dart`) — do not merge these.
class StoreVerificationModel {
  final String? businessType; // 'individual' | 'company' | 'partnership'
  final String? legalBusinessName;
  final String? registrationNumber;
  final String? taxId;
  final String? businessAddress;
  final String? idDocumentType; // 'cnic' | 'passport' | 'national_id'
  final AuthorizedContactModel authorizedContact;
  final List<VerificationDocumentModel> documents;
  final List<VerificationHistoryEntryModel> history;
  /// The KYC review's own state (`not_started|pending|under_review|verified|
  /// rejected`) — independent of [storeStatus] (marketplace listing
  /// lifecycle). Drives `StoreVerificationController.isEditable`: only
  /// `not_started`/`rejected` may still be edited.
  final String verificationStatus;
  final String storeStatus;
  final String? rejectionReason;

  const StoreVerificationModel({
    this.businessType,
    this.legalBusinessName,
    this.registrationNumber,
    this.taxId,
    this.businessAddress,
    this.idDocumentType,
    this.authorizedContact = const AuthorizedContactModel(),
    this.documents = const [],
    this.history = const [],
    this.verificationStatus = 'not_started',
    this.storeStatus = '',
    this.rejectionReason,
  });

  factory StoreVerificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return StoreVerificationModel(
        businessType: json['businessType'] as String?,
        legalBusinessName: json['legalBusinessName'] as String?,
        registrationNumber: json['registrationNumber'] as String?,
        taxId: json['taxId'] as String?,
        businessAddress: json['businessAddress'] as String?,
        idDocumentType: json['idDocumentType'] as String?,
        authorizedContact: json['authorizedContact'] is Map<String, dynamic>
            ? AuthorizedContactModel.fromJson(
                json['authorizedContact'] as Map<String, dynamic>,
              )
            : const AuthorizedContactModel(),
        documents:
            (json['documents'] as List<dynamic>?)
                ?.map(
                  (e) => VerificationDocumentModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
        history:
            (json['history'] as List<dynamic>?)
                ?.map(
                  (e) => VerificationHistoryEntryModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
        verificationStatus:
            json['verificationStatus'] as String? ?? 'not_started',
        storeStatus: json['storeStatus'] as String? ?? '',
        rejectionReason: json['rejectionReason'] as String?,
      );
    } catch (e) {
      debugPrint('❌ StoreVerificationModel.fromJson error: $e  json: $json');
      rethrow;
    }
  }
}

class AuthorizedContactModel {
  final String? name;
  final String? designation;
  final String? email;
  final String? phone;

  const AuthorizedContactModel({
    this.name,
    this.designation,
    this.email,
    this.phone,
  });

  factory AuthorizedContactModel.fromJson(Map<String, dynamic> json) =>
      AuthorizedContactModel(
        name: json['name'] as String?,
        designation: json['designation'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
      );
}

/// One entry per document TYPE the backend's checklist knows about (required
/// AND optional) — not just the ones actually uploaded. `state` tells the UI
/// what to render; `required` distinguishes the "required" vs "optional"
/// groups. See `StoreService.evaluateVerification` (backend).
class VerificationDocumentModel {
  final String type;
  final bool required;
  /// 'uploaded' | 'missing' | 'not_required'.
  final String state;
  final String fileName;
  final DateTime? uploadedAt;
  final String? viewUrl;

  bool get isUploaded => state == 'uploaded';

  const VerificationDocumentModel({
    required this.type,
    this.required = false,
    this.state = 'missing',
    this.fileName = '',
    this.uploadedAt,
    this.viewUrl,
  });

  factory VerificationDocumentModel.fromJson(Map<String, dynamic> json) =>
      VerificationDocumentModel(
        type: json['type'] as String? ?? '',
        required: json['required'] as bool? ?? false,
        state: json['state'] as String? ?? 'missing',
        fileName: json['fileName'] as String? ?? '',
        uploadedAt: json['uploadedAt'] != null
            ? DateTime.tryParse(json['uploadedAt'] as String)
            : null,
        viewUrl: json['viewUrl'] as String?,
      );
}

class VerificationHistoryEntryModel {
  final String action;
  final String? note;
  final String? actorId;
  final String? actorRole;
  final DateTime? at;

  const VerificationHistoryEntryModel({
    required this.action,
    this.note,
    this.actorId,
    this.actorRole,
    this.at,
  });

  factory VerificationHistoryEntryModel.fromJson(Map<String, dynamic> json) =>
      VerificationHistoryEntryModel(
        action: json['action'] as String? ?? '',
        note: json['note'] as String?,
        actorId: json['actorId'] as String?,
        actorRole: json['actorRole'] as String?,
        at: json['at'] != null ? DateTime.tryParse(json['at'] as String) : null,
      );
}
