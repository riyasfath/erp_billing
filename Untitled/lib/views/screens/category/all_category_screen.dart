import 'package:ecommerce_app/views/screens/category/category_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/category_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/viewmodel/category_viewmodel.dart';
import 'package:ecommerce_app/viewmodel/product_viewmodel.dart';

/// "All Categories" page — reached from Home > Our Categories > See All.
/// Upgraded layout: full-bleed image cards with a gradient scrim, the
/// category name + product count overlaid on the photo, and a soft
/// elevated look. Every value shown (name, count, thumbnail) still comes
/// straight from the API — no invented icons, colors, or hero banners.
class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
      context.read<ProductViewModel>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryViewModel = context.watch<CategoryViewModel>();
    final productViewModel = context.watch<ProductViewModel>();
    final allProducts = productViewModel.products;

    final List<CategoryModel> categoryModels = categoryViewModel.categories
        .map((c) => CategoryModel.fromApi(c, allProducts))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, categoryModels.length),
            Expanded(child: _buildBody(categoryViewModel, categoryModels, allProducts)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.3),
                ),
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$count categories to explore',
                      style: const TextStyle(fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    CategoryViewModel categoryViewModel,
    List<CategoryModel> categoryModels,
    List<ProductModel> allProducts,
  ) {
    if (categoryViewModel.isLoading && categoryModels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (categoryViewModel.error != null && categoryModels.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(categoryViewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => categoryViewModel.fetchCategories(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }
    if (categoryModels.isEmpty) {
      return const Center(child: Text('No categories found', style: TextStyle(color: AppColors.textGrey)));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: categoryModels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _FadeSlideIn(
        index: index,
        child: _categoryCard(context, categoryModels[index], allProducts),
      ),
    );
  }

  Widget _categoryCard(BuildContext context, CategoryModel category, List<ProductModel> allProducts) {
    final products = allProducts
        .where((p) => p.categoryName.toLowerCase() == category.filterValue)
        .toList();

    // Card footprint stays the same as before (152 tall); only the photo
    // inside it is now a smaller, inset square instead of a full-bleed fill.
    return _PressableScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryProductsScreen(category: category, products: products)),
      ),
      child: Container(
        height: 152,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Smaller, inset image — its own rounded box, not stretched to the card
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 108,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _thumb(category.heroImage),
                    // subtle scrim so a bottom label would stay legible if ever added
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.7, 1.0],
                          colors: [Colors.transparent, Color(0x33000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${category.productCount} items',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                    ),
                  ),
                  Text(
                    category.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: 0.2,
                      height: 1.15,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Shop now',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 32),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AppColors.bgLight,
          alignment: Alignment.center,
          child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        color: AppColors.bgLight,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.hintGrey, size: 32),
      ),
    );
  }
}

/// Wraps a card so it visibly "presses" (scales + dims slightly) on tap,
/// giving the list a more tactile, premium feel than a flat InkWell.
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Small staggered fade + slide-in as each row appears.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;

  const _FadeSlideIn({required this.child, required this.index});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}