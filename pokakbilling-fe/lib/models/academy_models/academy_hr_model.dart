// Models for counsellor conversion + HR submission flow.

String _s(dynamic v) => v == null ? '' : v.toString();
double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse(_s(v)) ?? 0;
int _i(dynamic v) => v is int ? v : int.tryParse(_s(v)) ?? 0;
DateTime? _dt(dynamic v) => DateTime.tryParse(_s(v))?.toLocal();
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

const _fullMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

/// yyyy-MM-dd for API
String acadApiDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "October 2026"
String acadMonthYear(DateTime d) => '${_fullMonths[d.month - 1]} ${d.year}';

// ── Counsellor ───────────────────────────────────────────────────────────────
class AcadCounsellor {
  final int id;
  final String name, email, phone, designation;
  const AcadCounsellor({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.designation = '',
  });

  factory AcadCounsellor.fromJson(Map<String, dynamic> j) => AcadCounsellor(
        id: _i(j['id']),
        name: _s(j['name']),
        email: _s(j['email']),
        phone: _s(j['phone']),
        designation: _s(j['designation']),
      );
}

// ── Summary block ────────────────────────────────────────────────────────────
class AcadConvSummary {
  final int totalRecords, newAdmissions, newRegistrations, totalStudents;
  final double totalCollected;
  const AcadConvSummary({
    this.totalRecords = 0,
    this.newAdmissions = 0,
    this.newRegistrations = 0,
    this.totalStudents = 0,
    this.totalCollected = 0,
  });

  factory AcadConvSummary.fromJson(dynamic raw) {
    final j = _m(raw);
    return AcadConvSummary(
      totalRecords: _i(j['total_records']),
      newAdmissions: _i(j['new_admissions_count']),
      newRegistrations: _i(j['new_registrations_count']),
      totalStudents: _i(j['total_students']),
      totalCollected: _d(j['total_payment_collected']),
    );
  }
}

// ── Record (admission / registration) ────────────────────────────────────────
class AcadConvPayment {
  final double amount;
  final String method, type, label;
  final DateTime? date;
  const AcadConvPayment({
    required this.amount,
    required this.method,
    required this.type,
    required this.label,
    required this.date,
  });

  factory AcadConvPayment.fromJson(Map<String, dynamic> j) => AcadConvPayment(
        amount: _d(j['amount']),
        method: _s(j['payment_method']),
        type: _s(j['payment_type']),
        label: _s(j['payment_label']),
        date: _dt(j['payment_date']),
      );
}

class AcadConvRecord {
  final int id;
  final String recordType, studentId, name, email, phone, course;
  final DateTime? date;
  final AcadConvPayment? payment;

  const AcadConvRecord({
    required this.id,
    required this.recordType,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.course,
    required this.date,
    required this.payment,
  });

  bool get isAdmission => recordType == 'admission';

  factory AcadConvRecord.fromJson(Map<String, dynamic> j) {
    final p = j['payment'] ?? j['first_payment'];
    return AcadConvRecord(
      id: _i(j['id']),
      recordType: _s(j['record_type']),
      studentId: _s(j['student_id']),
      name: _s(j['name']),
      email: _s(j['email']),
      phone: _s(j['phone']),
      course: _s(j['course']),
      date: _dt(j['created_at']),
      payment: p is Map ? AcadConvPayment.fromJson(_m(p)) : null,
    );
  }
}

List<AcadConvRecord> _records(dynamic raw) => raw is List
    ? raw
        .whereType<Map>()
        .map((e) => AcadConvRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList()
    : <AcadConvRecord>[];

// ── Conversion report (GET counsellors/{id}/conversion/) ─────────────────────
class AcadConversion {
  final AcadCounsellor counsellor;
  final AcadConvSummary summary;
  final String? submissionStatus;
  final List<AcadConvRecord> records;

  const AcadConversion({
    required this.counsellor,
    required this.summary,
    required this.submissionStatus,
    required this.records,
  });

  factory AcadConversion.fromJson(Map<String, dynamic> j) {
    final st = j['submission_status'];
    String? status;
    if (st is String && st.isNotEmpty) {
      status = st;
    } else if (st is Map && _s(st['status']).isNotEmpty) {
      status = _s(st['status']);
    }
    return AcadConversion(
      counsellor: AcadCounsellor.fromJson(_m(j['counsellor'])),
      summary: AcadConvSummary.fromJson(j['summary']),
      submissionStatus: status,
      records: _records(j['records']),
    );
  }
}

// ── HR submission ────────────────────────────────────────────────────────────
class AcadSubmission {
  final int id, counsellorId;
  final String counsellorName, periodLabel, status, remarks;
  final String submittedByName, reviewedByName;
  final DateTime? startDate, endDate, submittedAt, reviewedAt;
  final AcadConvSummary summary;

  const AcadSubmission({
    required this.id,
    required this.counsellorId,
    required this.counsellorName,
    required this.periodLabel,
    required this.status,
    required this.remarks,
    required this.submittedByName,
    required this.reviewedByName,
    required this.startDate,
    required this.endDate,
    required this.submittedAt,
    required this.reviewedAt,
    required this.summary,
  });

  bool get isPending => status == 'submitted';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory AcadSubmission.fromJson(Map<String, dynamic> j) => AcadSubmission(
        id: _i(j['id']),
        counsellorId: _i(j['counsellor']),
        counsellorName: _s(j['counsellor_name']),
        periodLabel: _s(j['period_label']),
        status: _s(j['status']),
        remarks: _s(j['remarks']),
        submittedByName: _s(j['submitted_by_name']),
        reviewedByName: _s(j['reviewed_by_name']),
        startDate: _dt(j['start_date']),
        endDate: _dt(j['end_date']),
        submittedAt: _dt(j['submitted_at']),
        reviewedAt: _dt(j['reviewed_at']),
        summary: AcadConvSummary.fromJson(j['summary']),
      );
}

class AcadSubmissionDetail {
  final AcadSubmission submission;
  final AcadCounsellor counsellor;
  final AcadConvSummary summary;
  final List<AcadConvRecord> records;

  const AcadSubmissionDetail({
    required this.submission,
    required this.counsellor,
    required this.summary,
    required this.records,
  });

  factory AcadSubmissionDetail.fromJson(Map<String, dynamic> j) =>
      AcadSubmissionDetail(
        submission: AcadSubmission.fromJson(_m(j['submission'])),
        counsellor: AcadCounsellor.fromJson(_m(j['counsellor'])),
        summary: AcadConvSummary.fromJson(j['summary']),
        records: _records(j['records']),
      );
}