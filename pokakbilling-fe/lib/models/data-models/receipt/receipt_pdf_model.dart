class ReceiptPdfModel {
  final int receiptId;
  final String termsAndConditionsTitle;
  final List<TermsAndCondition> termsAndConditions;
  final Salesperson salesperson;
  final Client client;
  final String invoiceNumber;
  final String invoiceGrandTotal;
  final String receiptNumber;
  final String receiptDate;
  final String remark;
  final String createdAt;
  final int user;
  final int invoice;
  final List<dynamic> items;

  ReceiptPdfModel({
    required this.receiptId,
    required this.termsAndConditionsTitle,
    required this.termsAndConditions,
    required this.salesperson,
    required this.client,
    required this.invoiceNumber,
    required this.invoiceGrandTotal,
    required this.receiptNumber,
    required this.receiptDate,
    required this.remark,
    required this.createdAt,
    required this.user,
    required this.invoice,
    required this.items,
  });

  factory ReceiptPdfModel.fromJson(Map<String, dynamic> json) {
    return ReceiptPdfModel(
      receiptId: json['id'],
      termsAndConditionsTitle: json['termsandconditions_title'] ?? '',
      termsAndConditions: (json['termsandconditions'] as List)
          .map((e) => TermsAndCondition.fromJson(e))
          .toList(),
      salesperson: Salesperson.fromJson(json['salesperson']),
      client: Client.fromJson(json['client']),
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceGrandTotal: json['invoice_grand_total'] ?? '',
      receiptNumber: json['receipt_number'] ?? '',
      receiptDate: json['receipt_date'] ?? '',
      remark: json['remark'] ?? '',
      createdAt: json['created_at'] ?? '',
      user: json['user'],
      invoice: json['invoice'],
      items: json['items'] ?? [],
    );
  }
}

class TermsAndCondition {
  final int id;
  final String title;
  final String point;
  final String createdAt;
  final int termsAndConditions;

  TermsAndCondition({
    required this.id,
    required this.title,
    required this.point,
    required this.createdAt,
    required this.termsAndConditions,
  });

  factory TermsAndCondition.fromJson(Map<String, dynamic> json) {
    return TermsAndCondition(
      id: json['id'],
      title: json['termsandconditions'] ?? '',
      point: json['point'] ?? '',
      createdAt: json['created_at'] ?? '',
      termsAndConditions: json['terms_and_conditions'],
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
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      incentive: json['incentive'] ?? '',
      address: json['address'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

class Client {
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

  Client({
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

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      customerType: json['customer_type'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      companyName: json['company_name'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      salesperson: json['salesperson'],
    );
  }
}
