/// The 12 categories the backend groups store activity into
/// (`src/activity-log/schemas/activity-log.schema.ts`). Kept in sync manually.
const List<String> kActivityLogCategories = [
  'products',
  'orders',
  'finance',
  'marketing',
  'customers',
  'settings',
  'security',
  'loyalty',
  'subscriptions',
  'platform_billing',
  'platform_plans',
  'seo',
];

String _humanize(String value) => value
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

String activityLogCategoryLabel(String category) {
  if (category == 'seo') return 'SEO';
  return _humanize(category);
}

class ActivityLogModel {
  final String id;
  final String storeId;
  final String? actorId;
  final String? actorName;
  final String? actorRole;
  final String category;
  final String action;
  final String? description;
  final String? targetId;
  final String? targetType;
  final String? ip;
  final bool isSecurityAlert;
  final DateTime createdAt;

  const ActivityLogModel({
    required this.id,
    required this.storeId,
    this.actorId,
    this.actorName,
    this.actorRole,
    required this.category,
    required this.action,
    this.description,
    this.targetId,
    this.targetType,
    this.ip,
    required this.isSecurityAlert,
    required this.createdAt,
  });

  String get actionLabel => _humanize(action);
  String get categoryLabel => activityLogCategoryLabel(category);

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) => ActivityLogModel(
        id: json['_id'] as String? ?? '',
        storeId: json['storeId'] as String? ?? '',
        actorId: json['actorId'] as String?,
        actorName: json['actorName'] as String?,
        actorRole: json['actorRole'] as String?,
        category: json['category'] as String? ?? '',
        action: json['action'] as String? ?? '',
        description: json['description'] as String?,
        targetId: json['targetId'] as String?,
        targetType: json['targetType'] as String?,
        ip: json['ip'] as String?,
        isSecurityAlert: json['isSecurityAlert'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class ActivityLogLastLoginModel {
  final DateTime? at;
  final String? actorName;
  final String? ip;

  const ActivityLogLastLoginModel({this.at, this.actorName, this.ip});

  factory ActivityLogLastLoginModel.fromJson(Map<String, dynamic> json) => ActivityLogLastLoginModel(
        at: json['at'] != null ? DateTime.tryParse(json['at'] as String) : null,
        actorName: json['actorName'] as String?,
        ip: json['ip'] as String?,
      );
}

class ActivityLogStatsModel {
  final int totalEvents;
  final int staffActionsToday;
  final int activeStaffToday;
  final int securityAlerts;
  final ActivityLogLastLoginModel? lastLogin;

  const ActivityLogStatsModel({
    required this.totalEvents,
    required this.staffActionsToday,
    required this.activeStaffToday,
    required this.securityAlerts,
    this.lastLogin,
  });

  factory ActivityLogStatsModel.fromJson(Map<String, dynamic> json) => ActivityLogStatsModel(
        totalEvents: json['totalEvents'] as int? ?? 0,
        staffActionsToday: json['staffActionsToday'] as int? ?? 0,
        activeStaffToday: json['activeStaffToday'] as int? ?? 0,
        securityAlerts: json['securityAlerts'] as int? ?? 0,
        lastLogin: json['lastLogin'] is Map<String, dynamic>
            ? ActivityLogLastLoginModel.fromJson(json['lastLogin'] as Map<String, dynamic>)
            : null,
      );
}
