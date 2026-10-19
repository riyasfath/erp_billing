int? _rAsIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

int _rAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

/// One entry from GET /api/products/reviews/my/ — the signed-in user's
/// own review history. Shape wasn't confirmed with a filled sample, so
/// this reads defensively across the common field-name variants a
/// Django serializer would use (e.g. `product` as a raw id vs a nested
/// object with `id`/`name`/`image`).
class MyProductReviewModel {
  final int id;
  final int? productId;
  final String? productName;
  final String? productImage;
  final int rating;
  final String comment;
  final String? status;
  final String? adminReply;
  final DateTime? createdAt;

  MyProductReviewModel({
    required this.id,
    this.productId,
    this.productName,
    this.productImage,
    required this.rating,
    required this.comment,
    this.status,
    this.adminReply,
    this.createdAt,
  });

  factory MyProductReviewModel.fromJson(Map<String, dynamic> json) {
    final dynamic productField = json['product'];
    int? productId;
    String? productName;
    String? productImage;

    if (productField is Map<String, dynamic>) {
      productId = _rAsIntOrNull(productField['id']);
      productName = productField['name']?.toString();
      productImage = productField['image']?.toString();
    } else {
      productId = _rAsIntOrNull(productField);
      productName = json['product_name']?.toString();
      productImage = json['product_image']?.toString();
    }

    return MyProductReviewModel(
      id: _rAsInt(json['id']),
      productId: productId,
      productName: productName,
      productImage: productImage,
      rating: _rAsInt(json['rating']),
      comment: json['comment']?.toString() ?? '',
      status: json['status']?.toString(),
      adminReply: json['admin_reply']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}