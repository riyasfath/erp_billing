// Models for the Academy reports API
// (registrations / admissions / payments / summary).

String _s(dynamic v) => v == null ? '' : v.toString();
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse(_s(v)) ?? 0;
int _i(dynamic v) => v is int ? v : int.tryParse(_s(v)) ?? 0;
DateTime? _dt(dynamic v) => DateTime.tryParse(_s(v))?.toLocal();
String _nested(dynamic v, String key) => v is Map ? _s(v[key]) : '';

// ── Label helpers ────────────────────────────────────────────────────────────
String acadMethodLabel(String? m) {
  switch ((m ?? '').toLowerCase()) {
    case 'upi':
      return 'UPI';
    case 'card':
      return 'Card';
    case 'bank_transfer':
    case 'bank':
    case 'neft':
      return 'Bank';
    case 'cash':
      return 'Cash';
    case '':
      return '—';
    default:
      return m![0].toUpperCase() + m.substring(1);
  }
}

String acadCategoryLabel(String c) {
  switch (c) {
    case 'advance':
      return 'Advance';
    case 'installment':
      return 'Installment';
    case 'slot_amount':
      return 'Slot Amount';
    case 'admission_first_payment':
      return 'First Payment';
    default:
      return c.isEmpty ? 'Payment' : c.replaceAll('_', ' ');
  }
}

// ── Registration ─────────────────────────────────────────────────────────────
class AcadRegistration {
  final int id;
  final String name, email, phone, course, counsellor;
  final DateTime? date;
  final bool hasSlot;
  final double slotAmount;

  const AcadRegistration({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.counsellor,
    required this.date,
    required this.hasSlot,
    required this.slotAmount,
  });

  String get code => '#REG-$id';

  factory AcadRegistration.fromJson(Map<String, dynamic> j) {
    final slot = j['slot_payment'];
    return AcadRegistration(
      id: _i(j['id']),
      name: _s(j['name']),
      email: _s(j['email']),
      phone: _s(j['phone']),
      course: _nested(j['course'], 'title'),
      counsellor: _nested(j['counsellor'], 'name'),
      date: _dt(j['registration_date']),
      hasSlot: slot != null,
      slotAmount: slot is Map ? _d(slot['amount']) : (slot == null ? 0 : _d(slot)),
    );
  }
}

// ── Admission ────────────────────────────────────────────────────────────────
class AcadPaymentInfo {
  final double amount;
  final String method, transactionId, type;
  final DateTime? date;
  const AcadPaymentInfo({
    required this.amount,
    required this.method,
    required this.transactionId,
    required this.type,
    required this.date,
  });

  factory AcadPaymentInfo.fromJson(Map<String, dynamic> j) => AcadPaymentInfo(
        amount: _d(j['amount']),
        method: _s(j['payment_method']),
        transactionId: _s(j['transaction_id']),
        type: _s(j['payment_type']),
        date: _dt(j['payment_date']),
      );
}

class AcadAdmission {
  final int id;
  final String studentId, name, email, phone, course, counsellor;
  final DateTime? date;
  final AcadPaymentInfo? payment;

  const AcadAdmission({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.counsellor,
    required this.date,
    required this.payment,
  });

  bool get hasPayment => payment != null;

  factory AcadAdmission.fromJson(Map<String, dynamic> j) => AcadAdmission(
        id: _i(j['id']),
        studentId: _s(j['student_id']),
        name: _s(j['name']),
        email: _s(j['email']),
        phone: _s(j['phone']),
        course: _nested(j['course'], 'title'),
        counsellor: _nested(j['counsellor'], 'name'),
        date: _dt(j['admission_date']),
        payment: j['payment'] is Map
            ? AcadPaymentInfo.fromJson(
                Map<String, dynamic>.from(j['payment'] as Map))
            : null,
      );
}

// ── Payment transaction ──────────────────────────────────────────────────────
class AcadPayment {
  final String id, category, studentId, name, email, phone, course, counsellor;
  final String? method;
  final String transactionId, type;
  final double amount;
  final DateTime? date;

  const AcadPayment({
    required this.id,
    required this.category,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.counsellor,
    required this.method,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.date,
  });

  bool get isSlot => category == 'slot_amount';

  factory AcadPayment.fromJson(Map<String, dynamic> j) => AcadPayment(
        id: _s(j['id']),
        category: _s(j['payment_category']),
        studentId: _s(j['student_id']),
        name: _s(j['payer_name']),
        email: _s(j['email']),
        phone: _s(j['phone']),
        course: _nested(j['course'], 'title'),
        counsellor: _nested(j['counsellor'], 'name'),
        method: j['payment_method'] == null ? null : _s(j['payment_method']),
        transactionId: _s(j['transaction_id']),
        type: _s(j['payment_type']),
        amount: _d(j['amount']),
        date: _dt(j['payment_date']),
      );
}

// ── Summary ──────────────────────────────────────────────────────────────────
class AcadSummary {
  final int totalRegistrations,
      totalAdmissions,
      totalPayments,
      pendingPayments,
      todayRegistrations,
      todayAdmissions;
  final double amountCollected, conversionRate;
  final String registrationsSub, admissionsSub, paymentsSub, pendingSub;

  const AcadSummary({
    this.totalRegistrations = 0,
    this.totalAdmissions = 0,
    this.totalPayments = 0,
    this.pendingPayments = 0,
    this.todayRegistrations = 0,
    this.todayAdmissions = 0,
    this.amountCollected = 0,
    this.conversionRate = 0,
    this.registrationsSub = '',
    this.admissionsSub = '',
    this.paymentsSub = '',
    this.pendingSub = '',
  });

  factory AcadSummary.fromJson(Map<String, dynamic> j) {
    dynamic val(String k) {
      final m = j[k];
      if (m is Map) return m['value'];
      final s = j['summary'];
      return s is Map ? s[k] : null;
    }

    String sub(String k) {
      final m = j[k];
      return m is Map ? _s(m['subtext']) : '';
    }

    return AcadSummary(
      totalRegistrations: _i(val('total_registrations')),
      totalAdmissions: _i(val('total_admissions')),
      totalPayments: _i(val('total_payments')),
      pendingPayments: _i(val('pending_payments')),
      todayRegistrations: _i(val('today_registrations')),
      todayAdmissions: _i(val('today_admissions')),
      amountCollected: _d(val('total_amount_collected')),
      conversionRate: _d(val('conversion_rate')),
      registrationsSub: sub('total_registrations'),
      admissionsSub: sub('total_admissions'),
      paymentsSub: sub('total_payments'),
      pendingSub: sub('pending_payments'),
    );
  }
}