import '../core/utils/json_parse.dart';
import 'course_item_model.dart';

String? _strOrNull(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

class StudentPayment {
  final int installment;
  final double amount;
  final double paid;
  final String status;

  const StudentPayment({
    required this.installment,
    required this.amount,
    required this.paid,
    required this.status,
  });

  factory StudentPayment.fromJson(Map<String, dynamic> json) => StudentPayment(
        installment: JsonParse.toInt(json['installment']),
        amount: JsonParse.toDouble(json['amount']),
        paid: JsonParse.toDouble(json['paid']),
        status: JsonParse.toStr(json['status'], 'Pending'),
      );

  static StudentPayment? tryParse(dynamic v) => v is Map
      ? StudentPayment.fromJson(Map<String, dynamic>.from(v))
      : null;
}

class StudentEnrollment {
  final int? enrollmentId;
  final DateTime? registrationDate;
  final String? place;
  final String counsellorName;
  final String courseName;
  final String center;
  final DateTime? courseStartingDate;
  final String? courseDuration;
  final DateTime? enrollmentDate;
  final int? batchId;
  final String? batchNumber;
  final List<FacultyDetail> instructors;
  final String courseStatus;
  final String? paymentPlanType;
  final int? customInstallments;
  final double advanceAmount;
  final double totalFee;
  final double discountAmount;
  final double discountedFee;
  final double paidAmount;
  final double pendingAmount;
  final StudentPayment? secondPayment;
  final StudentPayment? thirdPayment;
  final DateTime? classEndDate;
  final String paymentStatus;
  final String studentStatus;

  const StudentEnrollment({
    required this.enrollmentId,
    required this.registrationDate,
    required this.place,
    required this.counsellorName,
    required this.courseName,
    required this.center,
    required this.courseStartingDate,
    required this.courseDuration,
    required this.enrollmentDate,
    required this.batchId,
    required this.batchNumber,
    required this.instructors,
    required this.courseStatus,
    required this.paymentPlanType,
    required this.customInstallments,
    required this.advanceAmount,
    required this.totalFee,
    required this.discountAmount,
    required this.discountedFee,
    required this.paidAmount,
    required this.pendingAmount,
    required this.secondPayment,
    required this.thirdPayment,
    required this.classEndDate,
    required this.paymentStatus,
    required this.studentStatus,
  });

  /// 0.0 → 1.0 for the progress bar
  double get paidProgress {
    final payable = discountedFee > 0 ? discountedFee : totalFee;
    if (payable <= 0) return pendingAmount <= 0 ? 1 : 0;
    return (paidAmount / payable).clamp(0, 1).toDouble();
  }

  List<StudentPayment> get installments =>
      [secondPayment, thirdPayment].whereType<StudentPayment>().toList();

  factory StudentEnrollment.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'] is Map
        ? Map<String, dynamic>.from(json['batch'] as Map)
        : null;

    return StudentEnrollment(
      enrollmentId: json['enrollment_id'] == null
          ? null
          : JsonParse.toInt(json['enrollment_id']),
      registrationDate: JsonParse.toDate(json['registration_date']),
      place: _strOrNull(json['place']),
      counsellorName: JsonParse.toStr(json['counsellor_name']),
      courseName: JsonParse.toStr(json['course_name']),
      center: JsonParse.toStr(json['center']),
      courseStartingDate: JsonParse.toDate(json['course_starting_date']),
      courseDuration: _strOrNull(json['course_duration']),
      enrollmentDate: JsonParse.toDate(json['enrollment_date']),
      batchId: batch == null ? null : JsonParse.toInt(batch['id']),
      batchNumber: batch == null ? null : _strOrNull(batch['batch_number']),
      instructors: JsonParse.toMapList(json['instructors'])
          .map(FacultyDetail.fromJson)
          .toList(),
      courseStatus: JsonParse.toStr(json['course_status'], 'Active'),
      paymentPlanType: _strOrNull(json['payment_plan_type']),
      customInstallments: json['custom_installments'] == null
          ? null
          : JsonParse.toInt(json['custom_installments']),
      advanceAmount: JsonParse.toDouble(json['advance_amount']),
      totalFee: JsonParse.toDouble(json['total_fee']),
      discountAmount: JsonParse.toDouble(json['discount_amount']),
      discountedFee: JsonParse.toDouble(json['discounted_fee']),
      paidAmount: JsonParse.toDouble(json['paid_amount']),
      pendingAmount: JsonParse.toDouble(json['pending_amount']),
      secondPayment: StudentPayment.tryParse(json['second_payment']),
      thirdPayment: StudentPayment.tryParse(json['third_payment']),
      classEndDate: JsonParse.toDate(json['class_end_date']),
      paymentStatus: JsonParse.toStr(json['payment_status'], 'Unpaid'),
      studentStatus: JsonParse.toStr(json['student_status'], 'active'),
    );
  }
}

class StudentProfile {
  final int id;
  final String studentCode;
  final String name;
  final String phone;
  final String email;
  final String center;
  final String status;
  final String counsellor;
  final List<StudentEnrollment> courses;

  const StudentProfile({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.phone,
    required this.email,
    required this.center,
    required this.status,
    required this.counsellor,
    required this.courses,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
        id: JsonParse.toInt(json['id']),
        studentCode: JsonParse.toStr(json['student_id']),
        name: JsonParse.toStr(json['student_name']),
        phone: JsonParse.toStr(json['phone_number']),
        email: JsonParse.toStr(json['email']),
        center: JsonParse.toStr(json['center']),
        status: JsonParse.toStr(json['status'], 'active'),
        counsellor: JsonParse.toStr(json['counsellor']),
        courses: JsonParse.toMapList(json['courses'])
            .map(StudentEnrollment.fromJson)
            .toList(),
      );
}