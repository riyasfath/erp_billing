class SupplierModel {
  int supplierId;
  String supplierNumber;
  String supplierType;
  String date;
  String firstName;
  String lastName;
  String companyName;
  String email;
  String phone;
  String mobile;
  String address;
  String country;
  String state;
  String contactPesonName;
  String contactPersonNumber;
  String currency;

  SupplierModel({
    required this.supplierId,
    required this.supplierNumber,
    required this.supplierType,
    required this.date,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.address,
    required this.country,
    required this.state,
    required this.contactPesonName,
    required this.contactPersonNumber,
    required this.currency,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) => SupplierModel(
        supplierId: json["id"] ?? 0,
        supplierNumber: json["supplier_number"] ?? "",
        supplierType: json["supplier_type"] ?? "",
        date: json["date"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        companyName: json["company_name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        mobile: json["mobile"] ?? "",
        address: json["address"] ?? "",
        country: json["country"] ?? "",
        state: json["state"] ?? "",
        contactPesonName: json["contact_person_name"] ?? "",
        contactPersonNumber: json["contact_person_number"] ?? "",
        currency: json["currency"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": supplierId,
        "supplier_number": supplierNumber,
        "supplier_type": supplierType,
        "date": date,
        "first_name": firstName,
        "last_name": lastName,
        "company_name": companyName,
        "email": email,
        "phone": phone,
        "mobile": mobile,
        "address": address,
        "country": country,
        "state": state,
        "contact_person_name": contactPesonName,
        "contact_person_number": contactPersonNumber,
        "currency": currency,
      };
}

class SupplierDetailModel {
  int supplierId;
  String termsTitle;
  String supplierNumber;
  String supplierType;
  String firstName;
  String lastName;
  String companyName;
  String email;
  String date;
  String contactPersonName;
  String contactPersonNumber;
  String state;
  String country;
  String address;
  String phone;
  String mobile;
  String currency;
  int paymentTermsId;
  List<TermsAndConditionModel> termsCondition;

  SupplierDetailModel({
    required this.supplierId,
    required this.termsTitle,
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
    required this.paymentTermsId,
    required this.termsCondition,
  });

  factory SupplierDetailModel.fromJson(Map<String, dynamic> json) =>
      SupplierDetailModel(
        supplierId: json["id"] ?? 0,
        termsTitle: json["termsandconditions_title"] ?? "",
        supplierNumber: json["supplier_number"] ?? "",
        supplierType: json["supplier_type"] ?? "",
        firstName: json["first_name"] ?? "",
        lastName: json["last_name"] ?? "",
        companyName: json["company_name"] ?? "",
        email: json["email"] ?? "",
        date: json["date"] ?? "",
        contactPersonName: json["contact_person_name"] ?? "",
        contactPersonNumber: json["contact_person_number"] ?? "",
        state: json["state"] ?? "",
        country: json["country"] ?? "",
        address: json["address"] ?? "",
        phone: json["phone"] ?? "",
        mobile: json["mobile"] ?? "",
        currency: json["currency"] ?? "",
        paymentTermsId: json["payment_terms"] ?? 0,
        termsCondition: List<TermsAndConditionModel>.from(
            json["termsandconditions"]
                .map((x) => TermsAndConditionModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": supplierId,
        "termsandconditions_title": termsTitle,
        "supplier_number": supplierNumber,
        "supplier_type": supplierType,
        "first_name": firstName,
        "last_name": lastName,
        "company_name": companyName,
        "email": email,
        "date": date,
        "contact_person_name": contactPersonName,
        "contact_person_number": contactPersonNumber,
        "state": state,
        "country": country,
        "address": address,
        "phone": phone,
        "mobile": mobile,
        "currency": currency,
        "payment_terms": paymentTermsId,
        "termsandconditions":
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
        termsTitle: json["termsandconditions"] ?? "",
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
