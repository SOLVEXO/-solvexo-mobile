class PayoutScheduleModel {
  final String currency; // USD | PKR
  final String frequency; // daily | weekly | biweekly | monthly | manual
  final int dayOfWeek; // 0=Sun..6=Sat
  final int dayOfMonth; // 1-28
  final double minimumAmount;
  final bool isEnabled;
  final DateTime? nextPayoutAt;
  final String? defaultPayoutMethodId;

  const PayoutScheduleModel({
    this.currency = 'USD',
    required this.frequency,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.minimumAmount,
    required this.isEnabled,
    this.nextPayoutAt,
    this.defaultPayoutMethodId,
  });

  static const empty = PayoutScheduleModel(
    frequency: 'weekly', dayOfWeek: 1, dayOfMonth: 1, minimumAmount: 50, isEnabled: true,
  );

  factory PayoutScheduleModel.fromJson(Map<String, dynamic> json) => PayoutScheduleModel(
        currency: json['currency'] as String? ?? 'USD',
        frequency: json['frequency'] as String? ?? 'weekly',
        dayOfWeek: json['dayOfWeek'] as int? ?? 1,
        dayOfMonth: json['dayOfMonth'] as int? ?? 1,
        minimumAmount: (json['minimumAmount'] as num?)?.toDouble() ?? 50,
        isEnabled: json['isEnabled'] as bool? ?? true,
        nextPayoutAt: json['nextPayoutAt'] != null ? DateTime.tryParse(json['nextPayoutAt'] as String) : null,
        defaultPayoutMethodId: json['defaultPayoutMethodId'] as String?,
      );

  static const _weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly (Every ${_weekDays[dayOfWeek.clamp(0, 6)]})';
      case 'biweekly':
        return 'Every 2 Weeks';
      case 'monthly':
        return 'Monthly (Day $dayOfMonth)';
      case 'manual':
      default:
        return 'Manual Only';
    }
  }
}
