class SalesOrderitemsModel {
  int id;
  String clientName;
  String mobileNumber;
  String termsTitle;
  String salesOrderNumber;
  String salesDate;
  String purchaseOrderNumber;
  String remark;
  String deliveryLocation;
  String deliveryAddress;
  String grandTotal;
  bool isDelivered;
  List<TermsAndConditionModel> termsCondition;
  List<Item> items;
  String salesPersonName;
  int clientId;
  int termsId;

  SalesOrderitemsModel({
    required this.id,
    required this.clientName,
    required this.mobileNumber,
    required this.termsTitle,
    required this.salesOrderNumber,
    required this.salesDate,
    required this.purchaseOrderNumber,
    required this.remark,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.grandTotal,
    required this.isDelivered,
    required this.termsCondition,
    required this.items,
    required this.salesPersonName,
    required this.clientId,
    required this.termsId,
  });

  factory SalesOrderitemsModel.fromJson(Map<String, dynamic> json) =>
      SalesOrderitemsModel(
        id: json["id"] ?? 0,
        clientName: json["client_name"] ?? "",
        mobileNumber: json["mobile_number"] ?? "",
        termsTitle: json["termsandconditions_title"] ?? "",
        salesOrderNumber: json["sales_order_number"] ?? "",
        salesDate: json["sales_date"] ?? "",
        purchaseOrderNumber: json["purchase_order_number"] ?? "",
        remark: json["remark"] ?? "",
        deliveryLocation: json["delivery_location"] ?? "",
        deliveryAddress: json["delivery_address"] ?? "",
        grandTotal: json["grand_total"] ?? "",
        isDelivered: json["is_delivered"] ?? false,
        termsCondition: List<TermsAndConditionModel>.from(
            json["termsandconditions_points"]
                .map((x) => TermsAndConditionModel.fromJson(x))),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        salesPersonName: json["salesperson_name"] ?? "",
        clientId: json["customer"] ?? 0,
        termsId: json["termsandconditions"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_name": clientName,
        "mobile_number": mobileNumber,
        "termsandcondtions_title": termsTitle,
        "sales_order_number": salesOrderNumber,
        "sales_date": salesDate,
        "purchase_order_number": purchaseOrderNumber,
        "remark": remark,
        "delivery_location": deliveryLocation,
        "delivery_address": deliveryAddress,
        "grand_total": grandTotal,
        "is_delivered": isDelivered,
        "termsandconditions_points":
            List<dynamic>.from(termsCondition.map((x) => x.toJson())),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "salesperson_name": salesPersonName,
        "customer": clientId,
        "termsandconditions": termsId,
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
        termsTitle: json["termsandconditions"] ?? "",
        point: json["point"] ?? "",
        createdAt: json["created_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": pointId,
        "terms_and_conditions": termsId,
        "termsandconditions": termsTitle,
        "point": point,
        "created_at": createdAt,
      };
}

class Item {
  int id;
  int productId;
  String name;
  String description;
  double quantity;
  double unitPrice;
  double total;
  double sgst;
  double cgst;
  double sgstPercentage;
  double cgstPercentage;
  double subTotal;
  bool isItemDelivered;

  Item({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.subTotal,
    required this.isItemDelivered,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] ?? 0,
        productId: json["product_id"] ?? 0,
        name: json["name"] ?? "",
        description: json["product_description"] ?? "",
        quantity: json["quantity"] ?? 0.0,
        unitPrice: json["unit_price"] ?? 0.0,
        total: json["total"] ?? 0.0,
        sgst: json["sgst"] ?? 0.0,
        cgst: json["cgst"] ?? 0.0,
        sgstPercentage: json["sgst_percentage"] ?? 0.0,
        cgstPercentage: json["cgst_percentage"] ?? 0.0,
        subTotal: json["sub_total"] ?? 0.0,
        isItemDelivered: json["is_item_delivered"] ?? false,
      );

  get productName => null;

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_id": productId,
        "name": name,
        "product_description": description,
        "quantity": quantity,
        "unit_price": unitPrice,
        "total": total,
        "sgst": sgst,
        "cgst": cgst,
        "sgst_percentage": sgstPercentage,
        "cgst_percentage": cgstPercentage,
        "sub_total": subTotal,
        "is_item_delivered": isItemDelivered,
      };
}
