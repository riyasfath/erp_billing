import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/products/create_product.dart';
import 'package:pokakbilling/views/Screens/products/single_product_tile.dart';
import 'package:provider/provider.dart';

class ProductMainScreen extends StatefulWidget {
  const ProductMainScreen({super.key});

  @override
  State<ProductMainScreen> createState() => _ProductMainScreenState();
}

class _ProductMainScreenState extends State<ProductMainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Pagination state
  int currentPage = 1;
  static const int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_fadeAnim);

    _animCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = Provider.of<ProductViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.productList.isEmpty && !provider.getProductLoader) {
        provider.getAllProducts();
      }
      if (provider.selectedProductId != 0) {
        provider.getProductById(provider.selectedProductId);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(context, topPad, sw),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double topPad, double sw) {
    return Consumer<ProductViewModel>(
      builder: (context, p, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPad + 8,
            bottom: 13,
            left: sw * 0.045,
            right: sw * 0.045,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.cborder, width: 1.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Products',
                          style: TextStyle(
                            color: AppColors.cdark,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${p.productList.length} products available',
                          style: const TextStyle(
                            color: AppColors.ctext,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // New product button
                  GestureDetector(
                    onTap: () => pushNavigation(
                      context,
                      const AddProduct(isEdit: false),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.c1.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded,
                              color: AppColors.white, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'New',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search_rounded,
                        color: AppColors.ctext, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => p.searchProducts(value),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.cdark,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: AppColors.ctext,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return Consumer<ProductViewModel>(
      builder: (context, provider, child) {
        if (provider.getProductLoader || provider.singleProductLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.c1,
              strokeWidth: 2.5,
            ),
          );
        }

        // Single product view
        if (provider.selectedProductId != 0 &&
            provider.singleProductList.isNotEmpty) {
          final product = provider.singleProductList.first;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildListHeader(1),
              _StaggeredItem(
                delay: const Duration(milliseconds: 60),
                child: _ProductCardWrapper(
                  child: SingleProductTile(
                    index: provider.productList.indexWhere(
                      (p) => p.productId == product.productId,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // Empty state
        if (provider.productList.isEmpty) {
          return _buildEmptyState();
        }

        // Paginated list
        final visibleProducts = _getVisibleProducts(provider);
        final totalPages = (provider.productList.length / itemsPerPage).ceil();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            _buildListHeader(visibleProducts.length),
            ...visibleProducts.asMap().entries.map((entry) {
              final i = entry.key;
              return _StaggeredItem(
                delay: Duration(milliseconds: 40 + i * 50),
                child: _ProductCardWrapper(
                  child: SingleProductTile(index: i),
                ),
              );
            }).toList(),
            if (totalPages > 1) _buildPagination(provider.productList.length),
          ],
        );
      },
    );
  }

  List _getVisibleProducts(ProductViewModel provider) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, provider.productList.length);
    return provider.productList.sublist(startIndex, endIndex);
  }

  // ── Pagination ────────────────────────────────────────────────────────────
  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    final startItem = (currentPage - 1) * itemsPerPage + 1;
    final endItem = (currentPage * itemsPerPage).clamp(0, totalItems);

    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Showing $startItem-$endItem of $totalItems products',
            style: const TextStyle(
              color: AppColors.ctext,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              GestureDetector(
                onTap: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: currentPage > 1 ? AppColors.c1 : AppColors.cxl,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentPage > 1 ? AppColors.c1 : AppColors.cborder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 16,
                        color:
                            currentPage > 1 ? AppColors.white : AppColors.ctext,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Previous',
                        style: TextStyle(
                          color: currentPage > 1
                              ? AppColors.white
                              : AppColors.ctext,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Page numbers
              ...List.generate(totalPages, (index) {
                final page = index + 1;
                final isActive = page == currentPage;
                return GestureDetector(
                  onTap: () => setState(() => currentPage = page),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.c1 : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.c1 : AppColors.cborder,
                      ),
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: isActive ? AppColors.white : AppColors.cdark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 12),

              // Next button
              GestureDetector(
                onTap: currentPage < totalPages
                    ? () => setState(() => currentPage++)
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        currentPage < totalPages ? AppColors.c1 : AppColors.cxl,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentPage < totalPages
                          ? AppColors.c1
                          : AppColors.cborder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          color: currentPage < totalPages
                              ? AppColors.white
                              : AppColors.ctext,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: currentPage < totalPages
                            ? AppColors.white
                            : AppColors.ctext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── List header ───────────────────────────────────────────────────────────
  Widget _buildListHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          const Text(
            'ALL PRODUCTS',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.ctext,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.cl,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cborder),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.cdark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.c1,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Products Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cdark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap "New" to add your first product',
            style: TextStyle(fontSize: 13, color: AppColors.ctext),
          ),
        ],
      ),
    );
  }
}

// ─── Card Wrapper ─────────────────────────────────────────────────────────────
class _ProductCardWrapper extends StatelessWidget {
  final Widget child;
  const _ProductCardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Staggered animation ──────────────────────────────────────────────────────
class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _StaggeredItem({required this.child, required this.delay});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(_fade);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
