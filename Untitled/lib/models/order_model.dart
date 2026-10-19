import 'package:ecommerce_app/core/env_config.dart';
import 'adress_model.dart';

/// One line item inside an order — from /api/orders/, /api/orders/{id}/,
/// or the response of /api/orders/add/ and /api/orders/direct-buy/.
class OrderItemModel {
  final int id;
  final String orderId;
  final int productId;
  final String productName;
  final String brandName;
  final String imageUrl;
  final int quantity;
  final double price;
  final String size;
  final String color;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    required this.size,
    required this.color,
  });

  double get subtotal => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product'] is int ? json['product'] as int : int.tryParse(json['product']?.toString() ?? '') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      brandName: json['brand_name']?.toString() ?? '',
      imageUrl: _fullImageUrl(json['product_image']?.toString()),
      quantity: json['quantity'] is int ? json['quantity'] as int : int.tryParse(json['quantity']?.toString() ?? '') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
    );
  }
}

/// One entry in an order's `returns` array. The API's return-detail
/// shape wasn't confirmed with a filled example — this reads it
/// defensively; adjust if a real filled `returns` array turns up with
/// different field names.
class ReturnEntryModel {
  final int id;
  final String? status;
  final String? reason;

  ReturnEntryModel({required this.id, this.status, this.reason});

  factory ReturnEntryModel.fromJson(Map<String, dynamic> json) {
    return ReturnEntryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      status: json['status']?.toString(),
      reason: json['reason']?.toString(),
    );
  }
}

String _fullImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return '${EnvConfig.accountsBaseUrl}$raw';
}

/// A single tracking-timeline entry, derived from the order's
/// timestamp fields (there's no separate tracking-steps endpoint).
class TrackingStep {
  final String title;
  final String subtitle;
  final bool completed;

  TrackingStep({required this.title, required this.subtitle, this.completed = false});
}

/// Full order — same shape for GET /api/orders/{id}/, each entry of
/// GET /api/orders/ `results`, and the response of /api/orders/add/
/// and /api/orders/direct-buy/.
class OrderModel {
  final int apiId; // numeric id — use this for cancel/{id}/, return/{id}/, detail/{id}/
  final String orderId; // display string, e.g. "ORD-2026-396"
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final AddressModel? address;
  final String shippingAddress;
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
  final List<ReturnEntryModel> returns;
  final List<OrderItemModel> items;
  final DateTime? createdAt;
  final DateTime? processedAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final String? cancelledComment;
  final String? expectedDelivery;

  OrderModel({
    required this.apiId,
    required this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.address,
    required this.shippingAddress,
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
    required this.returns,
    required this.items,
    this.createdAt,
    this.processedAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelledReason,
    this.cancelledComment,
    this.expectedDelivery,
  });

  bool get isCancelled => status.toLowerCase() == 'cancelled' || cancelledAt != null;
  bool get isDelivered => status.toLowerCase() == 'delivered';
  bool get hasActiveReturn => returns.isNotEmpty;

