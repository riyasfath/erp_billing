/// One review from a product's `reviews` array.
class ReviewModel {
  final int id;
  final String user;
  final int rating;
  final String comment;
  final String? adminReply;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    this.adminReply,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      user: json['user']?.toString() ?? 'Anonymous',
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
      adminReply: json['admin_reply']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

/// Full detail for one product — GET /api/products/{id}/. Separate from
/// the lighter ProductModel used in list/grid views, since the detail
/// endpoint returns description, all images, sizes, colors, reviews,
/// and specification fields that the list endpoint doesn't.
class ProductDetailModel {
  final String id;
  final String name;
  final String description;
  final String brand;
  final double price; // price actually charged (discounted if any)
  final double? oldPrice; // original price, struck-through, if discounted
  final double rating;
  final int reviewCount;
  final String? badge;
  final List<String> images; // full URLs
  final List<String> sizes;
  final List<String> colors;
  final List<ReviewModel> reviews;
  final int stockQuantity;
  final bool isInWishlist;
  final String category; // men/women/kids, from `gender`

  // --- Specifications / key highlights — every field is nullable
  // since the confirmed sample had them all as `null`; only render a
  // spec row when it's actually present. ---
  final String? materialType;
  final String? soleType;
  final String? heelHeight;
  final String? careInstructions;
  final String? fitType;

  ProductDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.brand,
    required this.price,
    this.oldPrice,
    required this.rating,
    required this.reviewCount,
    this.badge,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.reviews,
    required this.stockQuantity,
    required this.isInWishlist,
    required this.category,
    this.materialType,
    this.soleType,
    this.heelHeight,
    this.careInstructions,
    this.fitType,
  });

  /// First image, or '' if there are none — for a fallback single-image
  /// header while callers don't want the full carousel.
  String get imagePath => images.isNotEmpty ? images.first : '';

  /// True when at least one specification field is present — lets the
  /// UI skip rendering an empty "Specifications" section entirely.
  bool get hasSpecifications =>
      materialType != null ||
      soleType != null ||
      heelHeight != null ||
      careInstructions != null ||
      fitType != null;

  factory ProductDetailModel.fromApiJson(Map<String, dynamic> json) {
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

    final int reviewCount = json['reviews_count'] is int
        ? json['reviews_count'] as int
        : int.tryParse(json['reviews_count']?.toString() ?? '') ?? 0;

    final int stock = json['stock_quantity'] is int
        ? json['stock_quantity'] as int
        : int.tryParse(json['stock_quantity']?.toString() ?? '') ?? 0;

    final List<dynamic> imagesJson = (json['images'] as List?) ?? [];
    final List<String> images = imagesJson
        .map((e) => e['image']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    final List<dynamic> sizesJson = (json['sizes'] as List?) ?? [];
    final List<String> sizes =
        sizesJson.map((e) => e['size']?.toString() ?? '').toList();

    final List<dynamic> colorsJson = (json['colors'] as List?) ?? [];
    final List<String> colors =
        colorsJson.map((e) => e['color']?.toString() ?? '').toList();

    final List<dynamic> reviewsJson = (json['reviews'] as List?) ?? [];
    final List<ReviewModel> reviews = reviewsJson
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Non-empty, non-"null"-string helper — the sample had these as
    // real JSON null, but guards against a stray empty string too.
    String? cleanSpec(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return ProductDetailModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      brand: json['brand_name']?.toString() ?? '',
      price: hasDiscount ? discountPrice : originalPrice,
      oldPrice: hasDiscount ? originalPrice : null,
      rating: rating,
      reviewCount: reviewCount,
      badge: badge,
      images: images,
      sizes: sizes,
      colors: colors,
      reviews: reviews,
      stockQuantity: stock,
      isInWishlist: json['is_in_wishlist'] == true,
      category: (json['gender']?.toString() ?? 'all').toLowerCase(),
      materialType: cleanSpec(json['material_type']),
      soleType: cleanSpec(json['sole_type']),
      heelHeight: cleanSpec(json['heel_height']),
      careInstructions: cleanSpec(json['care_instructions']),
      fitType: cleanSpec(json['fit_type']),
    );
  }
}