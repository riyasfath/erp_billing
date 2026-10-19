class DeliveryPdfModel {
  final int id;
  final List<DeliveryItem> items;
  final Customer customer;
  final List<TermsAndCondition> termsandconditions;
  final String salesOrderNumber;
  final String subtotal;
  final String total;
  final String grandTotal;
  final String deliveryNumber;
  final String deliveryDate;
  final String deliveryLocation;
  final String deliveryAddress;
  final String time;
  final bool isInvoiced;
  final int user;
  final int salesOrder;

  DeliveryPdfModel({
    required this.id,
    required this.items,
    required this.customer,
    required this.termsandconditions,
    required this.salesOrderNumber,
    required this.subtotal,
    required this.total,
    required this.grandTotal,
    required this.deliveryNumber,
    required this.deliveryDate,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.time,
    required this.isInvoiced,
    required this.user,
    required this.salesOrder,
  });

  factory DeliveryPdfModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPdfModel(
      id: json['id'],
      items: List<DeliveryItem>.from(
        json['items'].map((x) => DeliveryItem.fromJson(x)),
      ),
      customer: Customer.fromJson(json['customer']),
      termsandconditions: List<TermsAndCondition>.from(
        json['termsandconditions'].map((x) => TermsAndCondition.fromJson(x)),
      ),
      salesOrderNumber: json['sales_order_number'],
      subtotal: json['subtotal'],
      total: json['total'],
      grandTotal: json['grand_total'],
      deliveryNumber: json['delivery_number'],
      deliveryDate: json['delivery_date'],
      deliveryLocation: json['delivery_location'],
      deliveryAddress: json['delivery_address'],
      time: json['time'],
      isInvoiced: json['is_invoiced'],
      user: json['user'],
      salesOrder: json['sales_order'],
    );
  }
}

class DeliveryItem {
  final int id;
  final String productName;
  final String productDescription;
  final int deliveredQuantity;
  final String unitPrice;
  final String total;
  final String sgst;
  final String cgst;
  final String subTotal;
  final String sgstPercentage;
  final String cgstPercentage;
  final int deliveryForm;
  final int product;

  DeliveryItem({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.deliveredQuantity,
    required this.unitPrice,
    required this.total,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.deliveryForm,
    required this.product,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      productName: json['product_name'],
      productDescription: json['product_description'],
      deliveredQuantity: json['delivered_quantity'],
      unitPrice: json['unit_price'],
      total: json['total'],
      sgst: json['sgst'],
      cgst: json['cgst'],
      subTotal: json['sub_total'],
      sgstPercentage: json['sgst_percentage'],
      cgstPercentage: json['cgst_percentage'],
      deliveryForm: json['delivery_form'],
      product: json['product'],
    );
  }
}

class Customer {
  final int id;
  final String customerType;
  final String firstName;
  final String lastName;
  final String country;
  final String state;
  final String companyName;
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
    required this.country,
    required this.state,
    required this.companyName,
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
      country: json['country'],
      state: json['state'],
      companyName: json['company_name'],
      address: json['address'],
      email: json['email'],
      phone: json['phone'],
      mobile: json['mobile'],
      salesperson: json['salesperson'],
    );
  }
}

class TermsAndCondition {
  final int id;
  final String termsAndConditions;
  final String point;
  final String createdAt;
  final int termsAndConditionsId;

  TermsAndCondition({
    required this.id,
    required this.termsAndConditions,
    required this.point,
    required this.createdAt,
    required this.termsAndConditionsId,
  });

  factory TermsAndCondition.fromJson(Map<String, dynamic> json) {
    return TermsAndCondition(
      id: json['id'],
      termsAndConditions: json['termsandconditions'],
      point: json['point'],
      createdAt: json['created_at'],
      termsAndConditionsId: json['terms_and_conditions'],
    );
  }
}
