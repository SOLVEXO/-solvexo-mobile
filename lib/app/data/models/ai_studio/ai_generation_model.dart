/// A single AI Studio generation history row (`GET .../generations[/:id]`
/// and the Image Enhancer job-status shape). `output` is kept as a raw map —
/// each tool renders its own known fields via [GenerationOutputView].
class AiGenerationModel {
  final String id;
  final String sessionId;
  final String toolType;
  final String status; // processing | succeeded | failed
  final Map<String, dynamic> input;
  final Map<String, dynamic>? output;
  final String? errorMessage;
  final String? providerUsed;
  final int creditsCharged;
  final String? productId;
  final bool accepted;
  final bool appliedToProduct;
  final DateTime? createdAt;

  const AiGenerationModel({
    required this.id,
    required this.sessionId,
    required this.toolType,
    required this.status,
    required this.input,
    this.output,
    this.errorMessage,
    this.providerUsed,
    this.creditsCharged = 0,
    this.productId,
    this.accepted = false,
    this.appliedToProduct = false,
    this.createdAt,
  });

  bool get isSucceeded => status == 'succeeded';
  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';

  factory AiGenerationModel.fromJson(Map<String, dynamic> json) {
    return AiGenerationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      sessionId: (json['sessionId'] ?? '').toString(),
      toolType: (json['toolType'] ?? '').toString(),
      status: (json['status'] ?? 'processing').toString(),
      input: (json['inputPayload'] as Map?)?.cast<String, dynamic>() ?? const {},
      output: (json['outputPayload'] as Map?)?.cast<String, dynamic>(),
      errorMessage: json['errorMessage'] as String?,
      providerUsed: json['providerUsed'] as String?,
      creditsCharged: (json['creditsCharged'] as num?)?.toInt() ?? 0,
      productId: json['productId'] as String?,
      accepted: json['accepted'] as bool? ?? false,
      appliedToProduct: json['appliedToProduct'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}
