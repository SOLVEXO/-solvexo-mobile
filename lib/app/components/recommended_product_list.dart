import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class RecommendedProductList extends StatelessWidget {
  const RecommendedProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return Obx(() {
      // ── Loading ───────────────────────────────────────────────────────
      if (controller.isFetchingProducts.value && controller.products.isEmpty) {
        return const _RecommendedShimmer();
      }

      // ── Empty ─────────────────────────────────────────────────────────
      if (controller.products.isEmpty) {
        return Center(child: CustomText(text: "No Product Found!"));
      }

      // ── Loaded ────────────────────────────────────────────────────────
      return SizedBox(
        height: Get.height / 2.7,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemCount: controller.products.length,
          itemBuilder: (_, index) {
            final item = controller.products[index];
            return ProductCard(product: item, index: index);
          },
        ),
      );
    });
  }
}

// ─── Shimmer ───────────────────────────────────────────────────────────────

class _RecommendedShimmer extends StatelessWidget {
  const _RecommendedShimmer();

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    // Derive exact card size from the same formula used in the real list
    final listHeight = Get.height / 2.7;
    final cardHeight =
        listHeight - 16; // subtract vertical padding (8 top + 8 bottom)
    final cardWidth = cardHeight / 1.8; // childAspectRatio: 1.8

    return SizedBox(
      height: listHeight,
      child: Shimmer.fromColors(
        baseColor: _base,
        highlightColor: _highlight,
        period: const Duration(milliseconds: 1400),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) =>
              _ShimmerCard(cardWidth: cardWidth, cardHeight: cardHeight),
        ),
      ),
    );
  }
}

// ─── Shimmer card ──────────────────────────────────────────────────────────

class _ShimmerCard extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;

  const _ShimmerCard({required this.cardWidth, required this.cardHeight});

  static const Color _shape = Color(0xFFD4D4D4);

  @override
  Widget build(BuildContext context) {
    final imageHeight = cardHeight * 0.52;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image block ──────────────────────────────────────────────
          Container(
            width: cardWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              color: _shape,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name line 1
                  _S(width: cardWidth * 0.84, height: 13),
                  const SizedBox(height: 5),

                  // Name line 2
                  _S(width: cardWidth * 0.60, height: 12),
                  const SizedBox(height: 10),

                  // Price + stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _P(width: cardWidth * 0.44, height: 20),
                      _S(width: cardWidth * 0.30, height: 14, radius: 6),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Star rating row
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (_) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: _S(width: 11, height: 11, radius: 3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _S(width: 24, height: 11),
                    ],
                  ),

                  const Spacer(),

                  // Add to cart button
                  _S(width: cardWidth - 20, height: 32, radius: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primitives ────────────────────────────────────────────────────────────

/// Rectangle
class _S extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _S({required this.width, required this.height, this.radius = 8});

  static const Color _shape = Color(0xFFD4D4D4);

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _shape,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Pill
class _P extends StatelessWidget {
  final double width;
  final double height;

  const _P({required this.width, required this.height});

  static const Color _shape = Color(0xFFD4D4D4);

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: _shape,
      borderRadius: BorderRadius.circular(height / 2),
    ),
  );
}
