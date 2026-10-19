class AdminProductImage {
  final int id;
  final String url;

  AdminProductImage({required this.id, required this.url});

  factory AdminProductImage.fromJson(Map<String, dynamic> json) => AdminProductImage(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        url: json['image']?.toString() ?? '',
      );
}

class AdminProductSize {
  final int id;
  final String size;

  AdminProductSize({required this.id, required this.size});

  factory AdminProductSize.fromJson(Map<String, dynamic> json) => AdminProductSize(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        size: json['size']?.toString() ?? '',
      );
}

class AdminProductColor {
  final int id;
  final String color;

  AdminProductColor({required this.id, required this.color});

  factory AdminProductColor.fromJson(Map<String, dynamic> json) => AdminProductColor(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        color: json['color']?.toString() ?? '',
      );
}

/// A single review, as it appears inside a product detail response's
/// `reviews` array. status is typically pending | approved | rejected.
class AdminProductReview {
  final int id;
  final String user;
  final int rating;
  final String comment;
  final String status;
  final String? adminReply;
  final String? rejectionReason;
  final DateTime? createdAt;

  AdminProductReview({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.status,
    this.adminReply,
    this.rejectionReason,
    this.createdAt,
  });

  AdminProductReview copyWith({String? status, String? adminReply, String? rejectionReason}) => AdminProductReview(
        id: id,
        user: user,
        rating: rating,
        comment: comment,
        status: status ?? this.status,
        adminReply: adminReply ?? this.adminReply,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        createdAt: createdAt,
      );

  factory AdminProductReview.fromJson(Map<String, dynamic> json) => AdminProductReview(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        user: json['user']?.toString() ?? '',
        rating: json['rating'] is int ? json['rating'] as int : int.tryParse('${json['rating']}') ?? 0,
        comment: json['comment']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        adminReply: json['admin_reply']?.toString(),
        rejectionReason: json['rejection_reason']?.toString(),
        createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      );
}

/// One model for both list items and the single-product detail
/// response — both carry the same shape (id, images, sizes, colors,
/// reviews, brand_name, category_name, name, description, gender,
/// price, discount_price, stock_quantity, status, is_featured...).
class AdminProductModel {
  final int id;
  final List<AdminProductImage> images;
  final List<AdminProductSize> sizes;
  final List<AdminProductColor> colors;
  final List<AdminProductReview> reviews;
  final String brandName;
  final String categoryName;
  final String? occasionName;
  final String name;
  final String description;
  final String gender;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final String status; // 'active' | 'inactive'
  final bool isFeatured;
  final DateTime? createdAt;

  AdminProductModel({
    required this.id,
    required this.images,
    required this.sizes,
    required this.colors,
    required this.reviews,
    required this.brandName,
    required this.categoryName,
    this.occasionName,
    required this.name,
    required this.description,
    required this.gender,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    required this.status,
    required this.isFeatured,
    this.createdAt,
  });

  String? get firstImageUrl => images.isNotEmpty ? images.first.url : null;
  int get reviewCount => reviews.length;

  AdminProductModel copyWith({bool? isFeatured, String? status, List<AdminProductReview>? reviews}) => AdminProductModel(
        id: id,
        images: images,
        sizes: sizes,
        colors: colors,
        reviews: reviews ?? this.reviews,
        brandName: brandName,
        categoryName: categoryName,
        occasionName: occasionName,
        name: name,
        description: description,
        gender: gender,
        price: price,
        discountPrice: discountPrice,
        stockQuantity: stockQuantity,
        status: status ?? this.status,
        isFeatured: isFeatured ?? this.isFeatured,
        createdAt: createdAt,
      );

  factory AdminProductModel.fromJson(Map<String, dynamic> json) {
    return AdminProductModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      images: (json['images'] as List? ?? []).map((e) => AdminProductImage.fromJson(e as Map<String, dynamic>)).toList(),
      sizes: (json['sizes'] as List? ?? []).map((e) => AdminProductSize.fromJson(e as Map<String, dynamic>)).toList(),
      colors: (json['colors'] as List? ?? []).map((e) => AdminProductColor.fromJson(e as Map<String, dynamic>)).toList(),
      reviews: (json['reviews'] as List? ?? []).map((e) => AdminProductReview.fromJson(e as Map<String, dynamic>)).toList(),
      brandName: json['brand_name']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      occasionName: json['occasion_name']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      discountPrice: json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null,
      stockQuantity: json['stock_quantity'] is int ? json['stock_quantity'] as int : int.tryParse('${json['stock_quantity']}') ?? 0,
      status: json['status']?.toString() ?? 'active',
      isFeatured: json['is_featured'] == true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}