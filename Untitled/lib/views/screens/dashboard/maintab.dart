import 'package:ecommerce_app/views/screens/cart/cart_screen.dart';
import 'package:ecommerce_app/views/screens/category/product_details_screen.dart';
import 'package:ecommerce_app/views/screens/favTab/fav.dart';
import 'package:ecommerce_app/views/screens/shope/shope_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/viewmodel/cart_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/favorites_viewmodel.dart';
import 'package:ecommerce_app/views/screens/dashboard/custom_bottom_nav.dart';
import 'package:ecommerce_app/views/screens/dashboard/homescreen.dart';
import 'package:ecommerce_app/views/screens/account/my_account_screen.dart';

/// Owns the active tab. Cart state lives in CartViewModel (real
/// /api/cart/ backend); favorites now live in FavoritesViewModel
/// (persisted locally via TokenStorage — see that file) instead of a
/// local Set here, so wishlisted items survive app close/reopen.
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFromStorage();
    });
  }

  void _onNavTap(int index) => setState(() => _currentIndex = index);

  void _toggleFavorite(String productId) {
    context.read<FavoritesViewModel>().toggleFavorite(productId);
  }

  // The real /api/cart/add/ endpoint requires a size AND color, which a
  // quick grid tap doesn't collect — so this opens the product page to
  // pick them, rather than sending a fake/default size and color.
  void _addToCart(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<CartViewModel>();
    final favoritesViewModel = context.watch<FavoritesViewModel>();
    final int cartBadgeCount =
        cartViewModel.items.fold<int>(0, (sum, item) => sum + item.quantity);

    final List<Widget> tabs = [
      HomeScreen(
        favoriteIds: favoritesViewModel.favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
        onNavigateToShop: () => setState(() => _currentIndex = 1), // jump to Shop
        onNavigateToCart: () => setState(() => _currentIndex = 2), // jump to Cart
      ),
      ShopScreen(
        favoriteIds: favoritesViewModel.favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
      ),
      CartScreen(
        onBrowseProducts: () => setState(() => _currentIndex = 1), // jump to Shop
        onGoToWishlist: () => setState(() => _currentIndex = 3), // jump to Favorites
      ),
      FavoritesScreen(
        favoriteIds: favoritesViewModel.favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onExploreWishlist: () => setState(() => _currentIndex = 1), // jump to Shop
      ),
      const MyAccountScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        cartCount: cartBadgeCount,
        favoritesCount: favoritesViewModel.favoriteIds.length,
      ),
    );
  }
}