  String get statusLabel {
    if (isCancelled) return 'Cancelled';
    if (isDelivered) return 'Delivered';
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  // --- Single-item convenience getters, used by the order-card UI
  // (every sample order so far has exactly one item) ---
  String get imagePath => items.isNotEmpty ? items.first.imageUrl : '';
  String get productName => items.isNotEmpty ? items.first.productName : '';
  String get size => items.isNotEmpty ? items.first.size : '';
  int get quantity => items.isNotEmpty ? items.first.quantity : 0;
  double get price => items.isNotEmpty ? items.first.price : 0;

  double get totalBills => subtotal;
  double get shipmentFee => shippingCost;
  double get totalPayment => totalAmount;
  String get deliverToAddress => shippingAddress;

  List<TrackingStep> get trackingSteps {
    final steps = <TrackingStep>[
      TrackingStep(title: 'Order Placed', subtitle: _fmtDate(createdAt), completed: true),
    ];

    if (isCancelled) {
      steps.add(TrackingStep(
        title: 'Order Cancelled',
        subtitle: cancelledComment ?? cancelledReason ?? _fmtDate(cancelledAt),
        completed: true,
      ));
      return steps;
    }

    steps.add(TrackingStep(
      title: 'Processing',
      subtitle: processedAt != null ? _fmtDate(processedAt) : 'Pending',
      completed: processedAt != null,
    ));
    steps.add(TrackingStep(
      title: 'Confirmed',
      subtitle: confirmedAt != null ? _fmtDate(confirmedAt) : 'Pending',
      completed: confirmedAt != null,
    ));
    steps.add(TrackingStep(
      title: 'Shipped',
      subtitle: shippedAt != null ? _fmtDate(shippedAt) : 'Pending',
      completed: shippedAt != null,
    ));
    steps.add(TrackingStep(
      title: 'Delivered',
      subtitle: deliveredAt != null
          ? _fmtDate(deliveredAt)
          : (expectedDelivery != null ? 'Expected $expectedDelivery' : 'Pending'),
      completed: deliveredAt != null,
    ));
    return steps;
  }

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = (json['items'] as List?) ?? [];
    final List<dynamic> returnsJson = (json['returns'] as List?) ?? [];

    return OrderModel(
      apiId: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      address: json['address'] is Map<String, dynamic> ? AddressModel.fromJson(json['address'] as Map<String, dynamic>) : null,
      shippingAddress: json['shipping_address']?.toString() ?? '',
      deliveryMethod: json['delivery_method']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      shippingCost: double.tryParse(json['shipping_cost']?.toString() ?? '') ?? 0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '') ?? 0,
      refundAmount: double.tryParse(json['refund_amount']?.toString() ?? '') ?? 0,
      refundCharges: double.tryParse(json['refund_charges']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      returns: returnsJson.map((e) => ReturnEntryModel.fromJson(e as Map<String, dynamic>)).toList(),
      items: itemsJson.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      processedAt: json['processed_at'] != null ? DateTime.tryParse(json['processed_at'].toString()) : null,
      confirmedAt: json['confirmed_at'] != null ? DateTime.tryParse(json['confirmed_at'].toString()) : null,
      shippedAt: json['shipped_at'] != null ? DateTime.tryParse(json['shipped_at'].toString()) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.tryParse(json['cancelled_at'].toString()) : null,
      cancelledReason: json['cancelled_reason']?.toString(),
      cancelledComment: json['cancelled_comment']?.toString(),
      expectedDelivery: json['expected_delivery']?.toString(),
    );
  }
}

/// One page of GET /api/orders/.
class OrderListResult {
  final List<OrderModel> orders;
  final String? nextUrl;
  final int count;

  OrderListResult({required this.orders, required this.nextUrl, required this.count});
}

// ---------------------------------------------------------------------
// Request models
// ---------------------------------------------------------------------

/// POST /api/orders/direct-buy/.
class DirectBuyModel {
  final int productId;
  final int quantity;
  final String size;
  final String color;
  final int addressId;
  final String deliveryMethod; // 'standard' | 'express'
  final String paymentMethod; // 'cod' | 'upi' | 'card'

  DirectBuyModel({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.color,
    required this.addressId,
    required this.deliveryMethod,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'size': size,
        'color': color,
        'address_id': addressId,
        'delivery_method': deliveryMethod,
        'payment_method': paymentMethod,
      };
}

/// One entry of POST /api/orders/{id}/return/'s `items` array.
class ReturnItemRequest {
  final int itemId;
  final String reason; // 'defective' | 'wrong_item' | 'size_issue' | 'changed_mind'
  final String comment;

  ReturnItemRequest({required this.itemId, required this.reason, required this.comment});

  Map<String, dynamic> toJson() => {
        'item_id': itemId,
        'reason': reason,
        'comment': comment,
      };
}