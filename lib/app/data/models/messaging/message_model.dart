/// Mirrors `solvexo-api`'s `Message` schema (`src/messaging/schemas/message.schema.ts`).
class MessageAttachment {
  final String url;
  final String publicId;
  final String resourceType;
  final String? fileName;
  final int? fileSize;
  final String mimeType;
  final String? thumbnailUrl;

  const MessageAttachment({
    required this.url,
    required this.publicId,
    required this.resourceType,
    this.fileName,
    this.fileSize,
    required this.mimeType,
    this.thumbnailUrl,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) => MessageAttachment(
        url: json['url'] as String? ?? '',
        publicId: json['publicId'] as String? ?? '',
        resourceType: json['resourceType'] as String? ?? '',
        fileName: json['fileName'] as String?,
        fileSize: json['fileSize'] as int?,
        mimeType: json['mimeType'] as String? ?? '',
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'publicId': publicId,
        'resourceType': resourceType,
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        'mimeType': mimeType,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };
}

class MessageProductShare {
  final String productId;
  final String title;
  final double price;
  final String? image;
  final String? slug;

  const MessageProductShare({
    required this.productId,
    required this.title,
    required this.price,
    this.image,
    this.slug,
  });

  factory MessageProductShare.fromJson(Map<String, dynamic> json) => MessageProductShare(
        productId: json['productId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        image: json['image'] as String?,
        slug: json['slug'] as String?,
      );
}

class MessageReplyTo {
  final String messageId;
  final String? text;
  final String type;
  final String senderId;
  final String senderRole;

  const MessageReplyTo({
    required this.messageId,
    this.text,
    required this.type,
    required this.senderId,
    required this.senderRole,
  });

  factory MessageReplyTo.fromJson(Map<String, dynamic> json) => MessageReplyTo(
        messageId: json['messageId'] as String? ?? '',
        text: json['text'] as String?,
        type: json['type'] as String? ?? 'text',
        senderId: json['senderId'] as String? ?? '',
        senderRole: json['senderRole'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        if (text != null) 'text': text,
        'type': type,
        'senderId': senderId,
        'senderRole': senderRole,
      };
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole; // user | seller | admin
  final String type; // text | image | video | pdf | document | voice | product_share
  final String? text;
  final List<MessageAttachment> attachments;
  final MessageProductShare? productShare;
  final MessageReplyTo? replyTo;
  final String status; // sent | delivered | seen
  final List<String> seenByUserIds;
  final bool isEdited;
  final bool isDeleted;
  final List<String> deletedByUsers;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.type,
    this.text,
    this.attachments = const [],
    this.productShare,
    this.replyTo,
    this.status = 'sent',
    this.seenByUserIds = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.deletedByUsers = const [],
    this.createdAt,
  });

  bool isMine(String myUserId) => senderId == myUserId;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        conversationId: (json['conversationId'] ?? '').toString(),
        senderId: (json['senderId'] ?? '').toString(),
        senderRole: json['senderRole'] as String? ?? 'user',
        type: json['type'] as String? ?? 'text',
        text: json['text'] as String?,
        attachments: (json['attachments'] as List?)
                ?.map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
                .toList() ??
            const [],
        productShare: json['productShare'] != null
            ? MessageProductShare.fromJson(json['productShare'] as Map<String, dynamic>)
            : null,
        replyTo: json['replyTo'] != null
            ? MessageReplyTo.fromJson(json['replyTo'] as Map<String, dynamic>)
            : null,
        status: json['status'] as String? ?? 'sent',
        seenByUserIds: (json['seenBy'] as List?)
                ?.map((s) => (s as Map<String, dynamic>)['userId']?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toList() ??
            const [],
        isEdited: json['isEdited'] as bool? ?? false,
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedByUsers: (json['deletedByUsers'] as List?)?.cast<String>() ?? const [],
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}
