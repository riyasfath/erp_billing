import 'dart:convert';

class SalesOrderModel {
  int salesOrderId;
  String clientName;
  String mobile;
  String termsTitle;
  String salesOrderNumber;
  String salesDate;
  String purchaseOrderNumber;
  String remark;
  String deliveryLocation;
  String deliveryAddress;
  String emailId;
  String grandTotal;
  int salesPerson;
  int bankAccount;

  SalesOrderModel({
    required this.salesOrderId,
    required this.clientName,
    required this.mobile,
    required this.termsTitle,
    required this.salesOrderNumber,
    required this.salesDate,
    required this.purchaseOrderNumber,
    required this.remark,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.emailId,
    required this.grandTotal,
    required this.salesPerson,
    required this.bankAccount,
  });

  factory SalesOrderModel.fromRawJson(String str) =>
      SalesOrderModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      salesOrderId: json['id'] ?? 0,
      clientName: json['client_name'] ?? '',
      mobile: json['mobile_number'] ?? '',
      termsTitle: json['termsandconditions_title'] ?? '',
      salesOrderNumber: json['sales_order_id'] ?? '',
      salesDate: json['sales_date'] ?? '',
      purchaseOrderNumber: json['purchase_order_number'] ?? '',
      remark: json['remark'] ?? '',
      deliveryLocation: json['delivery_location'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      emailId: json['email_id'] ?? '',
      grandTotal: json['grand_total'] ?? '',
      salesPerson: json['salesperson'] ?? 0,
      bankAccount: json['bank_account'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': salesOrderId,
      'client_name': clientName,
      'mobile_number': mobile,
      'termsandconditions_title': termsTitle,
      'sales_order_id': salesOrderNumber,
      'sales_date': salesDate,
      'purchase_order_number': purchaseOrderNumber,
      'remark': remark,
      'delivery_location': deliveryLocation,
      'delivery_address': deliveryAddress,
      'email_id': emailId,
      'grand_total': grandTotal,
      'salesperson': salesPerson,
      'bank_account': bankAccount,
    };
  }
}
