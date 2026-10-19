/// Models for the Academy Admission Dashboard.

class AcademyRegistration {
  final String regId;
  final String name;
  final String email;
  final String phone;
  final String course;
  final String counsellor;
  final String courseType; // online | offline | recorded
  final String source;
  final DateTime date;

  const AcademyRegistration({
    required this.regId,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.counsellor,
    required this.courseType,
    required this.source,
    required this.date,
  });

  factory AcademyRegistration.fromJson(Map<String, dynamic> j) =>
      AcademyRegistration(
        regId: '${j['reg_id'] ?? j['id'] ?? ''}',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        course: j['course'] ?? '',
        counsellor: j['counsellor'] ?? '',
        courseType: j['course_type'] ?? '',
        source: j['source'] ?? '',
        date: DateTime.tryParse('${j['date']}') ?? DateTime.now(),
      );
}

class AcademyAdmission {
  final String studentId;
  final String name;
  final String email;
  final String phone;
  final String course;
  final String counsellor;
  final String courseType;
  final String center;
  final DateTime admissionDate;
  final double totalFee;
  final double paidAmount;

  const AcademyAdmission({
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.counsellor,
    required this.courseType,
    required this.center,
    required this.admissionDate,
    required this.totalFee,
    required this.paidAmount,
  });

  double get balance =>
      (totalFee - paidAmount).clamp(0, double.infinity).toDouble();
  double get paidRatio =>
      totalFee <= 0 ? 0 : (paidAmount / totalFee).clamp(0, 1).toDouble();

  factory AcademyAdmission.fromJson(Map<String, dynamic> j) =>
      AcademyAdmission(
        studentId: '${j['student_id'] ?? ''}',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        phone: j['phone'] ?? '',
        course: j['course'] ?? '',
        counsellor: j['counsellor'] ?? '',
        courseType: j['course_type'] ?? '',
        center: j['center'] ?? '',
        admissionDate:
            DateTime.tryParse('${j['admission_date']}') ?? DateTime.now(),
        totalFee: double.tryParse('${j['total_fee']}') ?? 0,
        paidAmount: double.tryParse('${j['paid_amount']}') ?? 0,
      );
}

class AcademyPayment {
  final String studentId;
  final String name;
  final String email;
  final String course;
  final String counsellor;
  final String courseType;
  final String category; // installment | advance | full
  final String paymentType; // Installment | Advance | Full Payment
  final String status; // Completed | Pending | Failed
  final String transactionId;
  final double amount;
  final DateTime date;

  const AcademyPayment({
    required this.studentId,
    required this.name,
    required this.email,
    required this.course,
    required this.counsellor,
    required this.courseType,
    required this.category,
    required this.paymentType,
    required this.status,
    required this.transactionId,
    required this.amount,
    required this.date,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';

  factory AcademyPayment.fromJson(Map<String, dynamic> j) => AcademyPayment(
        studentId: '${j['student_id'] ?? ''}',
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        course: j['course'] ?? '',
        counsellor: j['counsellor'] ?? '',
        courseType: j['course_type'] ?? '',
        category: j['payment_category'] ?? '',
        paymentType: j['payment_type'] ?? '',
        status: j['status'] ?? 'Pending',
        transactionId: '${j['transaction_id'] ?? ''}',
        amount: double.tryParse('${j['amount']}') ?? 0,
        date: DateTime.tryParse('${j['payment_date']}') ?? DateTime.now(),
      );
}

class CounsellorStat {
  final String name;
  int registrations = 0;
  int admissions = 0;
  double collected = 0;
  CounsellorStat(this.name);
}