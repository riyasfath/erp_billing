import 'dart:convert';

class ItemsBySalesOrder {
  int salesOrderId;
  int productId;
  String productName;
  String productDescription;
  String quantity;
  String pendingQuantity;
  String unitPrice;
  String sgstPercentage;
  String cgstPercentage;
  String total;
  String sgst;
  String cgst;
  String subTotal;
  bool isItemDelivered;

  ItemsBySalesOrder({
    required this.salesOrderId,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.quantity,
    required this.pendingQuantity,
    required this.unitPrice,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
    required this.isItemDelivered,
  });

  factory ItemsBySalesOrder.fromRawJson(String str) =>
      ItemsBySalesOrder.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ItemsBySalesOrder.fromJson(Map<String, dynamic> json) {
    return ItemsBySalesOrder(
      salesOrderId: json['id'] ?? 0,
      productId: json['product'] ?? 0,
      productName: json['product_name'] ?? '',
      productDescription: json['product_description'] ?? '',
      quantity: json['quantity'] ?? "",
      pendingQuantity: json['pending_quantity'] ?? "",
      unitPrice: json['unit_price'] ?? '',
      sgstPercentage: json['sgst_percentage'] ?? '',
      cgstPercentage: json['cgst_percentage'] ?? '',
      total: json['total'] ?? '',
      sgst: json['sgst'] ?? '',
      cgst: json['cgst'] ?? '',
      subTotal: json['sub_total'] ?? '',
      isItemDelivered: json['is_item_delivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': salesOrderId,
      'product': productId,
      'product_name': productName,
      'product_description': productDescription,
      'quantity': quantity,
      'pending_quantity': pendingQuantity,
      'unit_price': unitPrice,
      'sgst_percentage': sgstPercentage,
      'cgst_percentage': cgstPercentage,
      'total': total,
      'sgst': sgst,
      'cgst': cgst,
      'sub_total': subTotal,
      'is_item_delivered': isItemDelivered,
    };
  }
}
