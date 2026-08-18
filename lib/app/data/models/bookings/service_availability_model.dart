class WeeklyRuleModel {
  final int dayOfWeek; // 0=Sun … 6=Sat
  final String startTime; // "HH:mm"
  final String endTime;

  const WeeklyRuleModel({required this.dayOfWeek, required this.startTime, required this.endTime});

  factory WeeklyRuleModel.fromJson(Map<String, dynamic> json) {
    return WeeklyRuleModel(
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() => {'dayOfWeek': dayOfWeek, 'startTime': startTime, 'endTime': endTime};
}

class AvailabilityExceptionModel {
  final DateTime date;
  final String type; // 'closed' | 'custom'
  final String? customStart;
  final String? customEnd;

  const AvailabilityExceptionModel({required this.date, required this.type, this.customStart, this.customEnd});

  factory AvailabilityExceptionModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityExceptionModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      type: json['type'] as String? ?? 'closed',
      customStart: json['customStart'] as String?,
      customEnd: json['customEnd'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'type': type,
    if (customStart != null) 'customStart': customStart,
    if (customEnd != null) 'customEnd': customEnd,
  };
}

class ServiceAvailabilityModel {
  final List<WeeklyRuleModel> weeklyRules;
  final List<AvailabilityExceptionModel> exceptions;

  const ServiceAvailabilityModel({this.weeklyRules = const [], this.exceptions = const []});

  factory ServiceAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return ServiceAvailabilityModel(
      weeklyRules: (json['weeklyRules'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(WeeklyRuleModel.fromJson)
          .toList(),
      exceptions: (json['exceptions'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(AvailabilityExceptionModel.fromJson)
          .toList(),
    );
  }

  static const empty = ServiceAvailabilityModel();
}

class ServiceSlotModel {
  final String startTime;
  final String endTime;
  final int spotsLeft;

  const ServiceSlotModel({required this.startTime, required this.endTime, required this.spotsLeft});

  bool get isAvailable => spotsLeft > 0;

  factory ServiceSlotModel.fromJson(Map<String, dynamic> json) {
    return ServiceSlotModel(
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      spotsLeft: (json['spotsLeft'] as num?)?.toInt() ?? 0,
    );
  }
}
