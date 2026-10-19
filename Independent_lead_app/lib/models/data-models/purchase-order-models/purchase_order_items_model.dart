class PurchaseOrderItemsModel {
  int purchaseOrderId;
  int supplierId;
  String purchaseOrderNumber;
  String purchaseOrderDate;
  String contactPersonName;
  String contactPersonNumber;
  String quotationNumber;
  String grandTotal;
  String remark;
  int termsId;
  String supplierName;
  String termsTitle;
  List<Item> items;
  List<TermsAndConditionModel> termsCondition;
  final SupplierDetails supplierDetails;

  PurchaseOrderItemsModel({
    required this.purchaseOrderId,
    required this.supplierId,
    required this.purchaseOrderNumber,
    required this.purchaseOrderDate,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.quotationNumber,
    required this.grandTotal,
    required this.remark,
    required this.termsId,
    required this.supplierName,
    required this.termsTitle,
    required this.items,
    required this.termsCondition,
    required this.supplierDetails,
  });

  factory PurchaseOrderItemsModel.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderItemsModel(
        purchaseOrderId: json["id"] ?? 0,
        supplierId: json["supplier_id"] ?? 0,
        purchaseOrderNumber: json['purchase_order_number'] ?? "",
        purchaseOrderDate: json['purchase_order_date'] ?? "",
        contactPersonName: json["contact_person_name"] ?? "",
        contactPersonNumber: json["contact_person_number"] ?? "",
        quotationNumber: json["quotation_number"] ?? "",
        grandTotal: json["grand_total"] ?? "",
        remark: json["remark"] ?? "",
        termsId: json["terms_and_conditions_id"] ?? 0,
        supplierName: json["supplier_name"] ?? "",
        termsTitle: json["terms_and_conditions_title"] ?? "",
        items: json["items"] != null
            ? List<Item>.from(json["items"].map((x) => Item.fromJson(x)))
            : [],
        termsCondition: json["termsandconditions"] != null
            ? List<TermsAndConditionModel>.from(json["termsandconditions"]
                .map((x) => TermsAndConditionModel.fromJson(x)))
            : [],
        supplierDetails: SupplierDetails.fromJson(json['supplier_details']),
      );

  Map<String, dynamic> toJson() => {
        "id": purchaseOrderId,
        "supplier_id": supplierId,
        "purchase_order_number": purchaseOrderNumber,
        "purchase_order_date": purchaseOrderDate,
        "contact_person_name": contactPersonName,
        "contact_person_number": contactPersonNumber,
        "quotation_number": quotationNumber,
        "grand_total": grandTotal,
        "remark": remark,
        "terms_and_conditions_id": termsId,
        "supplier_name": supplierId,
        "terms_and_conditions_title": termsTitle,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "termsandconditions_points":
            List<dynamic>.from(termsCondition.map((x) => x.toJson())),
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
  int quantity;
  String productName;
  String productDescription;
  String unitPrice;
  String total;
  String subTotal;
  String sgstPercentage;
  String cgstPercentage;

  Item({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.productDescription,
    required this.unitPrice,
    required this.total,
    required this.subTotal,
    required this.sgstPercentage,
    required this.cgstPercentage,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] ?? 0,
        productId: json["product"] ?? 0,
        quantity: json["quantity"] ?? 0,
        productName: json["product_name"] ?? "",
        productDescription: json["product_description"] ?? "",
        unitPrice: json["unit_price"] ?? "",
        total: json["total"] ?? "",
        subTotal: json["sub_total"] ?? "",
        sgstPercentage: json["sgst_percentage"] ?? "",
        cgstPercentage: json["cgst_percentage"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product": productId,
        "quantity": quantity,
        "product_name": productName,
        "product_description": productDescription,
        "unit_price": unitPrice,
        "total": total,
        "sub_total": subTotal,
        "sgst_percentage": sgstPercentage,
        "cgst_percentage": cgstPercentage,
      };
}

class SupplierDetails {
  final int id;
  final String supplierNumber;
  final String supplierType;
  final String firstName;
  final String lastName;
  final String companyName;
  final String email;
  final String date;
  final String contactPersonName;
  final String contactPersonNumber;
  final String state;
  final String country;
  final String address;
  final String phone;
  final String mobile;
  final String currency;
  final String createdAt;
  final int paymentTerms;

  SupplierDetails({
    required this.id,
    required this.supplierNumber,
    required this.supplierType,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.email,
    required this.date,
    required this.contactPersonName,
    required this.contactPersonNumber,
    required this.state,
    required this.country,
    required this.address,
    required this.phone,
    required this.mobile,
    required this.currency,
    required this.createdAt,
    required this.paymentTerms,
  });

  factory SupplierDetails.fromJson(Map<String, dynamic> json) {
    return SupplierDetails(
      id: json['id'],
      supplierNumber: json['supplier_number'],
      supplierType: json['supplier_type'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      companyName: json['company_name'],
      email: json['email'],
      date: json['date'],
      contactPersonName: json['contact_person_name'],
      contactPersonNumber: json['contact_person_number'],
      state: json['state'],
      country: json['country'],
      address: json['address'],
      phone: json['phone'],
      mobile: json['mobile'],
      currency: json['currency'],
      createdAt: json['created_at'],
      paymentTerms: json['payment_terms'],
    );
  }
}
