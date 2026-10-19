import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/product_model.dart';

/// Sort options shared between the Shop screen's "Sort by" row and this
/// sheet, so they never drift out of sync.
const List<String> kSortOptions = [
  'Recommended',
  'Most Popular',
  'Newest Arrivals',
  'Price: Low to High',
  'Price: High to Low',
];

/// The result of the Filters sheet — every field here maps to a real
/// field on [ProductModel]. There is deliberately no size/colorway
/// filter: the list/grid API (`ProductModel`) doesn't carry per-product
/// size or color data (only the detail endpoint does), so a filter for
/// it would have nothing real to filter against.
class ShopFilters {
  final String? categoryName; // null = no category filter ('ALL')
  final String sortBy;
  final RangeValues priceRange;
  final Set<String> brands; // empty = no brand filter
  final double? minRating; // null = no rating filter
  final bool inStockOnly;

  const ShopFilters({
    this.categoryName,
    this.sortBy = 'Recommended',
    required this.priceRange,
    this.brands = const {},
    this.minRating,
    this.inStockOnly = false,
  });

  /// A filter state that excludes nothing — used as the initial state
  /// before the user has touched the sheet.
  factory ShopFilters.initial() => const ShopFilters(
        priceRange: RangeValues(0, 100000),
      );

  bool get isDefault =>
      categoryName == null &&
      sortBy == 'Recommended' &&
      brands.isEmpty &&
      minRating == null &&
      inStockOnly == false;

  ShopFilters copyWith({
    String? categoryName,
    bool clearCategoryName = false,
    String? sortBy,
    RangeValues? priceRange,
    Set<String>? brands,
    double? minRating,
    bool clearMinRating = false,
    bool? inStockOnly,
  }) {
    return ShopFilters(
      categoryName: clearCategoryName ? null : (categoryName ?? this.categoryName),
      sortBy: sortBy ?? this.sortBy,
      priceRange: priceRange ?? this.priceRange,
      brands: brands ?? this.brands,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }
}

/// The "Filters" panel opened from the Shop tab's filter icon.
/// [products] is the full, unfiltered product list currently loaded —
/// used only to compute real option lists (distinct category names,
/// distinct brands with real counts, actual min/max price). Nothing in
/// this sheet is hardcoded sample data.
class FilterBottomSheet extends StatefulWidget {
  final List<ProductModel> products;
  final ShopFilters initialFilters;

