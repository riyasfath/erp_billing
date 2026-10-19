import 'dart:convert';

class QuotationModel {
  int quotationId;
  String customerName;
  String quotationNumber;
  String quotationDate;
  String remark;
  String emailId;
  String grandTotal;
  int salesPerson;
  String address;
  String deliveryLocation;
  int bankAccount;
  String projectName;

  QuotationModel({
    required this.quotationId,
    required this.customerName,
    required this.quotationNumber,
    required this.quotationDate,
    required this.remark,
    required this.emailId,
    required this.grandTotal,
    required this.salesPerson,
    required this.address,
    required this.deliveryLocation,
    required this.bankAccount,
    required this.projectName,
  });

  factory QuotationModel.fromRawJson(String str) =>
      QuotationModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      quotationId: json['id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      quotationNumber: json['quotation_number'] ?? '',
      quotationDate: json['quotation_date'] ?? '',
      remark: json['remark'] ?? '',
      emailId: json['email_id'] ?? '',
      grandTotal: json['grand_total'] ?? '',
      salesPerson: json['salesperson'] ?? 0,
      address: json['address'] ?? '',
      deliveryLocation: json['delivery_location'] ?? '',
      bankAccount: json['bank_account'] ?? 0,
      projectName: json['project_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': quotationId,
      'customer_name': customerName,
      'quotation_number': quotationNumber,
      'quotation_date': quotationDate,
      'remark': remark,
      'email_id': emailId,
      'grand_total': grandTotal,
      'salesperson': salesPerson,
      'address': address,
      'delivery_location': deliveryLocation,
      'bank_account': bankAccount,
      'project_name': projectName,
    };
  }
}
