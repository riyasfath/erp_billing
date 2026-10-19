class MaterialReceiveItemModel {
  final int mrId;
  final int supplierId;
  final String supplierName;
  final int purchaseOrderId;
  final String purchaseOrderNumber;
  final String materialReceiveNumber;
  final String grandTotal;
  final String receivedDate;
  final String remark;
  final List<MaterialReceiveItem> items;

  MaterialReceiveItemModel({
    required this.mrId,
    required this.supplierId,
    required this.supplierName,
    required this.purchaseOrderId,
    required this.purchaseOrderNumber,
    required this.materialReceiveNumber,
    required this.grandTotal,
    required this.receivedDate,
    required this.remark,
    required this.items,
  });

  factory MaterialReceiveItemModel.fromJson(Map<String, dynamic> json) {
    return MaterialReceiveItemModel(
      mrId: json['id'] ?? 0,
      supplierId: json['supplier'] ?? 0,
      supplierName: json['supplier_name'] ?? "",
      purchaseOrderId: json['purchase_order'] ?? 0,
      purchaseOrderNumber: json['purchase_order_number'] ?? "",
      materialReceiveNumber: json['material_receive_number'] ?? "",
      grandTotal: json['grand_total'] ?? "",
      receivedDate: json['received_date'] ?? "",
      remark: json['remark'] ?? "",
      items: (json['items'] as List)
          .map((e) => MaterialReceiveItem.fromJson(e))
          .toList(),
    );
  }
}

class MaterialReceiveItem {
  final int materialid;
  final int product;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String total;
  final String sgst;
  final String cgst;
  final String subTotal;

  MaterialReceiveItem({
    required this.materialid,
    required this.product,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
  });

  factory MaterialReceiveItem.fromJson(Map<String, dynamic> json) {
    return MaterialReceiveItem(
      materialid: json['id'] ?? 0,
      product: json['product'] ?? 0,
      productName: json['product_name'] ?? "",
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] ?? "",
      total: json['total'] ?? "",
      sgst: json['sgst_percentage'] ?? "",
      cgst: json['cgst_percentage'] ?? "",
      subTotal: json['sub_total'] ?? "",
    );
  }
}
