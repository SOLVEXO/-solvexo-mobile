/// Mirrors `solvexo-api`'s `Conversation` schema (`src/messaging/schemas/conversation.schema.ts`).
/// `getConversations`/`getConversationById` enrich the raw document with
/// lightweight `buyer`/`store` snapshots for display — both optional here
/// since not every endpoint returns them.
class ConversationPeer {
  final String? id;
  final String name;
  final String? avatar;

  const ConversationPeer({this.id, required this.name, this.avatar});

  factory ConversationPeer.fromJson(Map<String, dynamic>? json, {String avatarKey = 'profileImage'}) {
    if (json == null) return const ConversationPeer(name: '');
    return ConversationPeer(
      id: json['_id']?.toString(),
      name: json['name'] as String? ?? '',
      avatar: json[avatarKey] as String?,
    );
  }
}

class LastMessagePreview {
  final String messageId;
  final String? text;
  final String type;
  final String senderId;
  final String senderRole;
  final DateTime? sentAt;

  const LastMessagePreview({
    required this.messageId,
    this.text,
    required this.type,
    required this.senderId,
    required this.senderRole,
    this.sentAt,
  });

  factory LastMessagePreview.fromJson(Map<String, dynamic> json) => LastMessagePreview(
        messageId: json['messageId'] as String? ?? '',
        text: json['text'] as String?,
        type: json['type'] as String? ?? 'text',
        senderId: json['senderId'] as String? ?? '',
        senderRole: json['senderRole'] as String? ?? '',
        sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt'].toString()) : null,
      );

  /// A short, chat-list-friendly preview string for non-text message types.
  String get previewText {
    switch (type) {
      case 'image':
        return '📷 Photo';
      case 'video':
        return '🎥 Video';
      case 'voice':
        return '🎤 Voice message';
      case 'pdf':
      case 'document':
        return '📄 Document';
      case 'product_share':
        return '🛍️ Shared a product';
      default:
        return text ?? '';
    }
  }
}

class ConversationModel {
  final String id;
  final String buyerId;
  final String storeId;
  final String sellerId;
  final LastMessagePreview? lastMessage;
  final int buyerUnread;
  final int sellerUnread;
  final bool isPinned;

  /// Buyer has an active priority_support benefit at this store — the seller
  /// inbox sorts these first (server-side) and shows a badge.
  final bool isPriority;
  final bool isArchived;
  final bool isMuted;
  final bool blockedByBuyer;
  final bool blockedBySeller;
  final ConversationPeer? buyer;
  final ConversationPeer? store;
  final DateTime? updatedAt;

  const ConversationModel({
    required this.id,
    required this.buyerId,
    required this.storeId,
    required this.sellerId,
    this.lastMessage,
    this.buyerUnread = 0,
    this.sellerUnread = 0,
    this.isPinned = false,
    this.isPriority = false,
    this.isArchived = false,
    this.isMuted = false,
    this.blockedByBuyer = false,
    this.blockedBySeller = false,
    this.buyer,
    this.store,
    this.updatedAt,
  });

  int unreadFor(String role) => role == 'seller' ? sellerUnread : buyerUnread;

  /// The other party's display name/avatar from this [myRole]'s point of view
  /// — the store for a buyer, the buyer for a seller.
  String peerName(String myRole) =>
      myRole == 'seller' ? (buyer?.name ?? 'Buyer') : (store?.name ?? 'Store');
  String? peerAvatar(String myRole) => myRole == 'seller' ? buyer?.avatar : store?.avatar;

  bool isBlocked(String myRole) => myRole == 'seller' ? blockedBySeller : blockedByBuyer;

  factory ConversationModel.fromJson(Map<String, dynamic> json) => ConversationModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        buyerId: (json['buyerId'] ?? '').toString(),
        storeId: (json['storeId'] ?? '').toString(),
        sellerId: (json['sellerId'] ?? '').toString(),
        lastMessage: json['lastMessage'] != null
            ? LastMessagePreview.fromJson(json['lastMessage'] as Map<String, dynamic>)
            : null,
        buyerUnread: json['buyerUnread'] as int? ?? 0,
        sellerUnread: json['sellerUnread'] as int? ?? 0,
        isPinned: json['isPinned'] as bool? ?? false,
        isPriority: json['isPriority'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        isMuted: json['isMuted'] as bool? ?? false,
        blockedByBuyer: json['blockedByBuyer'] as bool? ?? false,
        blockedBySeller: json['blockedBySeller'] as bool? ?? false,
        buyer: json['buyer'] != null
            ? ConversationPeer.fromJson(json['buyer'] as Map<String, dynamic>?, avatarKey: 'profileImage')
            : null,
        store: json['store'] != null
            ? ConversationPeer.fromJson(json['store'] as Map<String, dynamic>?, avatarKey: 'logo')
            : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      );
}
