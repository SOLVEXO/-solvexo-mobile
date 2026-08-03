import 'package:book_store_app/app/data/models/storefront/storefront_model.dart';
import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/data/repositories/promotions_repository.dart';
import 'package:book_store_app/app/data/repositories/store_banner_repository.dart';
import 'package:book_store_app/app/data/repositories/storefront_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class SellerStorefrontController extends GetxController {
  final _repo = StorefrontRepository();
  final _messagingRepo = MessagingRepository();
  final _storeBannerRepo = StoreBannerRepository();
  final RxBool isStartingChat = false.obs;

  final ScrollController scrollController = ScrollController();

  late final String storeSlug;

  // ── Store profile ───────────────────────────────────────────────────────
  final Rx<StorefrontModel?> store = Rx(null);
  final RxBool isLoading = true.obs;
  final RxBool isFollowLoading = false.obs;
  final RxBool isFollowing = false.obs;

  // ── Products ─────────────────────────────────────────────────────────────
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxBool isLoadingProducts = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<String> filterTags = <String>[].obs;
  final RxInt totalProducts = 0.obs;

  final RxString selectedType = 'all'.obs; // all | physical | digital
  final RxString selectedTag = 'all'.obs;
  final RxString sort = 'newest'.obs; // newest | price_asc | price_desc | best_rated

  int _page = 1;
  bool _hasMore = false;
  bool get hasMore => _hasMore;

  // ── Store banners (seller's free hero carousel) ──────────────────────────
  final RxList<StoreBannerModel> storeBanners = <StoreBannerModel>[].obs;

  // ── Merchandising sections (pinned / new arrivals / best sellers / trending) ─
  // Fetched in parallel alongside products once `storeId` is known. Every
  // repository call silently returns [] on failure — no error toast, the
  // corresponding section just renders nothing (no-fake-data rule).
  final RxList<ProductModel> pinnedProducts = <ProductModel>[].obs;
  final RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxList<ProductModel> bestSellers = <ProductModel>[].obs;
  final RxList<ProductModel> trending = <ProductModel>[].obs;

  // ── Announcement bar ─────────────────────────────────────────────────────
  // Local-only, not persisted — dismissing just hides it for the rest of
  // this screen's lifetime (same pattern as HomeController.announcementDismissed).
  final RxBool announcementBarDismissed = false.obs;

  // ── Store banner impressions ─────────────────────────────────────────────
  final Set<String> _impressedStoreBannerIds = {};

  static const sortLabels = {
    'newest': 'Newest',
    'price_asc': 'Price: Low to High',
    'price_desc': 'Price: High to Low',
    'best_rated': 'Top Rated',
  };

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _readArgs();
    _loadStore();
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300) {
        loadMoreProducts();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _readArgs() {
    final args = Get.arguments;
    if (args is Map) {
      storeSlug = args['slug'] as String? ?? '';
    } else if (args is String) {
      storeSlug = args;
    } else {
      storeSlug = '';
    }
  }

  // ── Store profile ────────────────────────────────────────────────────────

  Future<void> _loadStore() async {
    if (storeSlug.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    final result = await _repo.getStoreBySlug(storeSlug);
    store.value = result;
    isLoading.value = false;

    if (result != null) {
      await Future.wait([
        loadProducts(reset: true),
        _loadFilterTags(),
        _loadFollowStatus(),
        _loadStoreBanners(),
        _loadMerchandisingSections(),
      ]);
    }
  }

  Future<void> _loadStoreBanners() async {
    final storeId = store.value?.storeId;
    if (storeId == null || storeId.isEmpty) return;
    storeBanners.assignAll(await _storeBannerRepo.getPublicBanners(storeId));
  }

  Future<void> _loadMerchandisingSections() async {
    final storeId = store.value?.storeId;
    if (storeId == null || storeId.isEmpty) return;
    final results = await Future.wait([
      _repo.getPinnedProducts(storeId),
      _repo.getNewArrivals(storeId),
      _repo.getBestSellers(storeId),
      _repo.getTrending(storeId),
    ]);
    pinnedProducts.assignAll(results[0]);
    newArrivals.assignAll(results[1]);
    bestSellers.assignAll(results[2]);
    trending.assignAll(results[3]);
  }

  Future<void> refreshData() => _loadStore();

  Future<void> _loadFilterTags() async {
    final storeId = store.value?.storeId;
    if (storeId == null || storeId.isEmpty) return;
    filterTags.assignAll(await _repo.getStoreFilterTags(storeId));
  }

  Future<void> _loadFollowStatus() async {
    final storeId = store.value?.storeId;
    if (storeId == null || storeId.isEmpty) return;
    isFollowing.value = await _repo.getFollowStatus(storeId);
  }

  // ── Products ─────────────────────────────────────────────────────────────

  Future<void> loadProducts({bool reset = false}) async {
    final storeId = store.value?.storeId;
    if (storeId == null || storeId.isEmpty) return;

    if (reset) {
      _page = 1;
      isLoadingProducts.value = true;
    }

    final result = await _repo.getStoreProducts(
      storeId: storeId,
      page: _page,
      type: selectedType.value,
      tag: selectedTag.value,
      sort: sort.value,
    );

    if (reset) {
      products.assignAll(result.products);
    } else {
      products.addAll(result.products);
    }
    totalProducts.value = result.total;
    _hasMore = result.hasMore;
    isLoadingProducts.value = false;
    isLoadingMore.value = false;
  }

  Future<void> loadMoreProducts() async {
    if (!_hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    _page++;
    await loadProducts();
  }

  void setType(String type) {
    if (selectedType.value == type) return;
    selectedType.value = type;
    loadProducts(reset: true);
  }

  void setTag(String tag) {
    if (selectedTag.value == tag) return;
    selectedTag.value = tag;
    loadProducts(reset: true);
  }

  void setSort(String value) {
    if (sort.value == value) return;
    sort.value = value;
    loadProducts(reset: true);
  }

  // ── Follow / unfollow ────────────────────────────────────────────────────

  Future<void> toggleFollow() async {
    final s = store.value;
    if (s == null || isFollowLoading.value) return;

    final profile = _resolveProfileController();
    if (profile.user.value == null) {
      ToastUtil.showToast('Please log in to follow this store.');
      Get.toNamed(Routes.authTabView);
      return;
    }

    isFollowLoading.value = true;
    final wasFollowing = isFollowing.value;
    // Optimistic update
    isFollowing.value = !wasFollowing;
    store.value = StorefrontModel(
      storeId: s.storeId,
      sellerId: s.sellerId,
      name: s.name,
      slug: s.slug,
      logo: s.logo,
      coverImage: s.coverImage,
      description: s.description,
      followersCount: s.followersCount + (wasFollowing ? -1 : 1),
      sellerType: s.sellerType,
      badges: s.badges,
      pinnedProductIds: s.pinnedProductIds,
      announcementBar: s.announcementBar,
    );

    final following = await _repo.toggleFollow(s.storeId);
    isFollowLoading.value = false;

    if (following == null) {
      // Revert on failure
      isFollowing.value = wasFollowing;
      store.value = s;
      ToastUtil.showToast('Could not update follow status. Please try again.');
    }
  }

  ProfileController _resolveProfileController() {
    if (Get.isRegistered<ProfileController>()) {
      return Get.find<ProfileController>();
    }
    return Get.put(ProfileController());
  }

  // ── Message seller ───────────────────────────────────────────────────────

  Future<void> messageStore() async {
    final s = store.value;
    if (s == null || isStartingChat.value) return;

    final profile = _resolveProfileController();
    if (profile.user.value == null) {
      ToastUtil.showToast('Please log in to message this store.');
      Get.toNamed(Routes.authTabView);
      return;
    }

    isStartingChat.value = true;
    final conversation = await _messagingRepo.startConversation(s.storeId);
    isStartingChat.value = false;

    if (conversation != null) {
      Get.toNamed(Routes.chatView, arguments: {
        'conversationId': conversation.id,
        'peerName': s.name,
        'peerAvatar': s.logo,
      });
    }
  }

  // ── Store banner impressions ─────────────────────────────────────────────

  /// Fires the store-banner impression beacon at most once per banner id
  /// per storefront view session — call from `StoreBannerCarousel` for
  /// whichever page is currently visible.
  void maybeTrackStoreBannerImpression(String bannerId) {
    if (bannerId.isEmpty) return;
    if (_impressedStoreBannerIds.add(bannerId)) {
      PromotionsRepository().trackImpression(entityType: 'store_banner', entityId: bannerId);
    }
  }

  // ── Announcement bar ─────────────────────────────────────────────────────

  void dismissAnnouncementBar() => announcementBarDismissed.value = true;

  // ── Share ────────────────────────────────────────────────────────────────

  void shareStore() {
    final s = store.value;
    if (s == null) return;
    final desc = (s.description ?? '').trim();
    final text = desc.isNotEmpty ? '${s.name} — $desc' : 'Check out ${s.name}\'s store!';
    SharePlus.instance.share(ShareParams(text: text, subject: s.name));
  }
}
