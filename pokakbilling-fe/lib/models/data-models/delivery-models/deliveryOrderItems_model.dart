class DeliveryOrderItemsModel {
  int id;
  String clientFirstName;
  String clientLastName;
  String deliveryNumber;
  String deliveryDate;
  String salesOrderNumber;
  String deliveryLocation;
  String deliveryAddress;
  String time;
  String grandTotal;
  String termsTitle;
  bool isInvoiced;
  List<TermsAndConditionModel> termsCondition;
  List<Item> items;
  int clientId;
  int salesOrderId;

  DeliveryOrderItemsModel({
    required this.id,
    required this.clientFirstName,
    required this.clientLastName,
    required this.deliveryNumber,
    required this.deliveryDate,
    required this.salesOrderNumber,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.time,
    required this.grandTotal,
    required this.termsTitle,
    required this.isInvoiced,
    required this.termsCondition,
    required this.items,
    required this.clientId,
    required this.salesOrderId,
  });

  factory DeliveryOrderItemsModel.fromJson(Map<String, dynamic> json) =>
      DeliveryOrderItemsModel(
        id: json["id"] ?? 0,
        clientFirstName: json['client_firstname'] ?? "",
        clientLastName: json['client_lastname'] ?? "",
        deliveryNumber: json["delivery_number"] ?? "",
        deliveryDate: json["delivery_date"] ?? "",
        salesOrderNumber: json["sales_order_number"] ?? "",
        deliveryLocation: json["delivery_location"] ?? "",
        deliveryAddress: json["delivery_address"] ?? "",
        time: json["time"] ?? "",
        grandTotal: json["grand_total"] ?? "",
        termsTitle: json["termsandconditions_title"] ?? "",
        isInvoiced: json["is_invoiced"] ?? false,
        termsCondition: List<TermsAndConditionModel>.from(
            json["termsandconditions_points"]
                .map((x) => TermsAndConditionModel.fromJson(x))),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        clientId: json["customer"] ?? 0,
        salesOrderId: json["sales_order"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_firstname": clientFirstName,
        "client_lastname": clientLastName,
        "delivery_number": deliveryNumber,
        "delivery_date": deliveryDate,
        "sales_order_number": salesOrderNumber,
        "delivery_location": deliveryLocation,
        "delivery_address": deliveryAddress,
        "time": time,
        "grand_total": grandTotal,
        "termsandcondtions_title": termsTitle,
        "is_invoiced": isInvoiced,
        "termsandconditions_points":
            List<dynamic>.from(termsCondition.map((x) => x.toJson())),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "customer": clientId,
        "sales_order": salesOrderId,
      };
}

class TermsAndConditionModel {
  int pointId;
  int termsId;
  String termsTitle;
  String point;
  String createdAt;

  TermsAndConditionModel({
    required this.pointId,
    required this.termsId,
    required this.termsTitle,
    required this.point,
    required this.createdAt,
  });

  factory TermsAndConditionModel.fromJson(Map<String, dynamic> json) =>
      TermsAndConditionModel(
        pointId: json["id"] ?? 0,
        termsId: json["terms_and_conditions"] ?? 0,
        termsTitle: json["terms_and_conditions_title"] ?? "",
        point: json["point"] ?? "",
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": pointId,
        "terms_and_conditions": termsId,
        "terms_and_conditions_title": termsTitle,
        "point": point,
        "created_at": createdAt,
      };
}

class Item {
  int id;
  int productId;
  String productName;
  String unitPrice;
  String total;
  String sgst;
  String cgst;
  String subTotal;
  int deliveredQuantity;
  String sgstPercentage;
  String cgstPercentage;

  Item({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
    required this.deliveredQuantity,
    required this.sgstPercentage,
    required this.cgstPercentage,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] ?? 0,
        productId: json["product_id"] ?? 0,
        productName: json["product_name"] ?? "",
        unitPrice: json["unit_price"] ?? "",
        total: json["total"] ?? "",
        sgst: json["sgst"] ?? "",
        cgst: json["cgst"] ?? "",
        subTotal: json["sub_total"] ?? "",
        deliveredQuantity: json["delivered_quantity"] ?? 0,
        sgstPercentage: json["sgst_percentage"] ?? "",
        cgstPercentage: json["cgst_percentage"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "product_name": productName,
        "unit_price": unitPrice,
        "total": total,
        "sgst": sgst,
        "cgst": cgst,
        "sub_total": subTotal,
        "delivered_quantity": deliveredQuantity,
        "sgst_percentage": sgstPercentage,
        "cgst_percentage": cgstPercentage,
      };
}
