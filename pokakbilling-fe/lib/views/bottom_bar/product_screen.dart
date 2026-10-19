import 'package:flutter/material.dart';
import 'package:pokakbilling/ERP_UI_KIT.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/viewmodels/product_viewmodel.dart';
import 'package:pokakbilling/views/Screens/products/create_product.dart';
import 'package:pokakbilling/views/Screens/products/single_product_tile.dart';
import 'package:provider/provider.dart';

const int _kPageSize = 10;

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;

  void _resetPage() {
    if (_currentPage != 0) setState(() => _currentPage = 0);
  }

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
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
      _resetPage();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().getAllProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: ErpColors.pageBg,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Consumer<ProductViewModel>(
              builder: (context, provider, _) {
                return _buildHeader(
                  context,
                  topPad,
                  sw,
                  provider.productList.length,
                );
              },
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    int count,
  ) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ErpColors.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -44,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 104,
            top: topPad + 2,
            child: Transform.rotate(
              angle: -0.25,
              child: Icon(Icons.inventory_2_rounded,
                  size: 86, color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          Positioned(
            left: -26,
            bottom: -34,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: topPad + 14,
              bottom: 20,
              left: sw * 0.045,
              right: sw * 0.045,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Products',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            )),
                        const SizedBox(height: 2),
                        Text(
                            '$count product${count != 1 ? 's' : ''} available',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14)),
                      ],
                    ),
                  ),

                  // ── NEW button ────────────────────────────────────────
                  ErpPressable(
                    onTap: () => pushNavigation(
                      context,
                      const AddProduct(isEdit: false),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: ErpColors.cyanDeep.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              color: ErpColors.cyanDeep, size: 18),
                          SizedBox(width: 4),
                          Text('New',
                              style: TextStyle(
                                  color: ErpColors.cyanDeep,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                // Search bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ErpColors.cyanDeep.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ErpColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.search_rounded,
                          color: ErpColors.cyanDeep, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        cursorColor: ErpColors.cyan,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ErpColors.ink,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search products…',
                          hintStyle: TextStyle(
                              color: ErpColors.slate.withValues(alpha: 0.7),
                              fontSize: 13.5),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      ErpPressable(
                        onTap: () {
                          _searchController.clear();
                          _resetPage();
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: ErpColors.slate.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 15, color: ErpColors.slate),
                        ),
                      ),
                    const SizedBox(width: 4),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────────────────────
  Widget _buildBody() => Consumer<ProductViewModel>(
        builder: (context, provider, _) {
          if (provider.getProductLoader) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: ErpColors.cyan,
                  strokeWidth: 2.5,
                ),
              ),
            );
          }

          if (provider.productList.isEmpty) {
            return _buildEmptyState('No products available.', provider);
          }

          final matchedIndexes = _query.trim().isEmpty
              ? List.generate(provider.productList.length, (i) => i)
              : provider.productList
                  .asMap()
                  .entries
                  .where((e) => e.value.productName
                      .toLowerCase()
                      .contains(_query.trim().toLowerCase()))
                  .map((e) => e.key)
                  .toList();

          if (matchedIndexes.isEmpty) {
            return _buildEmptyState('No products found.', provider);
          }

          final int totalCount = matchedIndexes.length;
          final bool paginate = totalCount > _kPageSize;
          final int totalPages =
              paginate ? (totalCount / _kPageSize).ceil() : 1;
          final int safePage = _currentPage.clamp(0, totalPages - 1);
          final int startIndex = safePage * _kPageSize;
          final int endIndex = (startIndex + _kPageSize).clamp(0, totalCount);
          final List<int> pageIndexes =
              matchedIndexes.sublist(startIndex, endIndex);
          final sw = MediaQuery.of(context).size.width;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── List header pill ────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(sw * 0.045, 18, sw * 0.045, 10),
                child: Row(children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [ErpColors.cyanLight, ErpColors.cyanDeep],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: ErpColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: ErpColors.headerGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCount',
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  if (paginate)
                    Text(
                      '${startIndex + 1}–$endIndex of $totalCount',
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: ErpColors.slate),
                    ),
                ]),
              ),

              // ── List ──────────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: ErpColors.cyan,
                  onRefresh: () => provider.getAllProducts(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.fromLTRB(
                        sw * 0.04, 0, sw * 0.04, paginate ? 8 : 24),
                    itemCount: pageIndexes.length,
                    itemBuilder: (context, i) {
                      final originalIndex = pageIndexes[i];
                      return ErpFadeIn(
                        key: ValueKey('p_${safePage}_$originalIndex'),
                        index: i,
                        child: _ProductCardWrapper(
                          child: SingleProductTile(index: originalIndex),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Pagination bar ───────────────────────────────────────
              if (paginate)
                Padding(
                  padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, 16),
                  child: _buildPaginationBar(safePage, totalPages),
                ),
            ],
          );
        },
      );

  // ── PAGINATION BAR ──────────────────────────────────────────────────────
  Widget _buildPaginationBar(int currentPage, int totalPages) {
    final bool canPrev = currentPage > 0;
    final bool canNext = currentPage < totalPages - 1;

    final Set<int> visibleSet = {0, totalPages - 1, currentPage};
    if (currentPage - 1 >= 0) visibleSet.add(currentPage - 1);
    if (currentPage + 1 < totalPages) visibleSet.add(currentPage + 1);
    final List<int> sorted = visibleSet.toList()..sort();

    final List<int> tokens = [];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) tokens.add(-1);
      tokens.add(sorted[i]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pageNavBtn(
            label: 'Prev',
            icon: Icons.chevron_left_rounded,
            iconLeft: true,
            enabled: canPrev,
            onTap: () => setState(() => _currentPage = currentPage - 1),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: tokens.map((t) {
              if (t == -1) {
                return Container(
                  width: 26,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  child: const Text('…',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: ErpColors.slate)),
                );
              }
              final bool active = t == currentPage;
              return GestureDetector(
                onTap: () => setState(() => _currentPage = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 34 : 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: active ? ErpColors.headerGradient : null,
                    color: active ? null : ErpColors.pageBg,
                    borderRadius: BorderRadius.circular(10),
                    border: active ? null : Border.all(color: ErpColors.line),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: ErpColors.cyan.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : const [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${t + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: active ? Colors.white : ErpColors.slate,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          _pageNavBtn(
            label: 'Next',
            icon: Icons.chevron_right_rounded,
            iconLeft: false,
            enabled: canNext,
            onTap: () => setState(() => _currentPage = currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _pageNavBtn({
    required String label,
    required IconData icon,
    required bool iconLeft,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final Color color =
        enabled ? ErpColors.cyanDeep : ErpColors.slate.withValues(alpha: 0.5);
    final Color bg =
        enabled ? ErpColors.cyan.withValues(alpha: 0.12) : ErpColors.pageBg;

    return ErpPressable(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: enabled
                  ? ErpColors.cyan.withValues(alpha: 0.30)
                  : ErpColors.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (iconLeft) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 2),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
          if (!iconLeft) ...[
            const SizedBox(width: 2),
            Icon(icon, size: 16, color: color),
          ],
        ]),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(String message, ProductViewModel provider) {
    return RefreshIndicator(
      color: ErpColors.cyan,
      onRefresh: () => provider.getAllProducts(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          const SizedBox(height: 60),
          ErpEmptyState(
            icon: Icons.inventory_2_rounded,
            title: message,
            subtitle: 'Try a different search or refresh.',
            actionLabel: 'Add Product',
            actionIcon: Icons.add_rounded,
            onAction: () =>
                pushNavigation(context, const AddProduct(isEdit: false)),
          ),
        ],
      ),
    );
  }
}

// ─── Card wrapper ─────────────────────────────────────────────────────────────
class _ProductCardWrapper extends StatelessWidget {
  final Widget child;
  const _ProductCardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ErpColors.line),
        boxShadow: [
          BoxShadow(
            color: ErpColors.cyan.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ErpColors.cyanDeep,
                  ErpColors.cyan,
                  ErpColors.cyanLight
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}