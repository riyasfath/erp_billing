class SalesOrderPdfModel {
  final int salesorderId;
  final String salesOrderNumber;
  final String salesDate;
  final String purchaseOrderNumber;
  final String remark;
  final String deliveryLocation;
  final String deliveryAddress;
  final String subtotal;
  final String total;
  final String grandTotal;
  final bool isDelivered;
  final String? termsandconditionsTitle;
  final List<TermsAndCondition> termsandconditions;
  final Customer customer;
  final Salesperson salesperson;
  final List<SalesOrderItem> items;

  SalesOrderPdfModel({
    required this.salesorderId,
    required this.salesOrderNumber,
    required this.salesDate,
    required this.purchaseOrderNumber,
    required this.remark,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.subtotal,
    required this.total,
    required this.grandTotal,
    required this.isDelivered,
    required this.termsandconditionsTitle,
    required this.termsandconditions,
    required this.customer,
    required this.salesperson,
    required this.items,
  });

  factory SalesOrderPdfModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderPdfModel(
      salesorderId: json['id'],
      salesOrderNumber: json['sales_order_number'],
      salesDate: json['sales_date'],
      purchaseOrderNumber: json['purchase_order_number'],
      remark: json['remark'],
      deliveryLocation: json['delivery_location'],
      deliveryAddress: json['delivery_address'],
      subtotal: json['subtotal'],
      total: json['total'],
      grandTotal: json['grand_total'],
      isDelivered: json['is_delivered'],
      termsandconditionsTitle: json['termsandconditions_title'],
      termsandconditions: List<TermsAndCondition>.from(
        json['termsandconditions'].map((x) => TermsAndCondition.fromJson(x)),
      ),
      customer: Customer.fromJson(json['customer']),
      salesperson: Salesperson.fromJson(json['salesperson']),
      items: List<SalesOrderItem>.from(
        json['items'].map((x) => SalesOrderItem.fromJson(x)),
      ),
    );
  }
}

class Customer {
  final int id;
  final String customerType;
  final String firstName;
  final String lastName;
  final String companyName;
  final String country;
  final String state;
  final String address;
  final String email;
  final String phone;
  final String mobile;
  final int salesperson;

  Customer({
    required this.id,
    required this.customerType,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.country,
    required this.state,
    required this.address,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.salesperson,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerType: json['customer_type'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      companyName: json['company_name'],
      country: json['country'],
      state: json['state'],
      address: json['address'],
      email: json['email'],
      phone: json['phone'],
      mobile: json['mobile'],
      salesperson: json['salesperson'],
    );
  }
}

class Salesperson {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String mobile;
  final String incentive;
  final String address;
  final String country;
  final String state;

  Salesperson({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.incentive,
    required this.address,
    required this.country,
    required this.state,
  });

  factory Salesperson.fromJson(Map<String, dynamic> json) {
    return Salesperson(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      mobile: json['mobile'],
      incentive: json['incentive'],
      address: json['address'],
      country: json['country'],
      state: json['state'],
    );
  }
}

class SalesOrderItem {
  final int id;
  final String productName;
  final String productDescription;
  final int quantity;
  final int pendingQuantity;
  final String unitPrice;
  final String total;
  final String sgst;
  final String cgst;
  final String subTotal;
  final String sgstPercentage;
  final String cgstPercentage;
  final bool isItemDelivered;
  final int salesOrder;
  final int product;

  SalesOrderItem({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.quantity,
    required this.pendingQuantity,
    required this.unitPrice,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.isItemDelivered,
    required this.salesOrder,
    required this.product,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderItem(
      id: json['id'],
      productName: json['product_name'],
      productDescription: json['product_description'],
      quantity: json['quantity'],
      pendingQuantity: json['pending_quantity'],
      unitPrice: json['unit_price'],
      total: json['total'],
      sgst: json['sgst'],
      cgst: json['cgst'],
      subTotal: json['sub_total'],
      sgstPercentage: json['sgst_percentage'],
      cgstPercentage: json['cgst_percentage'],
      isItemDelivered: json['is_item_delivered'],
      salesOrder: json['sales_order'],
      product: json['product'],
    );
  }
}

class TermsAndCondition {
  final int id;
  final String termsandconditions;
  final String point;
  final String createdAt;
  final int termsAndConditions;

  TermsAndCondition({
    required this.id,
    required this.termsandconditions,
    required this.point,
    required this.createdAt,
    required this.termsAndConditions,
  });

  factory TermsAndCondition.fromJson(Map<String, dynamic> json) {
    return TermsAndCondition(
      id: json['id'],
      termsandconditions: json['termsandconditions'],
      point: json['point'],
      createdAt: json['created_at'],
      termsAndConditions: json['terms_and_conditions'],
    );
  }
}
