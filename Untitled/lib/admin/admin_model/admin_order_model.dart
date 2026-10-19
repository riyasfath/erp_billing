const String _mediaBase = 'http://93.127.167.39:8060';

String? _fullImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  return path.startsWith('http') ? path : '$_mediaBase$path';
}

double _asDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _asDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

class AdminOrderAddress {
  final int id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;

  AdminOrderAddress({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory AdminOrderAddress.fromJson(Map<String, dynamic> json) => AdminOrderAddress(
        id: _asInt(json['id']),
        fullName: json['full_name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        addressLine1: json['address_line1']?.toString() ?? '',
        addressLine2: json['address_line2']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        pincode: json['pincode']?.toString() ?? '',
      );
}

class AdminOrderItem {
  final int id;
  final int? product;
  final String? productName;
  final String brandName;
  final String? productImage;
  final int quantity;
  final double price;
  final String size;
  final String color;

  AdminOrderItem({
    required this.id,
    this.product,
    this.productName,
    required this.brandName,
    this.productImage,
    required this.quantity,
    required this.price,
    required this.size,
    required this.color,
  });

  String? get imageUrl => _fullImageUrl(productImage);

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) => AdminOrderItem(
        id: _asInt(json['id']),
        product: json['product'] != null ? _asInt(json['product']) : null,
        productName: json['product_name']?.toString(),
        brandName: json['brand_name']?.toString() ?? 'N/A',
        productImage: json['product_image']?.toString(),
        quantity: _asInt(json['quantity']),
        price: _asDouble(json['price']),
        size: json['size']?.toString() ?? '',
        color: json['color']?.toString() ?? '',
      );
}

/// Same shape for both the admin orders list and a single order's
/// detail response — GET /api/orders/admin/all/ and
/// GET /api/orders/admin/{id}/.
class AdminOrderModel {
  final int id;
  final String orderId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final AdminOrderAddress? address;
  final String? shippingAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String? trackingNumber;
  final double shippingCost;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final double refundAmount;
  final double refundCharges;
  final String status;
  final int returnsCount;
  final List<AdminOrderItem> items;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final String? cancelledComment;
  final String? expectedDelivery;

  AdminOrderModel({
    required this.id,
    required this.orderId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.address,
    this.shippingAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.trackingNumber,
    required this.shippingCost,
    required this.subtotal,
    required this.tax,
    required this.totalAmount,
    required this.refundAmount,
    required this.refundCharges,
    required this.status,
    required this.returnsCount,
    required this.items,
    this.createdAt,
    this.cancelledAt,
    this.cancelledReason,
    this.cancelledComment,
    this.expectedDelivery,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      id: _asInt(json['id']),
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString(),
      customerEmail: json['customer_email']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      address: json['address'] != null ? AdminOrderAddress.fromJson(json['address'] as Map<String, dynamic>) : null,
      shippingAddress: json['shipping_address']?.toString(),
      deliveryMethod: json['delivery_method']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      shippingCost: _asDouble(json['shipping_cost']),
      subtotal: _asDouble(json['subtotal']),
      tax: _asDouble(json['tax']),
      totalAmount: _asDouble(json['total_amount']),
      refundAmount: _asDouble(json['refund_amount']),
      refundCharges: _asDouble(json['refund_charges']),
      status: json['status']?.toString() ?? '',
      returnsCount: (json['returns'] as List? ?? []).length,
      items: (json['items'] as List? ?? []).map((e) => AdminOrderItem.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: _asDate(json['created_at']),
      cancelledAt: _asDate(json['cancelled_at']),
      cancelledReason: json['cancelled_reason']?.toString(),
      cancelledComment: json['cancelled_comment']?.toString(),
      expectedDelivery: json['expected_delivery']?.toString(),
    );
  }
}