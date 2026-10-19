import 'dart:convert';

class PurchaseOrderModel {
  int purchaseOrderId;
  String purchaseOrderDate;
  String purchaseOrderNumber;
  int totalItems;
  String contactPersonNumber;
  String grandTotal;
  String supplierName;

  PurchaseOrderModel({
    required this.purchaseOrderId,
    required this.purchaseOrderDate,
    required this.purchaseOrderNumber,
    required this.totalItems,
    required this.contactPersonNumber,
    required this.grandTotal,
    required this.supplierName,
  });

  factory PurchaseOrderModel.fromRawJson(String str) =>
      PurchaseOrderModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      purchaseOrderId: json['id'] ?? 0,
      purchaseOrderDate: json['purchase_order_date'] ?? '',
      purchaseOrderNumber: json['purchase_order_number'] ?? '',
      totalItems: json['total_items'] ?? 0,
      contactPersonNumber: json['contact_person_number'] ?? '',
      grandTotal: json['grand_total'] ?? '',
      supplierName: json['supplier_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': purchaseOrderId,
      'purchase_order_date': purchaseOrderDate,
      'purchase_order_number': purchaseOrderNumber,
      'total_items': totalItems,
      'contact_person_number': contactPersonNumber,
      'grand_total': grandTotal,
      'supplier_name': supplierName,
    };
  }
}
