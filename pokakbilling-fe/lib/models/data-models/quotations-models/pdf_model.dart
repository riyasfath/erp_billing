double parseCurrency(String? value) {
  if (value == null) return 0.0;
  return double.tryParse(value.replaceAll(",", "")) ?? 0.0;
}

class QuotationPdfModel {
  final int quotationId;
  final String customerName;
  final String address;
  final String salespersonName;
  final String salespersonAddress;
  final String quotationNumber;
  final String quotationDate;
  String termsandconditionsTitle;
  List<Termsandcondition> termsandconditions;
  final String emailId;
  final String remark;
  final double subtotal;
  final double total;
  final List<QuotationItem> items;
  final List<BankaccountItem> bankAccount;
  int contractId;
  String contractTitle;
  Contract contract;
  final Salesperson salesperson;
  final Client clientDetails;
  final String projectName;

  QuotationPdfModel({
    required this.quotationId,
    required this.customerName,
    required this.address,
    required this.salespersonName,
    required this.salespersonAddress,
    required this.quotationNumber,
    required this.quotationDate,
    required this.termsandconditionsTitle,
    required this.termsandconditions,
    required this.emailId,
    required this.remark,
    required this.subtotal,
    required this.total,
    required this.items,
    required this.bankAccount,
    required this.contractId,
    required this.contractTitle,
    required this.contract,
    required this.salesperson,
    required this.clientDetails,
    required this.projectName,
  });

  factory QuotationPdfModel.fromJson(Map<String, dynamic> json) {
    List<QuotationItem> items = (json['items'] as List<dynamic>? ?? [])
        .map((item) => QuotationItem.fromJson(item))
        .toList();

    List<BankaccountItem> bankAccount =
        (json['bank_account'] as List<dynamic>? ?? [])
            .map((item) => BankaccountItem.fromJson(item))
            .toList();

    List<Termsandcondition> terms =
        (json["termsandconditions"] as List<dynamic>? ?? [])
            .map((x) => Termsandcondition.fromJson(x))
            .toList();

    return QuotationPdfModel(
      quotationId: json['quotation_id'] ?? 0,
      customerName: json['customer_name'] ?? "",
      address: json['address'] ?? "",
      salespersonName: json['salesperson_name'] ?? "",
      salespersonAddress: json['salesperson_address'] ?? "",
      quotationNumber: json['quotation_number'] ?? "",
      quotationDate: json['quotation_date'] ?? "",
      termsandconditionsTitle: json["termsandconditions_title"] ?? "",
      termsandconditions: terms,
      emailId: json['email_id'] ?? "",
      remark: json['remark'] ?? "",
      subtotal: parseCurrency(json['subtotal'].toString()),
      total: parseCurrency(json['total'].toString()),
      items: items,
      bankAccount: bankAccount,
      contractId: json["contract_id"] ?? 0,
      contractTitle: json["contract_title"] ?? "",
      contract: Contract.fromJson(json["contract"]),
      salesperson: Salesperson.fromJson(json['salesperson'] ?? {}),
      clientDetails: Client.fromJson(json['client']),
      projectName: json['project_name'] ?? "",
    );
  }
}

class Contract {
  int id;
  String title;
  DateTime createdAt;
  List<Section> sections;

  Contract({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.sections,
  });

  factory Contract.fromJson(Map<String, dynamic> json) => Contract(
        id: json["id"] ?? 0,
        title: json["title"] ?? "",
        createdAt: DateTime.parse(json["created_at"]),
        sections: List<Section>.from(
            json["sections"].map((x) => Section.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "created_at": createdAt.toIso8601String(),
        "sections": List<dynamic>.from(sections.map((x) => x.toJson())),
      };
}

class Section {
  int id;
  String title;
  int contract;
  List<Point> points;

  Section({
    required this.id,
    required this.title,
    required this.contract,
    required this.points,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        contract: json["contract"] ?? 0,
        points: List<Point>.from(json["points"].map((x) => Point.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "contract": contract,
        "points": List<dynamic>.from(points.map((x) => x.toJson())),
      };
}

class Point {
  int id;
  String points;
  int section;

  Point({
    required this.id,
    required this.points,
    required this.section,
  });

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        id: json["id"] ?? 0,
        points: json["points"] ?? "",
        section: json["section"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "points": points,
        "section": section,
      };
}

class QuotationItem {
  final String itemName;
  final int quantity;
  final double rate;
  final double tax;
  final double amount;
  final String description;

  QuotationItem({
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.tax,
    required this.amount,
    required this.description,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      itemName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      rate: parseCurrency(json['unit_price'].toString()),
      tax: parseCurrency(json['sgst'].toString()) +
          parseCurrency(json['cgst'].toString()),
      amount: parseCurrency(json['sub_total'].toString()),
      description: json['product_description'] ?? '',
    );
  }
}

class BankaccountItem {
  final int accId;
  final String bankName;
  final String accHolderName;
  final String accNumber;
  final String ifscCode;

  BankaccountItem({
    required this.accId,
    required this.bankName,
    required this.accHolderName,
    required this.accNumber,
    required this.ifscCode,
  });

  factory BankaccountItem.fromJson(Map<String, dynamic> json) {
    return BankaccountItem(
      accId: json['id'] ?? 0,
      bankName: json['bank_name'] ?? "",
      accHolderName: json['account_holder_name'] ?? "",
      accNumber: json['account_number'] ?? "",
      ifscCode: json['ifsc_code'] ?? "",
    );
  }
}

class Termsandcondition {
  int id;
  String termsandconditions;
  String point;
  DateTime createdAt;
  int termsAndConditions;

  Termsandcondition({
    required this.id,
    required this.termsandconditions,
    required this.point,
    required this.createdAt,
    required this.termsAndConditions,
  });

  factory Termsandcondition.fromJson(Map<String, dynamic> json) =>
      Termsandcondition(
        id: json["id"] ?? 0,
        termsandconditions: json["termsandconditions"] ?? "",
        point: json["point"] ?? "",
        createdAt: DateTime.parse(
            json["created_at"] ?? DateTime.now().toIso8601String()),
        termsAndConditions: json["terms_and_conditions"] ?? 0,
      );
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
  final String designation;

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
    required this.designation,
  });

  factory Salesperson.fromJson(Map<String, dynamic> json) {
    return Salesperson(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      mobile: json['mobile'] ?? '',
      incentive: json['incentive'] ?? '',
      address: json['address'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      designation: json['designation'] ?? '',
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
      id: json['id'] ?? 0,
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
      salesperson: json['salesperson'] ?? 0,
    );
  }
}
