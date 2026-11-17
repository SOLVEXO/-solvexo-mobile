import 'package:book_store_app/app/routes/app_pages.dart';

/// Static metadata for the 6 AI Studio tools — drives the hub grid, history
/// filter chips, and generic label/icon lookups. `toolType` matches the
/// backend's `AiToolType` string exactly.
class AiToolMeta {
  final String toolType;
  final String title;
  final String description;
  final String emoji;
  final String route;

  const AiToolMeta({
    required this.toolType,
    required this.title,
    required this.description,
    required this.emoji,
    required this.route,
  });

  static const listingWriter = AiToolMeta(
    toolType: 'listing_writer',
    title: 'Listing Writer',
    description: 'Generate a product title, description & tags',
    emoji: '📝',
    route: Routes.aiStudioListingWriter,
  );

  static const seoBooster = AiToolMeta(
    toolType: 'seo_booster',
    title: 'SEO Booster',
    description: 'Optimize tags & titles for search ranking',
    emoji: '🚀',
    route: Routes.aiStudioSeoBooster,
  );

  static const emailCampaigns = AiToolMeta(
    toolType: 'email_campaigns',
    title: 'Email Campaigns',
    description: 'Draft buyer-facing marketing emails',
    emoji: '📧',
    route: Routes.aiStudioEmailCampaigns,
  );

  static const worksheetBuilder = AiToolMeta(
    toolType: 'worksheet_builder',
    title: 'Worksheet Builder',
    description: 'Build worksheet questions & an answer key',
    emoji: '📚',
    route: Routes.aiStudioWorksheetBuilder,
  );

  static const priceOptimizer = AiToolMeta(
    toolType: 'price_optimizer',
    title: 'Price Optimizer',
    description: 'Data-backed pricing from comparable listings',
    emoji: '💰',
    route: Routes.aiStudioPriceOptimizer,
  );

  static const imageEnhancer = AiToolMeta(
    toolType: 'image_enhancer',
    title: 'Image Enhancer',
    description: 'Upscale, denoise, or clean up a product photo',
    emoji: '🖼️',
    route: Routes.aiStudioImageEnhancer,
  );

  static const all = <AiToolMeta>[
    listingWriter,
    seoBooster,
    emailCampaigns,
    worksheetBuilder,
    priceOptimizer,
    imageEnhancer,
  ];

  static AiToolMeta byToolType(String toolType) =>
      all.firstWhere((t) => t.toolType == toolType, orElse: () => listingWriter);
}
