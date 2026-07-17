/// One line of the "used this month by tool" breakdown.
class AiToolUsageModel {
  final String tool;
  final int credits;
  final int generations;

  const AiToolUsageModel({required this.tool, required this.credits, required this.generations});

  factory AiToolUsageModel.fromJson(Map<String, dynamic> json) => AiToolUsageModel(
        tool: (json['tool'] ?? '').toString(),
        credits: (json['credits'] as num?)?.toInt() ?? 0,
        generations: (json['generations'] as num?)?.toInt() ?? 0,
      );
}

/// One row of the per-generation credit audit trail (`AiCreditTransaction`).
class AiCreditTransactionModel {
  final String toolUsed;
  final int creditsCharged;
  final String status; // held | captured | refunded
  final DateTime? createdAt;

  const AiCreditTransactionModel({
    required this.toolUsed,
    required this.creditsCharged,
    required this.status,
    this.createdAt,
  });

  factory AiCreditTransactionModel.fromJson(Map<String, dynamic> json) => AiCreditTransactionModel(
        toolUsed: (json['toolUsed'] ?? '').toString(),
        creditsCharged: (json['creditsCharged'] as num?)?.toInt() ?? 0,
        status: (json['status'] ?? '').toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );
}

/// `GET /api/ai-studio/:storeId/credits` response — powers the
/// "N credits remaining" UI and the per-tool cost badges on the hub.
class AiCreditsOverviewModel {
  final int balance;
  final int monthlyAllowance;
  final DateTime? lastResetAt;
  final Map<String, int> toolCosts;
  final int usedThisMonth;
  final List<AiToolUsageModel> usageByTool;
  final List<AiCreditTransactionModel> transactions;

  const AiCreditsOverviewModel({
    required this.balance,
    required this.monthlyAllowance,
    this.lastResetAt,
    required this.toolCosts,
    required this.usedThisMonth,
    required this.usageByTool,
    required this.transactions,
  });

  int costFor(String tool) => toolCosts[tool] ?? 0;

  factory AiCreditsOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawCosts = (json['toolCosts'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AiCreditsOverviewModel(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      monthlyAllowance: (json['monthlyAllowance'] as num?)?.toInt() ?? 0,
      lastResetAt: DateTime.tryParse(json['lastResetAt']?.toString() ?? ''),
      toolCosts: rawCosts.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      usedThisMonth: (json['usedThisMonth'] as num?)?.toInt() ?? 0,
      usageByTool: (json['usageByTool'] as List? ?? [])
          .map((e) => AiToolUsageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactions: (json['transactions'] as List? ?? [])
          .map((e) => AiCreditTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
