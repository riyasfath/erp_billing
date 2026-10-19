import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/core/token_storage.dart';
import 'package:ecommerce_app/viewmodel/best_seller_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/notification_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/recently_viewmodel.dart';
import 'package:ecommerce_app/views/screens/category/all_category_screen.dart';
import 'package:ecommerce_app/views/screens/category/product_details_screen.dart';
import 'package:ecommerce_app/views/screens/notification/notification_screen.dart';
import 'package:ecommerce_app/views/screens/recent_view/recently_view_screen.dart';
import 'package:ecommerce_app/views/screens/see%20all/view_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/models/product_model.dart';

class HomeScreen extends StatefulWidget {
  final Set<String> favoriteIds;
  final void Function(String productId) onToggleFavorite;
  final void Function(ProductModel product) onAddToCart;
  final VoidCallback onNavigateToShop;
  final VoidCallback onNavigateToCart;

  const HomeScreen({
    super.key,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onNavigateToShop,
    required this.onNavigateToCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _recentPage = 0;
  final PageController _recentController = PageController();

  // 'all' | 'men' | 'women' | 'kids'
  String _selectedCategory = 'all';

  // Shown in the header in place of the old hardcoded 'Alexander Putra'.
  // Loaded from the saved login email, taking just the part before '@'.
  String _displayName = 'there';

  static const List<Map<String, String>> _categories = [
    {'label': 'ALL', 'value': 'all'},
    {'label': 'For Men', 'value': 'men'},
    {'label': 'For Women', 'value': 'women'},
    {'label': 'For Kids', 'value': 'kids'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BestSellerViewModel>().fetchBestSellers();
      context.read<ProductViewModel>().fetchProducts();
      context.read<NotificationViewModel>().fetchUnreadCount();
      context.read<RecentlyViewedViewModel>().loadFromStorage();
    });
  }

  Future<void> _loadDisplayName() async {
    final email = await TokenStorage.instance.getEmail();
    if (!mounted) return;
    if (email != null && email.contains('@')) {
      setState(() => _displayName = email.split('@').first);
    }
  }

  @override
  void dispose() {
    _recentController.dispose();
    super.dispose();
  }

  void _openViewAll({
    required String pageTitle,
    required Color bannerColor,
    required String bannerTitle,
    required String bannerSubtitle,
    required List<ViewAllSection> sections,
    bool showCountdown = false,
    bool showSoldBadge = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewAllScreen(
          pageTitle: pageTitle,
          bannerColor: bannerColor,
          bannerTitle: bannerTitle,
          bannerSubtitle: bannerSubtitle,
          showCountdown: showCountdown,
          showSoldBadge: showSoldBadge,
          sections: sections,
          favoriteIds: widget.favoriteIds,
          onToggleFavorite: widget.onToggleFavorite,
        ),
      ),
    );
  }

