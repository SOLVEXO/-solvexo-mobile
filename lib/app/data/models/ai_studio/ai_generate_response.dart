/// Flat response of a synchronous tool's `POST .../generate` call —
/// `{generationId, sessionId, creditsCharged, provider?, ...toolOutputFields}`.
/// [output] is everything except the envelope fields, so each tool screen can
/// read its own known keys straight out of it.
class AiGenerateResponse {
  static const _envelopeKeys = {'generationId', 'sessionId', 'creditsCharged', 'provider'};

  final String generationId;
  final String sessionId;
  final int creditsCharged;
  final String? provider;
  final Map<String, dynamic> output;

  const AiGenerateResponse({
    required this.generationId,
    required this.sessionId,
    required this.creditsCharged,
    this.provider,
    required this.output,
  });

  factory AiGenerateResponse.fromJson(Map<String, dynamic> json) {
    return AiGenerateResponse(
      generationId: (json['generationId'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      creditsCharged: (json['creditsCharged'] as num?)?.toInt() ?? 0,
      provider: json['provider'] as String?,
      output: Map.fromEntries(json.entries.where((e) => !_envelopeKeys.contains(e.key))),
    );
  }
}

/// `POST .../image-enhancer/generate` — async kickoff response.
class AiImageJobStart {
  final String jobId;
  final String status;
  final int creditsCharged;

  const AiImageJobStart({required this.jobId, required this.status, required this.creditsCharged});

  factory AiImageJobStart.fromJson(Map<String, dynamic> json) => AiImageJobStart(
        jobId: (json['jobId'] ?? '').toString(),
        status: (json['status'] ?? 'processing').toString(),
        creditsCharged: (json['creditsCharged'] as num?)?.toInt() ?? 0,
      );
}

/// `GET .../image-enhancer/jobs/:jobId` — polled until [status] leaves
/// 'processing'.
class AiImageJobModel {
  final String jobId;
  final String status; // processing | succeeded | failed
  final int creditsCharged;
  final String? errorMessage;
  final String? enhancedImageUrl;
  final String? originalImageUrl;
  final String? note;

  const AiImageJobModel({
    required this.jobId,
    required this.status,
    required this.creditsCharged,
    this.errorMessage,
    this.enhancedImageUrl,
    this.originalImageUrl,
    this.note,
  });

  bool get isProcessing => status == 'processing';
  bool get isSucceeded => status == 'succeeded';
  bool get isFailed => status == 'failed';

  factory AiImageJobModel.fromJson(Map<String, dynamic> json) => AiImageJobModel(
        jobId: (json['jobId'] ?? '').toString(),
        status: (json['status'] ?? 'processing').toString(),
        creditsCharged: (json['creditsCharged'] as num?)?.toInt() ?? 0,
        errorMessage: json['errorMessage'] as String?,
        enhancedImageUrl: json['enhancedImageUrl'] as String?,
        originalImageUrl: json['originalImageUrl'] as String?,
        note: json['note'] as String?,
      );
}

/// Result of any generate call — success (`response`/`jobStart` set), the
/// 402 insufficient-credits case the UI must map to a "Buy Credits" prompt,
/// or a generic failure (`message`, `retryable`).
class AiGenerateOutcome<T> {
  final T? data;
  final bool insufficientCredits;
  final int? requiredCredits;
  final int? currentBalance;
  final bool retryable;
  final String? message;

  const AiGenerateOutcome({
    this.data,
    this.insufficientCredits = false,
    this.requiredCredits,
    this.currentBalance,
    this.retryable = false,
    this.message,
  });

  bool get isSuccess => data != null;
}
