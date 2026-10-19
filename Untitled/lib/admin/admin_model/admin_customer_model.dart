int _cAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
double _cAsDouble(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _cAsDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

class AdminCustomerModel {
  final int id;
  final String? fullName;
  final String email;
  final String? photo;
  final String? phoneNumber;
  final DateTime? dateJoined;
  final int ordersCount;
  final double totalSpent;

  AdminCustomerModel({
    required this.id,
    this.fullName,
    required this.email,
    this.photo,
    this.phoneNumber,
    this.dateJoined,
    required this.ordersCount,
    required this.totalSpent,
  });

  String get displayName => fullName?.isNotEmpty == true ? fullName! : email;

  factory AdminCustomerModel.fromJson(Map<String, dynamic> json) => AdminCustomerModel(
        id: _cAsInt(json['id']),
        fullName: json['full_name']?.toString(),
        email: json['email']?.toString() ?? '',
        photo: json['photo']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        dateJoined: _cAsDate(json['date_joined']),
        ordersCount: _cAsInt(json['orders_count']),
        totalSpent: _cAsDouble(json['total_spent']),
      );
}