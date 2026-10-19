import 'dart:convert';

class DeliveryModel {
  int deliveryId;
  String clientFirstName;
  String clientLastName;
  String deliveryNumber;
  String deliveryDate;
  String deliveryLocation;
  String deliveryAddress;
  String time;
  String grandTotal;
  int customerId;
  int salesOrderId;
  int termsandConditionId;
  bool isInvoiced;

  DeliveryModel({
    required this.deliveryId,
    required this.clientFirstName,
    required this.clientLastName,
    required this.deliveryNumber,
    required this.deliveryDate,
    required this.deliveryLocation,
    required this.deliveryAddress,
    required this.time,
    required this.grandTotal,
    required this.customerId,
    required this.salesOrderId,
    required this.termsandConditionId,
    required this.isInvoiced,
  });

  factory DeliveryModel.fromRawJson(String str) =>
      DeliveryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      deliveryId: json['id'] ?? 0,
      clientFirstName: json['client_firstname'] ?? '',
      clientLastName: json['client_lastname'] ?? '',
      deliveryNumber: json['delivery_number'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      deliveryLocation: json['delivery_location'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      time: json['time'] ?? '',
      grandTotal: json['grand_total'] ?? '',
      customerId: json['customer'] ?? 0,
      salesOrderId: json['sales_order'] ?? 0,
      termsandConditionId: json['termsandconditions'] ?? 0,
      isInvoiced: json['is_invoiced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': deliveryId,
      'client_firstname': clientFirstName,
      'client_lastname': clientLastName,
      'delivery_number': deliveryNumber,
      'delivery_date': deliveryDate,
      'delivery_location': deliveryLocation,
      'delivery_address': deliveryAddress,
      'time': time,
      'grand_total': grandTotal,
      'customer': customerId,
      'sales_order': salesOrderId,
      'termsandconditions': termsandConditionId,
      'is_invoiced': isInvoiced,
    };
  }
}