  /// Both params are optional (with const-safe defaults) so any
  /// existing call site that still does `const FilterBottomSheet()`
  /// keeps compiling. Prefer passing the real, currently-loaded
  /// product list and the screen's current filters explicitly wherever
  /// possible — without [products] the sheet has nothing real to
  /// compute category/brand/price options from and will show empty
  /// option lists.
  const FilterBottomSheet({
    super.key,
    this.products = const [],
    this.initialFilters = const ShopFilters(priceRange: RangeValues(0, 100000)),
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _categoryName = widget.initialFilters.categoryName;
  late String _sortBy = widget.initialFilters.sortBy;
  late RangeValues _priceRange = widget.initialFilters.priceRange;
  late Set<String> _brands = {...widget.initialFilters.brands};
  late double? _minRating = widget.initialFilters.minRating;
  late bool _inStockOnly = widget.initialFilters.inStockOnly;

  late final double _minPossiblePrice;
  late final double _maxPossiblePrice;
  late final List<String> _categoryOptions;
  late final Map<String, int> _brandCounts;

  static const List<double> _ratingThresholds = [4.5, 4.0, 3.5, 3.0];

  @override
  void initState() {
    super.initState();

    final prices = widget.products.map((p) => p.price).toList();
    _minPossiblePrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
    _maxPossiblePrice = prices.isEmpty ? 1000 : prices.reduce((a, b) => a > b ? a : b);

    // Clamp the incoming range to what's actually possible right now,
    // in case the loaded product list has shrunk/changed since the
    // filter was last applied.
    _priceRange = RangeValues(
      _priceRange.start.clamp(_minPossiblePrice, _maxPossiblePrice),
      _priceRange.end.clamp(_minPossiblePrice, _maxPossiblePrice),
    );

    final Set<String> categories = {
      for (final p in widget.products)
        if (p.categoryName.isNotEmpty) p.categoryName,
    };
    _categoryOptions = categories.toList()..sort();

    final Map<String, int> counts = {};
    for (final p in widget.products) {
      if (p.brand.isEmpty) continue;
      counts[p.brand] = (counts[p.brand] ?? 0) + 1;
    }
    _brandCounts = counts;
    // Drop any previously-selected brand that no longer exists in the
    // current product list.
    _brands = _brands.where(_brandCounts.containsKey).toSet();
  }

  void _clearAll() {
    setState(() {
      _categoryName = null;
      _sortBy = 'Recommended';
      _priceRange = RangeValues(_minPossiblePrice, _maxPossiblePrice);
      _brands = {};
      _minRating = null;
      _inStockOnly = false;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      ShopFilters(
        categoryName: _categoryName,
        sortBy: _sortBy,
        priceRange: _priceRange,
        brands: _brands,
        minRating: _minRating,
        inStockOnly: _inStockOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                child: Row(
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_categoryOptions.isNotEmpty) ...[
                        _sectionTitle('CATEGORY'),
                        _chipRow(
                          ['ALL', ..._categoryOptions],
                          _categoryName ?? 'ALL',
                          (v) => setState(() => _categoryName = v == 'ALL' ? null : v),
                        ),
                        const SizedBox(height: 24),
                      ],

                      _sectionTitle('SORT BY'),
                      _chipRow(kSortOptions, _sortBy, (v) => setState(() => _sortBy = v)),
                      const SizedBox(height: 24),

                      _sectionTitle('PRICE RANGE'),
                      Text(
                        'Selected: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: _minPossiblePrice,
                        max: _maxPossiblePrice > _minPossiblePrice ? _maxPossiblePrice : _minPossiblePrice + 1,
                        divisions: 20,
                        activeColor: AppColors.primaryBlue,
                        inactiveColor: AppColors.borderGrey,
                        labels: RangeLabels(
                          '\$${_priceRange.start.round()}',
                          '\$${_priceRange.end.round()}',
                        ),
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${_minPossiblePrice.round()}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                          Text('\$${_maxPossiblePrice.round()}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (_brandCounts.isNotEmpty) ...[
                        _sectionTitle('BRANDS'),
                        ..._brandCounts.entries.map((entry) {
                          final selected = _brands.contains(entry.key);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _brands.add(entry.key);
                                } else {
                                  _brands.remove(entry.key);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            activeColor: AppColors.primaryBlue,
                            title: Text('${entry.key} (${entry.value})', style: const TextStyle(fontSize: 14)),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],

                      _sectionTitle('MINIMUM RATING'),
                      _chipRow(
                        ['Any', ..._ratingThresholds.map((r) => '$r+')],
                        _minRating == null ? 'Any' : '$_minRating+',
                        (v) => setState(() => _minRating = v == 'Any' ? null : double.parse(v.replaceAll('+', ''))),
                        starPrefix: true,
                      ),
                      const SizedBox(height: 24),

                      _sectionTitle('AVAILABILITY'),
                      CheckboxListTile(
                        value: _inStockOnly,
                        onChanged: (v) => setState(() => _inStockOnly = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeColor: AppColors.primaryBlue,
                        title: const Text('In Stock Only', style: TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Apply Filters — pinned to the bottom of the sheet
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Clear All', style: TextStyle(color: AppColors.textGrey)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textGrey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _chipRow(List<String> options, String selectedValue, ValueChanged<String> onSelect, {bool starPrefix = false}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final bool selected = option == selectedValue;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.borderGrey),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (starPrefix && option != 'Any') ...[
                  Icon(Icons.star, size: 13, color: selected ? Colors.white : AppColors.star),
                  const SizedBox(width: 4),
                ],
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}