enum NotificationType { order, message, promo, system }

/// Maps `solvexo-api`'s notification `type` strings (see
/// `src/notifications/notification.types.ts`) onto the app's coarser filter
/// categories used by the inbox tabs.
NotificationType _mapBackendType(String? backendType) {
  switch (backendType) {
    case 'order_placed':
    case 'order_shipped':
    case 'order_delivered':
    case 'order_cancelled':
    case 'payment_success':
    case 'payment_failed':
    case 'low_stock':
      return NotificationType.order;
    case 'new_message':
      return NotificationType.message;
    case 'new_follower':
      return NotificationType.promo;
    default:
      return NotificationType.system;
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id']).toString(),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: _mapBackendType(json['type'] as String?),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      data: (json['data'] as Map?)?.cast<String, dynamic>(),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        data: data,
      );

  String get filterKey => type.name;
}
