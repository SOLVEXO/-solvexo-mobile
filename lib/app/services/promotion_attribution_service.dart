/// Tracks which promotional banner (if any) a buyer most recently tapped
/// through, so `CheckoutRepository.createCheckout` can pass it along as
/// `attributedBannerId`/`attributedStoreBannerId` for the backend's
/// impression → click → conversion attribution pipeline
/// (`solvexo-api`'s `PromotionsService.recordConversions`).
///
/// Deliberately a plain in-memory singleton, not a GetxService — nothing
/// reactive needs to observe it, it just needs to survive from wherever a
/// banner is tapped until checkout is created a few screens later. Mirrors
/// the backend's own "short-TTL localStorage-equivalent token" comment.
class PromotionAttributionService {
  PromotionAttributionService._();
  static final PromotionAttributionService instance = PromotionAttributionService._();

  static const _defaultTtl = Duration(minutes: 30);

  String? _entityType; // 'banner' | 'store_banner'
  String? _entityId;
  DateTime? _capturedAt;

  void capture(String entityType, String entityId) {
    if (entityId.isEmpty) return;
    _entityType = entityType;
    _entityId = entityId;
    _capturedAt = DateTime.now();
  }

  /// Returns `(bannerId, storeBannerId)` for the pending attribution if one
  /// was captured within [ttl], then clears it — a checkout can only ever
  /// consume one attribution once. Returns `(null, null)` otherwise.
  ({String? bannerId, String? storeBannerId}) consumeIfFresh({Duration ttl = _defaultTtl}) {
    final type = _entityType;
    final id = _entityId;
    final capturedAt = _capturedAt;
    _clear();

    if (type == null || id == null || capturedAt == null) return (bannerId: null, storeBannerId: null);
    if (DateTime.now().difference(capturedAt) > ttl) return (bannerId: null, storeBannerId: null);

    return type == 'store_banner' ? (bannerId: null, storeBannerId: id) : (bannerId: id, storeBannerId: null);
  }

  void _clear() {
    _entityType = null;
    _entityId = null;
    _capturedAt = null;
  }
}
