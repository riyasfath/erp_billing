import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/product_detail_model.dart';
import 'package:ecommerce_app/viewmodel/product_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_details_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:ecommerce_app/views/screens/category/product_details_screen.dart';

/// The "Favorites" tab — "My Wishlist". Empty state matches the Figma
/// illustration + "Explore Wishlist" (jumps to Shop); filled state is
/// a search bar over a 2-column grid of every favorited product.
///
/// Products now come from the real, already-fetched ProductViewModel
/// list (the same one ShopScreen uses) — not from dummy_product.dart.
class FavoritesScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final void Function(String productId) onToggleFavorite;
  final VoidCallback onExploreWishlist;

  const FavoritesScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onExploreWishlist,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _addingProductIds = {};

  @override
  void initState() {
    super.initState();
    // Make sure the real product list is loaded — if the person opens
    // Favorites before ever visiting Shop, ProductViewModel.products
    // could still be empty.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProductViewModel>();
      if (vm.products.isEmpty) vm.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Every favorited product, unfiltered — used to decide whether the
  /// user has ANY wishlist items at all (independent of the current
  /// search text).
  List<ProductModel> _allFavorites(List<ProductModel> allProducts) {
    return allProducts.where((p) => widget.favoriteIds.contains(p.id)).toList();
  }

  List<ProductModel> _searchFiltered(List<ProductModel> favorites) {
    if (_searchQuery.isEmpty) return favorites;
    final q = _searchQuery.toLowerCase();
    return favorites.where((p) => p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q)).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  // -------------------------------------------------------------------
  // ADD TO CART — same real logic as ShopScreen: no navigation, just
  // adds. Size is requested only if the product actually has sizes;
  // color silently defaults to the first option.
  // -------------------------------------------------------------------
  void _showSnack(String message, {bool isError = false, IconData icon = Icons.check_circle}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.badgeRed : const Color(0xFF16A34A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 1800),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickSize(List<String> sizes) {
    String? chosen;
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECT SIZE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: sizes.map((s) {
                        final bool selected = s == chosen;
                        return GestureDetector(
                          onTap: () => setSheetState(() => chosen = s),
                          child: Container(
                            width: 68,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primaryBlue : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGrey),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: chosen == null ? null : () => Navigator.pop(sheetContext, chosen),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          disabledBackgroundColor: AppColors.borderGrey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _quickAddToCart(ProductModel product) async {
    if (_addingProductIds.contains(product.id)) return;
    setState(() => _addingProductIds.add(product.id));

    try {
      final detailViewModel = ProductDetailViewModel();
      await detailViewModel.fetchDetail(product.id);
      final ProductDetailModel? detail = detailViewModel.detail;

      if (detail == null) {
        _showSnack(detailViewModel.error ?? 'Could not load this product', isError: true, icon: Icons.error_outline);
        return;
      }

      String size = '';
      if (detail.sizes.isNotEmpty) {
        final chosen = await _pickSize(detail.sizes);
        if (chosen == null) return; // user dismissed the size sheet — not added, no navigation either
        size = chosen;
      }

      final String color = detail.colors.isNotEmpty ? detail.colors.first : 'N/A';

      if (!mounted) return;
      final cartViewModel = context.read<CartViewModel>();
      final success = await cartViewModel.addToCart(
        productId: detail.id,
        quantity: 1,
        size: size,
        color: color,
      );

      if (!mounted) return;
      if (success) {
        _showSnack('${detail.name} added to your cart');
      } else {
        _showSnack(cartViewModel.addError ?? 'Could not add to cart', isError: true, icon: Icons.error_outline);
      }
    } finally {
      if (mounted) setState(() => _addingProductIds.remove(product.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();
    final bool landscape = _isLandscape(context);
    final allFavorites = _allFavorites(productViewModel.products);
    final visibleFavorites = _searchFiltered(allFavorites);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, landscape ? 8 : 16, 20, 0),
            child: Row(
              children: [
                Text(
                  'My Wishlist',
                  style: TextStyle(fontSize: landscape ? 17 : 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
              ],
            ),
          ),
          // The search bar is now ALWAYS shown once the user has at
          // least one favorited product — this was the actual bug:
          // it previously only rendered inside the "filled" state, so
          // a search with zero matches swapped in the empty-state
          // illustration (which has no search field on it at all) and
          // there was no way left to clear the search and get back to
          // the saved list without restarting the app.
          if (allFavorites.isNotEmpty) _buildSearchBar(landscape),
          Expanded(
            child: productViewModel.isLoading && productViewModel.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : (allFavorites.isEmpty
                    ? _buildEmptyState(landscape)
                    : (visibleFavorites.isEmpty ? _buildNoSearchResults(landscape) : _buildGrid(visibleFavorites, landscape))),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool landscape) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, landscape ? 10 : 16, 20, landscape ? 10 : 12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: const InputDecoration(
                  hintText: 'Search your wishlist',
                  hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: const Icon(Icons.close, color: AppColors.iconGrey, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  // Was a fixed 160x160 icon + Center + no scrolling — in landscape
  // the whole block is taller than the available height and the
  // "Explore Wishlist" button (plus some of the text above it) got
  // pushed off-screen with no way to reach it. Now it scrolls, and
  // the icon/spacing shrink in landscape so it usually fits without
  // needing to scroll at all. Only shown when the user truly has no
  // favorited products at all (search text doesn't affect this).
  Widget _buildEmptyState(bool landscape) {
    final double iconBoxSize = landscape ? 100 : 160;
    final double iconSize = landscape ? 44 : 70;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.assignment_turned_in_outlined, size: iconSize, color: AppColors.primaryBlue),
          ),
          SizedBox(height: landscape ? 14 : 24),
          const Text(
            "You haven't added any items to your wishlist yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the heart icon on any card product to save it here, let's add your wishlist.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
          ),
          SizedBox(height: landscape ? 16 : 22),
          ElevatedButton(
            onPressed: widget.onExploreWishlist,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: landscape ? 11 : 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text('Explore Wishlist', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  /// Shown when the user HAS favorited products, but the current
  /// search text matches none of them — distinct from the true empty
  /// state, and crucially still sits below the always-visible search
  /// bar so clearing the text is always reachable.
  Widget _buildNoSearchResults(bool landscape) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: landscape ? 80 : 110,
              height: landscape ? 80 : 110,
              decoration: BoxDecoration(color: AppColors.bgLight, shape: BoxShape.circle),
              child: Icon(Icons.search_off_rounded, size: landscape ? 36 : 48, color: AppColors.textGrey),
            ),
            const SizedBox(height: 18),
            Text(
              'No results for "$_searchQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try a different search, or clear it to see your full wishlist.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<ProductModel> favorites, bool landscape) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: favorites.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: landscape ? 3 : 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 240,
        ),
        itemBuilder: (context, index) => _productCard(favorites[index]),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final bool isAdding = _addingProductIds.contains(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
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
                  height: 110,
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
                      child: const Icon(Icons.favorite, size: 14, color: AppColors.badgeRed),
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
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
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
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 11, color: AppColors.star),
                                  const SizedBox(width: 2),
                                  Text('${product.rating}', style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: isAdding ? null : () => _quickAddToCart(product),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                            child: isAdding
                                ? const Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.add, color: Colors.white, size: 16),
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
      ),
    );
  }

  Widget _productImage(ProductModel product) {
    if (product.imagePath.isEmpty) {
      return const Center(child: Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28));
    }
    if (product.isNetworkImage) {
      return Image.network(
        product.imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stack) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28),
      );
    }
    return Image.asset(
      product.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28),
    );
  }
}