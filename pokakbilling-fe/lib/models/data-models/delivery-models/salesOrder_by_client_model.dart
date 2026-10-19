import 'dart:convert';

class SalesorderByClientModel {
  int salesOrderId;
  String salesOrderNumber;
  String clientFirstName;
  String clientLastName;

  SalesorderByClientModel({
    required this.salesOrderId,
    required this.salesOrderNumber,
    required this.clientFirstName,
    required this.clientLastName,
  });

  factory SalesorderByClientModel.fromRawJson(String str) =>
      SalesorderByClientModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SalesorderByClientModel.fromJson(Map<String, dynamic> json) {
    return SalesorderByClientModel(
      salesOrderId: json['id'] ?? 0,
      salesOrderNumber: json['sales_order_number'] ?? '',
      clientFirstName: json['client_first_name'] ?? '',
      clientLastName: json['client_last_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': salesOrderId,
      'sales_order_number': salesOrderNumber,
      'client_first_name': clientFirstName,
      'client_last_name': clientLastName,
    };
  }
}
