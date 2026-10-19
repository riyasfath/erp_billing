/// Data model for a single product/shoe card used across
/// Home, Search, and Detail screens.
class ProductModel {
  final String id;
  final String name;
  final String brand;
  final double price; // price actually shown/charged (discounted if any)
  final double? oldPrice; // original price, shown struck-through, if discounted
  final double rating;
  final int? reviewCount;
  final String? badge;
  final String imagePath; // asset path OR a full network URL (see isNetworkImage)
  final String category; // 'all' | 'men' | 'women' | 'kids' — from `gender`
  final String categoryName; // e.g. 'Athletic', 'Casual' — from `category_name`
  final int? soldCount; // for "28/30 Sold" style badges
  final int? totalStock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.rating,
    this.reviewCount,
    this.badge,
    required this.imagePath,
    this.category = 'all',
    this.categoryName = '',
    this.soldCount,
    this.totalStock,
  });

  /// True when [imagePath] is a real URL from the API (use Image.network)
  /// rather than a local asset (use Image.asset).
  bool get isNetworkImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  /// Parses one item from GET /api/products/ `results`. Field mapping:
  /// - `price` = original price, `discount_price` = actual selling price
  ///   when it's lower than `price` — so the model's `price` is whichever
  ///   one the customer actually pays, and `oldPrice` is the struck-through
  ///   original (null when there's no real discount).
  /// - `gender` ("Men" / "kids" / ...) becomes the men/women/kids
  ///   `category` filter, lowercased for consistent matching.
  /// - `images[0].image` becomes `imagePath` (a full URL) when present.
  /// - `badge` is derived: is_new -> 'New', is_featured -> 'Featured',
  ///   else a genuine discount -> '<percent>% OFF'. Adjust the priority
  ///   here if you want different badge rules.
  factory ProductModel.fromApiJson(Map<String, dynamic> json) {
    final double originalPrice =
        double.tryParse(json['price']?.toString() ?? '') ?? 0;
    final double? discountPrice = json['discount_price'] != null
        ? double.tryParse(json['discount_price'].toString())
        : null;
    final bool hasDiscount =
        discountPrice != null && discountPrice < originalPrice;

    final int discountPercentage = json['discount_percentage'] is int
        ? json['discount_percentage'] as int
        : int.tryParse(json['discount_percentage']?.toString() ?? '') ?? 0;

    final List<dynamic> images = (json['images'] as List?) ?? [];
    final String? firstImageUrl =
        images.isNotEmpty ? images.first['image']?.toString() : null;

    String? badge;
    if (json['is_new'] == true) {
      badge = 'New';
    } else if (json['is_featured'] == true) {
      badge = 'Featured';
    } else if (hasDiscount && discountPercentage > 0) {
      badge = '$discountPercentage% OFF';
    }

    final double rating = json['average_rating'] is num
        ? (json['average_rating'] as num).toDouble()
        : double.tryParse(json['average_rating']?.toString() ?? '') ?? 0;

    final int? reviewCount = json['reviews_count'] is int
        ? json['reviews_count'] as int
        : int.tryParse(json['reviews_count']?.toString() ?? '');

    final int? stock = json['stock_quantity'] is int
        ? json['stock_quantity'] as int
        : int.tryParse(json['stock_quantity']?.toString() ?? '');

    return ProductModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      brand: json['brand_name']?.toString() ?? '',
      price: hasDiscount ? discountPrice : originalPrice,
      oldPrice: hasDiscount ? originalPrice : null,
      rating: rating,
      reviewCount: reviewCount,
      badge: badge,
      imagePath: firstImageUrl ?? '',
      category: (json['gender']?.toString() ?? 'all').toLowerCase(),
      categoryName: json['category_name']?.toString() ?? '',
      soldCount: null, // not provided by this endpoint
      totalStock: stock,
    );
  }

  /// Local/dummy-data shape — kept for existing sample data
  /// (dummy_product.dart) that isn't coming from the API.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      price: (json['price'] as num).toDouble(),
      oldPrice: json['oldPrice'] != null
          ? (json['oldPrice'] as num).toDouble()
          : null,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int?,
      badge: json['badge'] as String?,
      imagePath: json['imagePath'] as String,
      category: json['category'] as String? ?? 'all',
      soldCount: json['soldCount'] as int?,
      totalStock: json['totalStock'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'badge': badge,
      'imagePath': imagePath,
      'category': category,
      'soldCount': soldCount,
      'totalStock': totalStock,
    };
  }
}

/// One page of GET /api/products/ — the list plus the URL to fetch the
/// next page (null when there isn't one).
class ProductPageResult {
  final List<ProductModel> products;
  final String? nextUrl;
  final int count;

  ProductPageResult({
    required this.products,
    required this.nextUrl,
    required this.count,
  });
}