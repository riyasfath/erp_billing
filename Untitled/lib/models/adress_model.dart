/// A saved delivery address, matching the real
/// /api/accounts/addresses/ shape.
class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;
  final DateTime? createdAt;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
    this.createdAt,
  });

  /// Short label for list rows / the checkout summary (there's no
  /// separate "title" field in the real API, unlike the old mock data).
  String get title => fullName;

  /// One-line combined address for display.
  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2.trim().isNotEmpty) addressLine2,
      city,
      '$state $pincode',
    ];
    return parts.where((p) => p.trim().isNotEmpty).join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  /// For POST /api/accounts/addresses/ — `id`/`created_at` aren't sent,
  /// the server assigns those.
  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      };
}