int _eAsInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
DateTime? _eAsDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

class EmployeeUserDetails {
  final int id;
  final String email;
  final String? fullName;
  final String role;
  final String? photo;
  final DateTime? dateJoined;

  EmployeeUserDetails({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.photo,
    this.dateJoined,
  });

  factory EmployeeUserDetails.fromJson(Map<String, dynamic> json) => EmployeeUserDetails(
        id: _eAsInt(json['id']),
        email: json['email']?.toString() ?? '',
        fullName: json['full_name']?.toString(),
        role: json['role']?.toString() ?? 'employee',
        photo: json['photo']?.toString(),
        dateJoined: _eAsDate(json['date_joined']),
      );
}

/// Matches GET (list), POST (create), and PATCH (update) responses —
/// all return this same shape. NOTE: `permissions` is write-only from
/// this API's perspective — sent on create/update but never returned
/// by GET, so it can't be displayed after the fact.
class AdminEmployeeModel {
  final int id;
  final EmployeeUserDetails userDetails;
  final String employeeId;
  final String jobTitle;
  final String phone;
  final DateTime? createdAt;

  AdminEmployeeModel({
    required this.id,
    required this.userDetails,
    required this.employeeId,
    required this.jobTitle,
    required this.phone,
    this.createdAt,
  });

  String get displayName => userDetails.fullName?.isNotEmpty == true ? userDetails.fullName! : userDetails.email;

  factory AdminEmployeeModel.fromJson(Map<String, dynamic> json) => AdminEmployeeModel(
        id: _eAsInt(json['id']),
        userDetails: EmployeeUserDetails.fromJson(json['user_details'] as Map<String, dynamic>? ?? {}),
        employeeId: json['employee_id']?.toString() ?? '',
        jobTitle: json['job_title']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        createdAt: _eAsDate(json['created_at']),
      );
}