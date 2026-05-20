import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

const Color _kBase = Color(0xFFE0E0E0);
const Color _kHighlight = Color(0xFFF5F5F5);
const Color _kShape = Color(0xFFD6D6D6);

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      body: Shimmer.fromColors(
        baseColor: _kBase,
        highlightColor: _kHighlight,
        period: const Duration(milliseconds: 1400),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ───────── Hero Image ─────────
              Container(
                height: MediaQuery.of(context).size.height / 4,
                width: double.infinity,
                color: const Color(0xffF8F8F8),
                child: const Center(
                  child: _S(width: 220, height: 180, radius: 16),
                ),
              ),

              /// ───────── White Content Area ─────────
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Product Name + Actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            spacing: 10,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _S(width: double.infinity, height: 18),
                              SizedBox(height: 8),
                              _S(width: 180, height: 14),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const _SC(size: 38),
                        const SizedBox(width: 10),
                        const _SC(size: 38),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Price + Stock
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _SP(width: 120, height: 32),
                        _SP(width: 110, height: 28),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const _Divider(),

                    const SizedBox(height: 16),

                    /// Seller
                    Row(
                      spacing: 10,
                      children: const [
                        _S(width: 70, height: 14),
                        SizedBox(width: 8),
                        _SP(width: 100, height: 24),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Color Section
                    const _S(width: 60, height: 15),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _S(width: 70, height: 36),
                        _S(width: 90, height: 36),
                        _S(width: 80, height: 36),
                        _S(width: 75, height: 36),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// Size Section
                    const _S(width: 45, height: 15),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _S(width: 80, height: 36),
                        _S(width: 90, height: 36),
                        _S(width: 100, height: 36),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// SKU + Stock Badge
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _SP(width: 130, height: 28),
                        _SP(width: 110, height: 28),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const _Divider(),

                    const SizedBox(height: 18),

                    /// Description
                    const _S(width: 100, height: 16),
                    const SizedBox(height: 12),

                    const _S(width: double.infinity, height: 13),
                    const SizedBox(height: 8),
                    const _S(width: double.infinity, height: 13),
                    const SizedBox(height: 8),
                    const _S(width: double.infinity, height: 13),
                    const SizedBox(height: 8),
                    const _S(width: 220, height: 13),

                    const SizedBox(height: 20),

                    /// Rating + Sold
                    Row(
                      children: const [
                        _S(width: 16, height: 16, radius: 4),
                        SizedBox(width: 8),
                        _S(width: 30, height: 13),
                        SizedBox(width: 12),
                        _S(width: 1, height: 16),
                        SizedBox(width: 12),
                        _S(width: 80, height: 13),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const _Divider(),

                    const SizedBox(height: 18),

                    /// Reviews
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _S(width: 80, height: 16),
                        _S(width: 24, height: 24),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xffF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              const _SC(size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  spacing: 10,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _S(width: 120, height: 14),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (_) => const Padding(
                                          padding: EdgeInsets.only(right: 4),
                                          child: _S(
                                            width: 14,
                                            height: 14,
                                            radius: 3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const _S(width: double.infinity, height: 13),
                          const SizedBox(height: 8),
                          const _S(width: 220, height: 13),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const _Divider(),

                    const SizedBox(height: 18),

                    /// Related Products
                    const _S(width: 140, height: 16),
                    const SizedBox(height: 14),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 10,
                        children: List.generate(
                          4,
                          (_) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                _S(width: 130, height: 140, radius: 14),
                                SizedBox(height: 8),
                                _S(width: 100, height: 13),
                                SizedBox(height: 6),
                                _S(width: 70, height: 13),
                                SizedBox(height: 8),
                                _SP(width: 80, height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// ───────── Bottom Bar ─────────
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Row(
          children: [
            const _S(width: 140, height: 52, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _kShape,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ───────── Rectangle ─────────
class _S extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _S({required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == double.infinity ? null : width,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: _kShape,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// ───────── Pill ─────────
class _SP extends StatelessWidget {
  final double width;
  final double height;

  const _SP({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _kShape,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// ───────── Circle ─────────
class _SC extends StatelessWidget {
  final double size;

  const _SC({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: _kShape, shape: BoxShape.circle),
    );
  }
}

/// ───────── Divider ─────────
class _Divider extends StatelessWidget {
  const _Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, width: double.infinity, color: _kShape);
  }
}