  void _openAllCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllCategoriesScreen()),
    );
  }

  void _openRecentlyViewed(List<ProductModel> realRecentlyViewed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecentlyViewedScreen(
          products: realRecentlyViewed,
          favoriteIds: widget.favoriteIds,
          onToggleFavorite: widget.onToggleFavorite,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  List<ProductModel> _filtered(List<ProductModel> source) {
    if (_selectedCategory == 'all') return source;
    return source.where((p) => p.category == _selectedCategory).toList();
  }

  /// Splits a real product list into two ViewAllSections (was two dummy
  /// consts before) so the "See All" pages show live data too.
  List<ViewAllSection> _splitIntoSections(
    List<ProductModel> products,
    String firstTitle,
    String secondTitle,
  ) {
    final int half = (products.length / 2).ceil();
    return [
      ViewAllSection(title: firstTitle, products: products.take(half).toList()),
      ViewAllSection(title: secondTitle, products: products.skip(half).toList()),
    ];
  }

  /// Shared by both the "Best Seller Deals" section's "See All" link
  /// and the featured banner tap — both should land on the same page.
  void _openBestSellerViewAll(BestSellerViewModel viewModel) {
    _openViewAll(
      pageTitle: 'Our Best Seller',
      bannerColor: const Color(0xFFF59E0B),
      bannerTitle: 'Check Today\'s\nBest Seller',
      bannerSubtitle: 'Let\'s get our best seller products\nwith best quality',
      showSoldBadge: true,
      sections: _splitIntoSections(viewModel.products, 'Best Seller Today', 'Other Best Seller'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productViewModel = context.watch<ProductViewModel>();
    final bestSellerViewModel = context.watch<BestSellerViewModel>();
    final recentlyViewedViewModel = context.watch<RecentlyViewedViewModel>();

    // No dedicated "new arrivals" / "most popular" / "special for you"
    // endpoints exist — derived client-side from the real /api/products/
    // list instead of the old dummy_product.dart data:
    //  - New Arrivals: first slice (API returns newest-id-first)
    //  - Most Popular: highest average_rating first
    //  - Special For You: the next slice after New Arrivals
    final allProducts = productViewModel.products;
    final realNewArrivals = allProducts.take(4).toList();
    final realMostPopular = [...allProducts]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final realSpecialForYou = allProducts.skip(4).take(4).toList();

    final filteredNewArrivals = _filtered(realNewArrivals);
    final filteredMostPopular = _filtered(realMostPopular.take(4).toList());
    final filteredSpecialForYou = _filtered(realSpecialForYou);
    final filteredBestSellers = _filtered(bestSellerViewModel.products);

    // Recently Viewed is REAL now — products the user actually opened
    // the detail page for (see RecentlyViewedViewModel), not the old
    // dummy_product.dart list.
    final realRecentlyViewed = recentlyViewedViewModel.products;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildBanner(),
            const SizedBox(height: 24),
            _buildCategories(),

            if (realRecentlyViewed.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Recently Viewed', onSeeAll: () => _openRecentlyViewed(realRecentlyViewed)),
              const SizedBox(height: 12),
              _buildRecentlyViewedCarousel(realRecentlyViewed),
            ],
            const SizedBox(height: 24),

            if (productViewModel.isLoading && allProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (productViewModel.error != null && allProducts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    Text(productViewModel.error!, style: const TextStyle(color: AppColors.textGrey), textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => productViewModel.fetchProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            if (filteredNewArrivals.isNotEmpty) ...[
              _buildSectionHeader('New Arrivals', onSeeAll: () => _openViewAll(
                pageTitle: 'New Arrivals',
                bannerColor: AppColors.success,
                bannerTitle: 'May Flash Sale\nSpecial Offer !',
                bannerSubtitle: 'Get your wishlist with the best\nprice only at the moment',
                showCountdown: true,
                showSoldBadge: true,
                sections: _splitIntoSections(realNewArrivals, 'Latest Deals', 'Other Flash Deals'),
              )),
              const SizedBox(height: 12),
              _buildProductGrid(filteredNewArrivals, showAddButton: true),
              const SizedBox(height: 24),
            ],

            // Best Seller Deals — banner, then the real product grid from
            // GET /api/products/bestseller/.
            _buildSectionHeader('Best Seller Deals', onSeeAll: () => _openBestSellerViewAll(bestSellerViewModel)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openBestSellerViewAll(bestSellerViewModel),
              child: _buildFeaturedBanner(),
            ),
            const SizedBox(height: 20),
            _buildBestSellerGrid(bestSellerViewModel, filteredBestSellers),
            const SizedBox(height: 24),

            if (filteredMostPopular.isNotEmpty) ...[
              _buildSectionHeader(
                'Most Popular',
                trailingTag: '12:03:25',
                onSeeAll: () => _openViewAll(
                  pageTitle: 'Our Popular Product',
                  bannerColor: AppColors.primaryBlue,
                  bannerTitle: 'Update About\nPopular Product',
                  bannerSubtitle: 'Stay update with out popular &\nhigh quality product',
                  sections: _splitIntoSections(realMostPopular, 'Popular This Week', 'Other Popular\'s Product'),
                ),
              ),
              const SizedBox(height: 12),
              _buildProductGrid(filteredMostPopular, showAddButton: false),
              const SizedBox(height: 24),
            ],

            if (filteredSpecialForYou.isNotEmpty) ...[
              _buildSectionHeader('Special For You', onSeeAll: () => _openViewAll(
                pageTitle: 'Special For You',
                bannerColor: const Color(0xFFEF6F5B),
                bannerTitle: 'Get Personalized\nDeals Now',
                bannerSubtitle: 'Get best product offer & deals\nbased on your interest',
                sections: _splitIntoSections(realSpecialForYou, 'Only For You', 'Other Special Offer'),
              )),
              const SizedBox(height: 12),
              _buildProductGrid(filteredSpecialForYou, showAddButton: false),
            ],

            if (filteredNewArrivals.isEmpty &&
                filteredMostPopular.isEmpty &&
                filteredSpecialForYou.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    'No products in this category yet',
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellerGrid(BestSellerViewModel viewModel, List<ProductModel> products) {
    if (viewModel.isLoading && products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (viewModel.error != null && products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text(viewModel.error!, style: const TextStyle(color: AppColors.textGrey), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.fetchBestSellers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (products.isEmpty) return const SizedBox.shrink();

    return _buildProductGrid(products, showAddButton: true);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.avatarBg,
            child: Icon(Icons.person, color: AppColors.textGrey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Happy Shopping',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_displayName !',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _iconWithBadge(Icons.shopping_cart_outlined, widget.onNavigateToCart),
          const SizedBox(width: 10),
          Consumer<NotificationViewModel>(
            builder: (context, notificationViewModel, _) => _iconWithBadge(
              Icons.notifications_none_rounded,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
              badgeCount: notificationViewModel.unreadCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconWithBadge(IconData icon, VoidCallback onTap, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 20, color: AppColors.textDark)),
            if (badgeCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: AppColors.badgeRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'May Flash Sale\nSpecial Offer !',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get your wishlist with the best price only at the moment',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onNavigateToShop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.success,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See More',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/images/shoe1.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.sports_gymnastics,
                  color: Colors.white70,
                  size: 70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Our Categories', onSeeAll: _openAllCategories),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final String value = _categories[index]['value']!;
              final String label = _categories[index]['label']!;
              final bool selected = value == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: AppColors.primaryBlue),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? trailingTag,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (trailingTag != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.blueTagBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 12, color: AppColors.primaryBlue),
                  const SizedBox(width: 3),
                  Text(
                    trailingTag,
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedCarousel(List<ProductModel> products) {
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _recentController,
            itemCount: products.length,
            onPageChanged: (i) => setState(() => _recentPage = i),
            itemBuilder: (context, index) => _recentlyViewedCard(products[index]),
          ),
        ),
        if (products.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(products.length, (i) {
              final bool active = i == _recentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryBlue : AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _recentlyViewedCard(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _productThumb(product.imagePath, size: 96),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: AppColors.star),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${product.rating} (${product.reviewCount ?? 0} reviews)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (product.oldPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${product.oldPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 96,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _favoriteButton(product.id, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products, {required bool showAddButton}) {
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
        itemBuilder: (context, index) => _productCard(products[index], showAddButton: showAddButton),
      ),
    );
  }

  Widget _productCard(ProductModel product, {required bool showAddButton}) {
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
                      if (showAddButton)
                        GestureDetector(
                          onTap: () => widget.onAddToCart(product),
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
    ),
    );
  }

  Widget _favoriteButton(String productId, {double size = 24, bool withBackground = false}) {
    final bool isFavorite = widget.favoriteIds.contains(productId);
    final icon = Icon(
      isFavorite ? Icons.favorite : Icons.favorite_border,
      size: size * 0.6,
      color: isFavorite ? AppColors.badgeRed : AppColors.textGrey,
    );

    return GestureDetector(
      onTap: () => widget.onToggleFavorite(productId),
      child: withBackground
          ? Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: icon,
            )
          : icon,
    );
  }

  /// Shared thumbnail for every product image on this screen (grid
  /// cards + Recently Viewed). Shows a spinner while a network image
  /// loads instead of a blank/broken box — this was the "weird
  /// looking" issue: real products carry full network URLs, and a
  /// plain Image.asset call can't render those at all.
  Widget _productThumb(String path, {double size = 60, double? height}) {
    final bool isNetworkImage = path.startsWith('http://') || path.startsWith('https://');

    return Container(
      width: size,
      height: height ?? size,
      color: AppColors.bgLight,
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size == double.infinity ? 0 : 12),
        child: path.isEmpty
            ? const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 28)
            : isNetworkImage
                ? Image.network(
                    path,
                    width: size,
                    height: height ?? size,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: (height ?? size) > 60 ? 26 : 18,
                          height: (height ?? size) > 60 ? 26 : 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.image_outlined,
                      color: AppColors.hintGrey,
                      size: 28,
                    ),
                  )
                : Image.asset(
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

  Widget _buildFeaturedBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 210,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBanner,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/shoe2.png'),
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            opacity: 0.35,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'FEATURED',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SUMMER '24 PERFORMANCE",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Beyond The Limit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Explore Collection',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 15),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}