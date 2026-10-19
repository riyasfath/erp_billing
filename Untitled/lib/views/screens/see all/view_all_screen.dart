import 'dart:async';
import 'package:ecommerce_app/views/screens/category/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// One section of products within a View All page, e.g.
/// "Latest Deals" or "Other Flash Deals".
class ViewAllSection {
  final String title;
  final List<ProductModel> products;
  const ViewAllSection({required this.title, required this.products});
}

/// Generic "View All" page — used for New Arrivals, Best Seller,
/// Popular Product, and Special For You. Pass a different banner
/// color/copy/sections list per entry point (see homescreen.dart).
class ViewAllScreen extends StatefulWidget {
  final String pageTitle;
  final Color bannerColor;
  final String bannerTitle;
  final String bannerSubtitle;
  final bool showCountdown;
  final bool showSoldBadge;
  final List<ViewAllSection> sections;
  final Set<String> favoriteIds;
  final void Function(String productId) onToggleFavorite;

  const ViewAllScreen({
    super.key,
    required this.pageTitle,
    required this.bannerColor,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.sections,
    required this.favoriteIds,
    required this.onToggleFavorite,
    this.showCountdown = false,
    this.showSoldBadge = false,
  });

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  Duration _remaining = const Duration(hours: 12, minutes: 58, seconds: 47);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.showCountdown) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining.inSeconds <= 0) {
          _timer?.cancel();
          return;
        }
        setState(() => _remaining -= const Duration(seconds: 1));
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildBanner(),
                    if (widget.showCountdown) ...[
                      const SizedBox(height: 20),
                      _buildCountdown(),
                    ],
                    for (final section in widget.sections) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildGrid(section.products),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // TOP BAR — back button + title
  // -------------------------------------------------------------------
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 52),
                child: Text(
                  widget.pageTitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // SEARCH BAR — microphone/voice-search icon removed since it wasn't
  // wired to any actual voice-search functionality (tapping it did
  // nothing).
  // -------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Product Here',
                  hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // BANNER
  // -------------------------------------------------------------------
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.bannerColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bannerTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.bannerSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/images/shoe2.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.sports_gymnastics, color: Colors.white70, size: 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // COUNTDOWN — "Ended Before HH : MM : SS"
  // -------------------------------------------------------------------
  Widget _buildCountdown() {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Ended Before',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          _countdownBox(h, 'Hours'),
          const SizedBox(width: 8),
          const Text(':', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _countdownBox(m, 'Minutes'),
          const SizedBox(width: 8),
          const Text(':', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _countdownBox(s, 'Seconds'),
        ],
      ),
    );
  }

  Widget _countdownBox(String value, String label) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFEA580C)),
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
      ],
    );
  }

  // -------------------------------------------------------------------
  // PRODUCT GRID
  // -------------------------------------------------------------------
  Widget _buildGrid(List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: widget.showSoldBadge ? 290 : 250,
        ),
        itemBuilder: (context, index) => _productCard(products[index]),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final bool isFavorite = widget.favoriteIds.contains(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 140,
                  color: AppColors.bgLight,
                  child: _productImage(product),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => widget.onToggleFavorite(product.id),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isFavorite ? AppColors.badgeRed : AppColors.textGrey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (product.oldPrice != null)
                          Text(
                            '\$${product.oldPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGrey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        const Spacer(),
                        const Icon(Icons.star, size: 12, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text('${product.rating}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                      ],
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    if (widget.showSoldBadge && product.soldCount != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${product.soldCount}/${product.totalStock} Sold',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Real products carry a network image URL; any leftover dummy data
  /// still uses local assets — this handles both.
  Widget _productImage(ProductModel product) {
    if (product.imagePath.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28),
      );
    }
    if (product.isNetworkImage) {
      return Image.network(
        product.imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28),
      );
    }
    return Image.asset(
      product.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
          const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28),
    );
  }
}