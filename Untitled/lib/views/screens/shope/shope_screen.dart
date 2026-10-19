import 'package:ecommerce_app/utils/filter_bottom_sheet.dart';
import 'package:ecommerce_app/views/screens/category/product_details_screen.dart';
import 'package:ecommerce_app/views/screens/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/product_detail_model.dart';
import 'package:ecommerce_app/viewmodel/product_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_details_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The "Shop" tab body — search bar (filter icon left, cart icon
/// right), real persisted recent searches, category tabs, a
/// results-count + sort row, and a 2-column product grid with
/// New Arrival / Best Seller / Trending badges.
///
/// Everything here is backed by real data:
/// - Products: GET /api/products/ via ProductViewModel.
/// - Recent searches: persisted on-device via shared_preferences.
/// - Filters: ShopFilters, computed from and applied to the real
///   product list (see filter_bottom_sheet.dart).
/// - "+" quick add-to-cart: fetches the product's real detail (for
///   size/color, which the list model doesn't carry) and calls the
///   real CartViewModel.addToCart — same rules as ProductDetailScreen
///   (size required only if the product has sizes; color silently
///   defaults to the first option, same as the detail screen).
class ShopScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final void Function(String productId) onToggleFavorite;
  final void Function(ProductModel product)? onAddToCart;

  const ShopScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
    this.onAddToCart,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 8;

  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  String _searchQuery = '';

  String _selectedTab = 'All'; // All | Men | Women | Kids
  ShopFilters _filters = ShopFilters.initial();

  final Set<String> _addingProductIds = {};

  static const List<String> _tabs = ['All', 'Men', 'Women', 'Kids'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProducts();
    });
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // RECENT SEARCHES — persisted for real via shared_preferences
  // -------------------------------------------------------------------
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_recentSearchesKey) ?? [];
    if (!mounted) return;
    setState(() => _recentSearches = saved);
  }

  Future<void> _persistRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  Future<void> _submitSearch(String term) async {
    final trimmed = term.trim();
    setState(() => _searchQuery = trimmed);
    if (trimmed.isEmpty) return;

    setState(() {
      _recentSearches.removeWhere((t) => t.toLowerCase() == trimmed.toLowerCase());
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }
    });
    await _persistRecentSearches();
  }

  void _runRecentSearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: term.length));
    _submitSearch(term);
  }

  Future<void> _removeRecentSearch(String term) async {
    setState(() => _recentSearches.remove(term));
    await _persistRecentSearches();
  }

  Future<void> _clearRecentSearches() async {
    setState(() => _recentSearches.clear());
    await _persistRecentSearches();
  }

  // -------------------------------------------------------------------
  // FILTERING + SORTING — all on real ProductModel fields
  // -------------------------------------------------------------------
  List<ProductModel> _visibleProducts(List<ProductModel> all) {
    Iterable<ProductModel> list = all;

    if (_selectedTab != 'All') {
      list = list.where((p) => p.category == _selectedTab.toLowerCase());
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q));
    }

    if (_filters.categoryName != null) {
      list = list.where((p) => p.categoryName == _filters.categoryName);
    }

    list = list.where((p) => p.price >= _filters.priceRange.start && p.price <= _filters.priceRange.end);

    if (_filters.brands.isNotEmpty) {
      list = list.where((p) => _filters.brands.contains(p.brand));
    }

    if (_filters.minRating != null) {
      list = list.where((p) => p.rating >= _filters.minRating!);
    }

    if (_filters.inStockOnly) {
      list = list.where((p) => (p.totalStock ?? 0) > 0);
    }

    return _applySort(list.toList());
  }

  List<ProductModel> _applySort(List<ProductModel> list) {
    final sorted = [...list];
    switch (_filters.sortBy) {
      case 'Price: Low to High':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Most Popular':
        sorted.sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
        break;
      case 'Newest Arrivals':
        sorted.sort((a, b) => (b.badge == 'New' ? 1 : 0).compareTo(a.badge == 'New' ? 1 : 0));
        break;
      case 'Recommended':
      default:
        break; // keep the API's own order
    }
    return sorted;
  }

  Future<void> _openFilters() async {
    final products = context.read<ProductViewModel>().products;
    final result = await showModalBottomSheet<ShopFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(products: products, initialFilters: _filters),
    );
    if (result != null && mounted) {
      setState(() => _filters = result);
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: kSortOptions.map((o) {
            return ListTile(
              title: Text(o),
              trailing: o == _filters.sortBy ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
              onTap: () {
                setState(() => _filters = _filters.copyWith(sortBy: o));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // QUICK ADD TO CART — mirrors ProductDetailScreen's rules exactly:
  // size is required only if the product has sizes; color silently
  // defaults to the first option (the detail screen never forces a
  // color choice either).
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
        if (chosen == null) return; // user dismissed the size sheet
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
        widget.onAddToCart?.call(product);
      } else {
        _showSnack(cartViewModel.addError ?? 'Could not add to cart', isError: true, icon: Icons.error_outline);
      }
    } finally {
      if (mounted) setState(() => _addingProductIds.remove(product.id));
    }
  }

  // -------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();
    final results = _visibleProducts(productViewModel.products);

    return SafeArea(
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_recentSearches.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildRecentSearches(),
                  ],
                  const SizedBox(height: 18),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  _buildResultsRow(results.length),
                  const SizedBox(height: 14),
                  _buildResultsBody(productViewModel, results),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // SEARCH BAR — filter icon left, cart icon right (navigates to CartScreen)
  // -------------------------------------------------------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _openFilters,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.tune_rounded, size: 20, color: AppColors.textDark),
                  if (!_filters.isDefault)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(radius: 4, backgroundColor: AppColors.primaryBlue),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.iconGrey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submitSearch,
                      decoration: const InputDecoration(
                        hintText: 'Search product here',
                        hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close, color: AppColors.iconGrey, size: 18),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // RECENT SEARCHES — real, persisted, removable chips + Clear all
  // -------------------------------------------------------------------
  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'RECENT SEARCHES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _clearRecentSearches,
                child: const Text(
                  'CLEAR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((term) {
              return GestureDetector(
                onTap: () => _runRecentSearch(term),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(term, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeRecentSearch(term),
                        child: const Icon(Icons.close, size: 15, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // CATEGORY TABS — All / Men / Women / Kids
  // -------------------------------------------------------------------
  Widget _buildTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final bool selected = tab == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.textDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? AppColors.textDark : AppColors.borderGrey),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textGrey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // RESULTS COUNT + SORT
  // -------------------------------------------------------------------
  Widget _buildResultsRow(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text.rich(
            TextSpan(
              text: 'Showing ',
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              children: [
                TextSpan(text: '$count', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                const TextSpan(text: ' results'),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showSortSheet,
            child: Text(
              'Sort by: ${_filters.sortBy}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // RESULTS BODY — loading / error / empty / grid + load-more
  // -------------------------------------------------------------------
  Widget _buildResultsBody(ProductViewModel viewModel, List<ProductModel> products) {
    if (viewModel.isLoading && viewModel.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.error != null && viewModel.products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchProducts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Text('No results match your search/filters', style: TextStyle(color: AppColors.textGrey)),
        ),
      );
    }

    return Column(
      children: [
        _buildResultsGrid(products),
        if (viewModel.hasMore) ...[
          const SizedBox(height: 16),
          Center(
            child: viewModel.isLoadingMore
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () => viewModel.loadMore(),
                    child: const Text('Load More'),
                  ),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------------
  // PRODUCT GRID
  // -------------------------------------------------------------------
  Widget _buildResultsGrid(List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 240,
        ),
        itemBuilder: (context, index) => _productCard(products[index]),
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final bool isFavorite = widget.favoriteIds.contains(product.id);
    final bool isAdding = _addingProductIds.contains(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
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
                  height: 130,
                  color: AppColors.bgLight,
                  child: _productImage(product),
                ),
                if (product.badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
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
                    Row(
                      children: [
                        const CircleAvatar(radius: 6, backgroundColor: AppColors.bgLight),
                        const SizedBox(width: 6),
                        Text(product.brand, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                children: [
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                                  ),
                                  if (product.oldPrice != null)
                                    Text(
                                      '\$${product.oldPrice!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textGrey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: AppColors.star),
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
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                            child: isAdding
                                ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.add, color: Colors.white, size: 17),
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

  /// Real products carry a network image URL; any leftover local/dummy
  /// asset data still uses local assets — this handles both.
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
            child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
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