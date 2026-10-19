double _rAsDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
int _rAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _rAsDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
const String _rMediaBase = 'http://93.127.167.39:8060';

class AdminReturnModel {
  final int id;
  final String returnId;
  final String orderId;
  final String customerName;
  final String customerEmail;
  final String productName;
  final String? productImage;
  final double productPrice;
  final String productSize;
  final String productColor;
  final String reason;
  final String comment;
  final String status;
  final double refundAmount;
  final DateTime? createdAt;
  final String? rejectionCategory;
  final String? rejectionReason;
  final DateTime? refundedAt;

  AdminReturnModel({
    required this.id,
    required this.returnId,
    required this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.productName,
    this.productImage,
    required this.productPrice,
    required this.productSize,
    required this.productColor,
    required this.reason,
    required this.comment,
    required this.status,
    required this.refundAmount,
    this.createdAt,
    this.rejectionCategory,
    this.rejectionReason,
    this.refundedAt,
  });

  String? get imageUrl {
    if (productImage == null || productImage!.isEmpty) return null;
    return productImage!.startsWith('http') ? productImage : '$_rMediaBase$productImage';
  }

  factory AdminReturnModel.fromJson(Map<String, dynamic> json) => AdminReturnModel(
        id: _rAsInt(json['id']),
        returnId: json['return_id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        customerName: json['customer_name']?.toString() ?? '',
        customerEmail: json['customer_email']?.toString() ?? '',
        productName: json['product_name']?.toString() ?? '',
        productImage: json['product_image']?.toString(),
        productPrice: _rAsDouble(json['product_price']),
        productSize: json['product_size']?.toString() ?? '',
        productColor: json['product_color']?.toString() ?? '',
        reason: json['reason']?.toString() ?? '',
        comment: json['comment']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        refundAmount: _rAsDouble(json['refund_amount']),
        createdAt: _rAsDate(json['created_at']),
        rejectionCategory: json['rejection_category']?.toString(),
        rejectionReason: json['rejection_reason']?.toString(),
        refundedAt: _rAsDate(json['refunded_at']),
      );
}