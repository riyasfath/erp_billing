// // lib/models/data-models/salesperson_model.dart
// class SalesPersonModel {
//   final int salesPersonId;
//   final String firstName;
//   final String lastName;
//   final String designation;
//   final String email;
//   final String phone;
//   final String mobile;
//   final String incentive;
//   final String address;
//   final String country;
//   final String state;
//   final String city;
//   final String? profilePicture;
//   final int linkedUser;

//   SalesPersonModel({
//     required this.salesPersonId,
//     required this.firstName,
//     required this.lastName,
//     required this.designation,
//     required this.email,
//     required this.phone,
//     required this.mobile,
//     required this.incentive,
//     required this.address,
//     required this.country,
//     required this.state,
//     required this.city,
//     this.profilePicture,
//     required this.linkedUser,
//   });

//   factory SalesPersonModel.fromJson(Map<String, dynamic> json) {
//     final user = json['user'] as Map<String, dynamic>? ?? {};

//     return SalesPersonModel(
//       salesPersonId: (json['id'] is int)
//           ? json['id'] as int
//           : int.tryParse('${json['id']}') ?? 0,
//       firstName: user['first_name']?.toString() ?? '',
//       lastName: user['last_name']?.toString() ?? '',
//       email: user['email']?.toString() ?? '',
//       phone: user['phone_number']?.toString() ?? '',
//       designation: json['designation']?.toString() ?? '',
//       mobile: json['mobile']?.toString() ?? '',
//       incentive: json['incentive']?.toString() ?? '0.00',
//       address: json['address']?.toString() ?? '',
//       country: json['country']?.toString() ?? '',
//       state: json['state']?.toString() ?? '',
//       city: json['city']?.toString() ?? '',
//       profilePicture: json['profile_picture']?.toString(),
//       linkedUser: (json['linked_user'] is int)
//           ? json['linked_user'] as int
//           : int.tryParse('${json['linked_user']}') ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': salesPersonId,
//         'user': {
//           'first_name': firstName,
//           'last_name': lastName,
//           'email': email,
//           'phone_number': phone,
//           'username': email,
//         },
//         'designation': designation,
//         'city': city,
//         'state': state,
//         'country': country,
//         'address': address,
//         'mobile': mobile,
//         'incentive': incentive,
//         'linked_user': linkedUser,
//         'profile_picture': profilePicture,
//       };

//   String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

//   @override
//   String toString() => 'SalesPersonModel(id: $salesPersonId, name: $fullName)';

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SalesPersonModel && other.salesPersonId == salesPersonId;

//   @override
//   int get hashCode => salesPersonId.hashCode;
// }
// lib/models/data-models/salesperson_model.dart

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
  final String city;
  final String? profilePicture;
  final int linkedUser;

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
    required this.city,
    this.profilePicture,
    required this.linkedUser,
  });

  factory SalesPersonModel.fromJson(Map<String, dynamic> json) {
    // ── The GET /sales-persons/ endpoint returns a FLAT object:
    //    { "id": 9, "name": "anu", "email": "anu@gmail.com", ... }
    //    No nested "user" object. We handle BOTH shapes here so that
    //    the detail / create / edit endpoints (which DO nest user) still work.

    final user = json['user'] as Map<String, dynamic>?;

    String firstName = '';
    String lastName = '';

    if (user != null) {
      // ── Nested shape (detail / create / edit responses)
      firstName = user['first_name']?.toString() ?? '';
      lastName = user['last_name']?.toString() ?? '';
    } else {
      // ── Flat shape (list endpoint): "name" may be "First Last" or just "First"
      final rawName = json['name']?.toString().trim() ?? '';
      final parts = rawName.split(' ');
      firstName = parts.isNotEmpty ? parts.first : rawName;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return SalesPersonModel(
      salesPersonId: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      firstName: firstName,
      lastName: lastName,
      email: (user != null
              ? user['email']?.toString()
              : json['email']?.toString()) ??
          '',
      phone: (user != null
              ? user['phone_number']?.toString()
              : json['mobile']?.toString()) ??
          '',
      designation: json['designation']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      incentive: json['incentive']?.toString() ?? '0.00',
      address: json['address']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString(),
      linkedUser: (json['linked_user'] is int)
          ? json['linked_user'] as int
          : int.tryParse('${json['linked_user']}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': salesPersonId,
        'user': {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phone,
          'username': email,
        },
        'designation': designation,
        'city': city,
        'state': state,
        'country': country,
        'address': address,
        'mobile': mobile,
        'incentive': incentive,
        'linked_user': linkedUser,
        'profile_picture': profilePicture,
      };

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  @override
  String toString() => 'SalesPersonModel(id: $salesPersonId, name: $fullName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesPersonModel && other.salesPersonId == salesPersonId;

  @override
  int get hashCode => salesPersonId.hashCode;
}
