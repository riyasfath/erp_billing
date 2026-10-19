
class MaterialReceiveModel {
  final int mrId;
  final String receivedDate;
  final String materialReceiveNumber;
  final String supplierName;

  MaterialReceiveModel({
    required this.mrId,
    required this.receivedDate,
    required this.materialReceiveNumber,
    required this.supplierName,
  });

  factory MaterialReceiveModel.fromJson(Map<String, dynamic> json) {
    return MaterialReceiveModel(
      mrId: json['id'] ?? 0,
      receivedDate: json['received_date'] ?? '',
      materialReceiveNumber: json['material_receive_number'] ?? '',
      supplierName: json['supplier_name'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': mrId,
      'received_date': receivedDate,
      'material_receive_number': materialReceiveNumber,
      'supplier_name': supplierName,
    };
  }
}
