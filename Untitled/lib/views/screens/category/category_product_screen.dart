import 'package:ecommerce_app/views/screens/category/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// Product grid for a single category — reached from AllCategoriesScreen's
/// "View All Products" button. [products] is passed in directly (the
/// real, already-filtered list) rather than looked up from a dummy map.
class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;
  final List<ProductModel> products;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final Set<String> _favoriteIds = {};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.products
        : widget.products
            .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No products found', style: TextStyle(color: AppColors.textGrey)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        mainAxisExtent: 250,
                      ),
                      itemBuilder: (context, index) => _productCard(filtered[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final category = widget.category;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: category.iconBg.withOpacity(0.12),
            child: Icon(category.icon, color: category.iconBg, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Text('${category.productCount} Products',
                    style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: AppColors.star),
              const SizedBox(width: 3),
              Text('${category.rating}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: AppColors.bgLight, borderRadius: BorderRadius.circular(25)),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search Product Here',
                  hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const Icon(Icons.mic_none_rounded, color: AppColors.iconGrey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final bool isFavorite = _favoriteIds.contains(product.id);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
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
                  height: 130,
                  color: AppColors.bgLight,
                  child: _productImage(product),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isFavorite ? _favoriteIds.remove(product.id) : _favoriteIds.add(product.id);
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14, color: isFavorite ? AppColors.badgeRed : AppColors.textGrey),
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
                    Text(product.brand, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                    const SizedBox(height: 2),
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const Spacer(),
                    Row(
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const Spacer(),
                        const Icon(Icons.star, size: 12, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text('${product.rating}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Real products carry a network image URL; local dummy data still
  /// uses asset paths — this handles both.
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
              width: 20,
              height: 20,
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