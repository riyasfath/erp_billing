class InvoiceModel {
  int invoiceId;
  String clientName;
  String invoiceNumber;

  InvoiceModel({
    required this.invoiceId,
    required this.clientName,
    required this.invoiceNumber,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        invoiceId: json["id"],
        clientName: json["client_name"],
        invoiceNumber: json["invoice_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": invoiceId,
        "client_name": clientName,
        "invoice_number": invoiceNumber,
      };
}

class ReceiptModel {
  int receiptId;
  String termsTitle;
  String clientName;
  String invoiceNumber;
  String receiptNumber;
  String receiptDate;
  String remark;

  ReceiptModel({
    required this.receiptId,
    required this.termsTitle,
    required this.clientName,
    required this.invoiceNumber,
    required this.receiptNumber,
    required this.receiptDate,
    required this.remark,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => ReceiptModel(
        receiptId: json["id"] ?? 0,
        termsTitle: json["termsandconditions_title"] ?? "",
        clientName: json["client_name"] ?? "",
        invoiceNumber: json["invoice_number"] ?? "",
        receiptNumber: json["receipt_number"] ?? "",
        receiptDate: json["receipt_date"] ?? "",
        remark: json["remark"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": receiptId,
        "termsandconditions_title": termsTitle,
        "client_name": clientName,
        "invoice_number": invoiceNumber,
        "receipt_number": receiptNumber,
        "receipt_date": receiptDate,
        "remark": remark,
      };
}

class SingleReceiptModel {
  int receiptId;
  String termsTitle;
  String clientName;
  String invoiceNumber;
  String receiptNumber;
  String receiptDate;
  String remark;
  final List<TermsAndCondition> termsAndConditions;
  final List<ItemsModel> items;
  int clientId;
  int invoiceId;
  int termsId;

  SingleReceiptModel({
    required this.receiptId,
    required this.termsTitle,
    required this.clientName,
    required this.invoiceNumber,
    required this.receiptNumber,
    required this.receiptDate,
    required this.remark,
    required this.termsAndConditions,
    required this.items,
    required this.clientId,
    required this.invoiceId,
    required this.termsId,
  });

  factory SingleReceiptModel.fromJson(Map<String, dynamic> json) =>
      SingleReceiptModel(
        receiptId: json["id"] ?? 0,
        termsTitle: json["termsandconditions_title"] ?? "",
        clientName: json["client_name"] ?? "",
        invoiceNumber: json["invoice_number"] ?? "",
        receiptNumber: json["receipt_number"] ?? "",
        receiptDate: json["receipt_date"] ?? "",
        remark: json["remark"] ?? "",
        termsAndConditions: (json['termsandconditions_points'] as List)
            .map((e) => TermsAndCondition.fromJson(e))
            .toList(),
        items:
            (json['items'] as List).map((e) => ItemsModel.fromJson(e)).toList(),
        clientId: json["client"] ?? 0,
        invoiceId: json["invoice"] ?? 0,
        termsId: json["termsandconditions"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": receiptId,
        "termsandconditions_title": termsTitle,
        "client_name": clientName,
        "invoice_number": invoiceNumber,
        "receipt_number": receiptNumber,
        "receipt_date": receiptDate,
        "remark": remark,
        "termsandconditions_points":
            termsAndConditions.map((e) => e.toJson()).toList(),
        "items": items.map((e) => e.toJson()).toList(),
        "client": clientId,
        "invoice": invoiceId,
        "termsandconditions": termsId,
      };
}

class TermsAndCondition {
  final int id;
  final int termsAndConditions;
  final String termsAndConditionsTitle;
  final String point;
  final String createdAt;

  TermsAndCondition({
    required this.id,
    required this.termsAndConditions,
    required this.termsAndConditionsTitle,
    required this.point,
    required this.createdAt,
  });

  factory TermsAndCondition.fromJson(Map<String, dynamic> json) {
    return TermsAndCondition(
      id: json['id'] ?? 0,
      termsAndConditions: json['terms_and_conditions'] ?? 0,
      termsAndConditionsTitle: json['terms_and_conditions_title'] ?? "",
      point: json['point'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'terms_and_conditions': termsAndConditions,
      'terms_and_conditions_title': termsAndConditionsTitle,
      'point': point,
      'created_at': createdAt,
    };
  }
}

class ItemsModel {
  final int id;
  final String productName;
  final String deliveryQuantity;
  final String unitPrice;
  final String sgstPercentage;
  final String cgstPercentage;
  final String total;
  final String sgst;
  final String cgst;
  final String subTotal;

  ItemsModel({
    required this.id,
    required this.productName,
    required this.deliveryQuantity,
    required this.unitPrice,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
  });

  factory ItemsModel.fromJson(Map<String, dynamic> json) {
    return ItemsModel(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? "",
      deliveryQuantity: json['delivered_quantity'] ?? "",
      unitPrice: json['unit_price'] ?? "",
      sgstPercentage: json['sgst_percentage'] ?? "",
      cgstPercentage: json['cgst_percentage'] ?? "",
      total: json['total'] ?? "",
      sgst: json['sgst'] ?? "",
      cgst: json['cgst'] ?? "",
      subTotal: json['sub_total'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'delivered_quantity': deliveryQuantity,
      'unit_price': unitPrice,
      'sgst_percentage': sgstPercentage,
      'cgst_percentage': cgstPercentage,
      'total': total,
      'sgst': sgst,
      'cgst': cgst,
      'sub_total': subTotal,
    };
  }
}
