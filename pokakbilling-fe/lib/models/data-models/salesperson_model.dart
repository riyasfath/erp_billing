class SalesPersonModel {
  final int salesPersonId;
  final String firstName;
  final String lastName;
  final String designation;
  final String email;
  final String phone;
  final String mobile;
  final String incentive;
  final String address;
  final String country;
  final String state;
  final DateTime? createdDate; // ← added for date filter support

  SalesPersonModel({
    required this.salesPersonId,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.email,
    required this.phone,
    required this.mobile,
    required this.incentive,
    required this.address,
    required this.country,
    required this.state,
    this.createdDate, // ← optional so existing callers are unaffected
  });

  factory SalesPersonModel.fromJson(Map<String, dynamic> json) {
    // Parse created_at / created_date from API — handles both key names
    DateTime? parsedDate;
    final rawDate =
        json['created_at'] ?? json['created_date'] ?? json['date_created'];
    if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString());
    }

    return SalesPersonModel(
      salesPersonId: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      incentive: json['incentive']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      createdDate: parsedDate, // ← mapped from API response
    );
  }

  Map<String, dynamic> toJson() => {
        'id': salesPersonId,
        'first_name': firstName,
        'last_name': lastName,
        'designation': designation,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'incentive': incentive,
        'address': address,
        'country': country,
        'state': state,
        // createdDate is read-only from API, not sent in POST/PATCH
      };

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  @override
  String toString() => 'SalesPersonModel(id: $salesPersonId, name: $fullName)';

  // Equality by id is essential for Dropdown selection to work
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesPersonModel && other.salesPersonId == salesPersonId;

  @override
  int get hashCode => salesPersonId.hashCode;
}
