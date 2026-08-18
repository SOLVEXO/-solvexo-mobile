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
    case 'refund_requested':
    case 'payment_success':
    case 'payment_failed':
    case 'low_stock':
      return NotificationType.order;
    case 'new_message':
      return NotificationType.message;
    case 'new_follower':
    case 'promotion_request_submitted':
    case 'promotion_approved':
    case 'promotion_rejected':
    case 'promotion_payment_succeeded':
    case 'promotion_payment_failed':
    case 'promotion_going_live':
    case 'promotion_expiring_soon':
    case 'promotion_expired':
    case 'store_approved':
    case 'store_rejected':
    case 'verification_under_review':
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
  // The backend's fine-grained type string (e.g. `order_shipped`), kept
  // alongside the coarse [type] bucket so taps can route to the exact
  // screen the notification is about.
  final String? rawType;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.rawType,
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
      rawType: json['type'] as String?,
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
        rawType: rawType,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        data: data,
      );

  String get filterKey => type.name;
}
