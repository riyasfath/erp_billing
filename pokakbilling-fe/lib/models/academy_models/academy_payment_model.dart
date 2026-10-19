// Payment data for the Academy module.
//
// One [AcademyPaymentModel] = one admitted student's fee record.
// A one-time (full) payment is stored as a single installment, so receipts and
// installment plans share the same shape.

enum AcademyPayMode { cash, upi, card, bank }

AcademyPayMode acadPayModeFrom(String? v) {
  switch ((v ?? '').toLowerCase()) {
    case 'upi':
      return AcademyPayMode.upi;
    case 'card':
      return AcademyPayMode.card;
    case 'bank':
    case 'bank_transfer':
    case 'neft':
      return AcademyPayMode.bank;
    default:
      return AcademyPayMode.cash;
  }
}

String acadPayModeLabel(AcademyPayMode m) {
  switch (m) {
    case AcademyPayMode.upi:
      return 'UPI';
    case AcademyPayMode.card:
      return 'Card';
    case AcademyPayMode.bank:
      return 'Bank';
    case AcademyPayMode.cash:
      return 'Cash';
  }
}

DateTime? _date(dynamic v) =>
    v == null || v.toString().isEmpty ? null : DateTime.tryParse(v.toString());

double _num(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0;

class AcademyInstallment {
  final int number;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? receiptNo;
  final AcademyPayMode? mode;

  const AcademyInstallment({
    required this.number,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.receiptNo,
    this.mode,
  });

  bool get isPaid => paidDate != null;

  bool get isOverdue {
    if (isPaid) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(today);
  }

  factory AcademyInstallment.fromJson(Map<String, dynamic> j) =>
      AcademyInstallment(
        number: (j['number'] ?? j['installment_no'] ?? 1) as int,
        amount: _num(j['amount']),
        dueDate: _date(j['due_date']) ?? DateTime.now(),
        paidDate: _date(j['paid_date']),
        receiptNo: j['receipt_no']?.toString(),
        mode: j['mode'] == null ? null : acadPayModeFrom(j['mode'].toString()),
      );
}

class AcademyPaymentModel {
  final int id;
  final String studentName;
  final String phone;
  final String courseName;
  final bool isInstallmentPlan;
  final double totalFee;
  final List<AcademyInstallment> installments;

  const AcademyPaymentModel({
    required this.id,
    required this.studentName,
    required this.phone,
    required this.courseName,
    required this.isInstallmentPlan,
    required this.totalFee,
    required this.installments,
  });

  double get paidAmount =>
      installments.where((i) => i.isPaid).fold<double>(0, (s, i) => s + i.amount);

  double get balance =>
      (totalFee - paidAmount).clamp(0.0, double.infinity).toDouble();

  double get overdueAmount =>
      installments.where((i) => i.isOverdue).fold<double>(0, (s, i) => s + i.amount);

  int get paidCount => installments.where((i) => i.isPaid).length;

  bool get isFullyPaid => balance <= 0;

  bool get hasOverdue => installments.any((i) => i.isOverdue);

  double get progress =>
      totalFee <= 0 ? 0 : (paidAmount / totalFee).clamp(0.0, 1.0).toDouble();

  AcademyInstallment? get nextDue {
    for (final i in installments) {
      if (!i.isPaid) return i;
    }
    return null;
  }

  /// 'Paid' | 'Overdue' | 'Partial'
  String get statusLabel =>
      isFullyPaid ? 'Paid' : (hasOverdue ? 'Overdue' : 'Partial');

  factory AcademyPaymentModel.fromJson(Map<String, dynamic> j) =>
      AcademyPaymentModel(
        id: (j['id'] ?? 0) as int,
        studentName: (j['student_name'] ?? j['full_name'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
        isInstallmentPlan:
            (j['plan_type'] ?? '').toString().toLowerCase() == 'installment',
        totalFee: _num(j['total_fee']),
        installments: ((j['installments'] as List?) ?? [])
            .map((e) => AcademyInstallment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A single paid transaction, shown in the Receipts tab.
class AcademyReceipt {
  final AcademyPaymentModel payment;
  final AcademyInstallment installment;
  const AcademyReceipt(this.payment, this.installment);

  String get receiptNo => installment.receiptNo ?? '—';
  double get amount => installment.amount;
  DateTime get date => installment.paidDate!;
  AcademyPayMode get mode => installment.mode ?? AcademyPayMode.cash;
}