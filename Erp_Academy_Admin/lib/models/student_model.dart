import '../core/utils/json_parse.dart';
import 'course_item_model.dart';

int? _intOrNull(dynamic v) => v == null ? null : JsonParse.toInt(v);

String? _strOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// One row from GET /internship/students/
class StudentListItem {
  final int id;
  final String studentCode; // ST2026076
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final String email; // personal email (profile.user.email)
  final String loginEmail; // staff_email (shown in web list)
  final String phone;
  final DateTime? dateOfBirth;
  final String? profileImage;
  final String address;

  final int? enrollmentId;
  final int? centerId;
  final String centerName;
  final List<String> courses;
  final List<FacultyDetail> faculty;
  final int? batchId;
  final String? batchNumber;
  final DateTime? startDate;
  final String counsellorName;
  final String status; // active / inactive / completed
  final DateTime? createdAt;

  // Admission payment info
  final String? paymentPlanType;
  final int? installmentCount;
  final int? customInstallments;
  final double advanceAmount;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime? paymentDate;
  final double discountAmount;
  final String? discountReason;

  const StudentListItem({
    required this.id,
    required this.studentCode,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.email,
    required this.loginEmail,
    required this.phone,
    required this.dateOfBirth,
    required this.profileImage,
    required this.address,
    required this.enrollmentId,
    required this.centerId,
    required this.centerName,
    required this.courses,
    required this.faculty,
    required this.batchId,
    required this.batchNumber,
    required this.startDate,
    required this.counsellorName,
    required this.status,
    required this.createdAt,
    required this.paymentPlanType,
    required this.installmentCount,
    required this.customInstallments,
    required this.advanceAmount,
    required this.paymentMethod,
    required this.transactionId,
    required this.paymentDate,
    required this.discountAmount,
    required this.discountReason,
  });

  bool get hasCourse => courses.isNotEmpty;
  bool get hasEnrollment => enrollmentId != null || courses.isNotEmpty;
  String get courseTitle => courses.join(', ');
  bool get isActive => status.toLowerCase() == 'active';

  factory StudentListItem.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'] as Map)
        : <String, dynamic>{};
    final user = profile['user'] is Map
        ? Map<String, dynamic>.from(profile['user'] as Map)
        : <String, dynamic>{};

    final first = JsonParse.toStr(user['first_name']).trim();
    final last = JsonParse.toStr(user['last_name']).trim();
    var full = JsonParse.toStr(json['full_name']).trim();
    if (full.isEmpty) full = '$first $last'.trim();

    final personalEmail = JsonParse.toStr(user['email']).trim();
    final staffEmail = JsonParse.toStr(profile['staff_email']).trim();

    return StudentListItem(
      id: JsonParse.toInt(json['id']),
      studentCode: JsonParse.toStr(json['student_id']),
      firstName: first,
      lastName: last,
      fullName: full,
      gender: JsonParse.toStr(user['gender']),
      email: personalEmail,
      loginEmail: staffEmail.isNotEmpty ? staffEmail : personalEmail,
      phone: JsonParse.toStr(profile['phone_number']),
      dateOfBirth: JsonParse.toDate(profile['date_of_birth']),
      profileImage: _strOrNull(profile['profile_image']),
      address: JsonParse.toStr(profile['address']).replaceAll('\r\n', '\n'),
      enrollmentId: _intOrNull(json['enrollment_id']),
      centerId: _intOrNull(json['center']),
      centerName: JsonParse.toStr(json['center_name']),
      courses: JsonParse.toMapList(json['courses'])
          .map((c) => JsonParse.toStr(c['title']).trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      faculty: JsonParse.toMapList(json['faculty'])
          .map(FacultyDetail.fromJson)
          .toList(),
      batchId: _intOrNull(json['batch']),
      batchNumber: _strOrNull(json['batch_number']),
      startDate: JsonParse.toDate(json['start_date']),
      counsellorName: JsonParse.toStr(json['councellor_name']),
      status: JsonParse.toStr(json['status'], 'active'),
      createdAt: JsonParse.toDate(json['created_at']),
      paymentPlanType: _strOrNull(json['enrollment_payment_plan_type']),
      installmentCount: _intOrNull(json['payment_installment_count']),
      customInstallments: _intOrNull(json['enrollment_custom_installments']),
      advanceAmount: JsonParse.toDouble(json['enrollment_advance_amount']),
      paymentMethod: _strOrNull(json['enrollment_payment_method']),
      transactionId: _strOrNull(json['enrollment_transaction_id']),
      paymentDate: JsonParse.toDate(json['enrollment_payment_date']),
      discountAmount: JsonParse.toDouble(json['enrollment_discount_amount']),
      discountReason: _strOrNull(json['enrollment_discount_reason']),
    );
  }
}