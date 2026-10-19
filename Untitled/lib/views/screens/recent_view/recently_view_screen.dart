import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// "Recently Viewed" page — reached from Home > Recently Viewed > See All.
/// Shows every recently viewed sample product in a 2-column grid, using
/// the same card look as the Home product grids (favorite toggle + add
/// to cart button included).
class RecentlyViewedScreen extends StatelessWidget {
  final List<ProductModel> products;
  final Set<String> favoriteIds;
  final void Function(String productId) onToggleFavorite;
  final void Function(ProductModel product) onAddToCart;

  const RecentlyViewedScreen({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(
                        'No recently viewed products yet',
                        style: const TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 240,
                      ),
                      itemBuilder: (context, index) => _productCard(products[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Recently Viewed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return Container(
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
              _productThumb(product.imagePath, size: double.infinity, height: 110),
              if (product.badge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: _favoriteButton(product.id, size: 24, withBackground: true),
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
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                if (product.oldPrice != null) ...[
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '\$${product.oldPrice!.toStringAsFixed(2)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textGrey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 11, color: AppColors.star),
                                const SizedBox(width: 2),
                                Text(
                                  '${product.rating}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onAddToCart(product),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteButton(String productId, {double size = 24, bool withBackground = false}) {
    final bool isFavorite = favoriteIds.contains(productId);
    final icon = Icon(
      isFavorite ? Icons.favorite : Icons.favorite_border,
      size: size * 0.6,
      color: isFavorite ? AppColors.badgeRed : AppColors.textGrey,
    );

    return GestureDetector(
      onTap: () => onToggleFavorite(productId),
      child: withBackground
          ? Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: icon,
            )
          : icon,
    );
  }

  Widget _productThumb(String path, {double size = 60, double? height}) {
    return Container(
      width: size,
      height: height ?? size,
      color: AppColors.bgLight,
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          path,
          width: size,
          height: height ?? size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => const Icon(
            Icons.image_outlined,
            color: AppColors.hintGrey,
            size: 28,
          ),
        ),
      ),
    );
  }
}