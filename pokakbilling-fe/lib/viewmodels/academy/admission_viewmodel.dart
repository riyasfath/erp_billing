import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/admission_model.dart';

/// Academy Admission Dashboard view-model.
///
/// Uses DUMMY data for now — replace the body of [fetchAll] with your
/// "Live Admissions API" call and map the JSON with the `fromJson` factories.
class AdmissionViewmodel extends ChangeNotifier {
  bool loading = false;

  List<AcademyRegistration> _registrations = [];
  List<AcademyAdmission> _admissions = [];
  List<AcademyPayment> _payments = [];

  // ── Filters ──
  String? counsellorFilter;
  String? typeFilter;
  String? courseFilter;
  String? paymentTypeFilter;
  String search = '';
  late DateTime startDate;
  late DateTime endDate;

  AdmissionViewmodel() {
    _defaultRange();
  }

  void _defaultRange() {
    final n = DateUtils.dateOnly(DateTime.now());
    startDate = DateTime(n.year, n.month, 1);
    endDate = n;
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Future<void> fetchAll() async {
    loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateUtils.dateOnly(DateTime.now());
    _registrations = _dummyRegistrations(now);
    _admissions = _dummyAdmissions(now);
    _payments = _dummyPayments(now);
    loading = false;
    notifyListeners();
  }

  // ── Filter setters ─────────────────────────────────────────────────────────
  void setCounsellor(String? v) {
    counsellorFilter = v;
    notifyListeners();
  }

  void setType(String? v) {
    typeFilter = v;
    notifyListeners();
  }

  void setCourse(String? v) {
    courseFilter = v;
    notifyListeners();
  }

  void setPaymentType(String? v) {
    paymentTypeFilter = v;
    notifyListeners();
  }

  void setSearch(String v) {
    search = v.trim();
    notifyListeners();
  }

  void setStartDate(DateTime d) {
    startDate = DateUtils.dateOnly(d);
    if (startDate.isAfter(endDate)) endDate = startDate;
    notifyListeners();
  }

  void setEndDate(DateTime d) {
    endDate = DateUtils.dateOnly(d);
    if (endDate.isBefore(startDate)) startDate = endDate;
    notifyListeners();
  }

  void resetFilters() {
    counsellorFilter = typeFilter = courseFilter = paymentTypeFilter = null;
    search = '';
    _defaultRange();
    notifyListeners();
  }

  // ── Options ────────────────────────────────────────────────────────────────
  Map<String, String> _distinct(Iterable<String> v) {
    final list = v.where((e) => e.trim().isNotEmpty).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {for (final e in list) e: e};
  }

  Map<String, String> get counsellorOptions => _distinct([
        ..._registrations.map((e) => e.counsellor),
        ..._admissions.map((e) => e.counsellor),
        ..._payments.map((e) => e.counsellor),
      ]);

  Map<String, String> get courseOptions => _distinct([
        ..._registrations.map((e) => e.course),
        ..._admissions.map((e) => e.course),
        ..._payments.map((e) => e.course),
      ]);

  Map<String, String> get paymentTypeOptions =>
      _distinct(_payments.map((e) => e.paymentType));

  static const Map<String, String> typeOptions = {
    'online': 'Online',
    'offline': 'Offline',
    'recorded': 'Recorded',
  };

  // ── Filtering ──────────────────────────────────────────────────────────────
  bool _inRange(DateTime d) {
    final x = DateUtils.dateOnly(d);
    return !x.isBefore(startDate) && !x.isAfter(endDate);
  }

  bool _match(String counsellor, String course, String type, String hay) {
    if (counsellorFilter != null && counsellor != counsellorFilter) {
      return false;
    }
    if (courseFilter != null && course != courseFilter) return false;
    if (typeFilter != null && type.toLowerCase() != typeFilter) return false;
    if (search.isNotEmpty &&
        !hay.toLowerCase().contains(search.toLowerCase())) {
      return false;
    }
    return true;
  }

  List<AcademyRegistration> get registrations => _registrations
      .where((r) =>
          _inRange(r.date) &&
          _match(r.counsellor, r.course, r.courseType,
              '${r.regId} ${r.name} ${r.phone} ${r.email} ${r.counsellor}'))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<AcademyAdmission> get admissions => _admissions
      .where((a) =>
          _inRange(a.admissionDate) &&
          _match(a.counsellor, a.course, a.courseType,
              '${a.studentId} ${a.name} ${a.phone} ${a.email} ${a.counsellor}'))
      .toList()
    ..sort((a, b) => b.admissionDate.compareTo(a.admissionDate));

  List<AcademyPayment> get payments => _payments
      .where((p) =>
          _inRange(p.date) &&
          (paymentTypeFilter == null || p.paymentType == paymentTypeFilter) &&
          _match(p.counsellor, p.course, p.courseType,
              '${p.studentId} ${p.name} ${p.email} ${p.counsellor} ${p.transactionId}'))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  // ── Stats ──────────────────────────────────────────────────────────────────
  int get totalRegistrations => registrations.length;
  int get totalAdmissions => admissions.length;
  int get successfulPayments => payments.where((p) => p.isCompleted).length;
  int get pendingPayments => payments.where((p) => p.isPending).length;

  double get amountCollected => payments
      .where((p) => p.isCompleted)
      .fold<double>(0, (sum, p) => sum + p.amount);

  double get conversionRate => totalRegistrations == 0
      ? 0
      : (totalAdmissions / totalRegistrations * 100).clamp(0, 100).toDouble();

  int get todayRegistrations {
    final n = DateTime.now();
    return _registrations.where((r) => DateUtils.isSameDay(r.date, n)).length;
  }

  int get todayAdmissions {
    final n = DateTime.now();
    return _admissions
        .where((a) => DateUtils.isSameDay(a.admissionDate, n))
        .length;
  }

  /// This month vs last month registrations (unfiltered).
  double get registrationGrowth {
    final n = DateTime.now();
    final prev = DateTime(n.year, n.month - 1);
    final thisM = _registrations
        .where((r) => r.date.year == n.year && r.date.month == n.month)
        .length;
    final lastM = _registrations
        .where((r) => r.date.year == prev.year && r.date.month == prev.month)
        .length;
    if (lastM == 0) return thisM > 0 ? 100 : 0;
    return (thisM - lastM) / lastM * 100;
  }

  List<CounsellorStat> get counsellorBreakdown {
    final map = <String, CounsellorStat>{};
    CounsellorStat of(String n) => map.putIfAbsent(n, () => CounsellorStat(n));
    for (final r in registrations) {
      of(r.counsellor).registrations++;
    }
    for (final a in admissions) {
      of(a.counsellor).admissions++;
    }
    for (final p in payments.where((p) => p.isCompleted)) {
      of(p.counsellor).collected += p.amount;
    }
    final list = map.values.toList()
      ..sort((a, b) {
        final c = b.collected.compareTo(a.collected);
        return c != 0 ? c : b.registrations.compareTo(a.registrations);
      });
    return list;
  }

  // ── Dummy data ─────────────────────────────────────────────────────────────
  static List<AcademyRegistration> _dummyRegistrations(DateTime now) {
    DateTime d(int ago) => now.subtract(Duration(days: ago));
    return [
      AcademyRegistration(
          regId: 'REG2026101',
          name: 'Jomol K',
          email: 'abcd@gmail.com',
          phone: '9089464625',
          course: 'javaa',
          counsellor: 'Abhal Benny',
          courseType: 'online',
          source: 'Instagram',
          date: d(0)),
      AcademyRegistration(
          regId: 'REG2026100',
          name: 'Fidha Sudheer',
          email: 'fidhaah123@gmail.com',
          phone: '9876543210',
          course: 'digital marketing',
          counsellor: 'Abhal Benny',
          courseType: 'offline',
          source: 'Website',
          date: d(0)),
      AcademyRegistration(
          regId: 'REG2026099',
          name: 'Muhammed ak',
          email: 'aksiyad6369@gmail.com',
          phone: '+919645261264',
          course: 'testing',
          counsellor: 'Alan mathew',
          courseType: 'online',
          source: 'Referral',
          date: d(1)),
      AcademyRegistration(
          regId: 'REG2026098',
          name: 'fuhad saneen',
          email: 'saneenfuhad81@gmail.com',
          phone: '+913456788799',
          course: 'testone',
          counsellor: 'Anfique test',
          courseType: 'recorded',
          source: 'Facebook',
          date: d(2)),
      AcademyRegistration(
          regId: 'REG2026097',
          name: 'aisrya lll',
          email: 'aiswaryasurendran97@gmail.com',
          phone: '+919645261264',
          course: 'data analytics',
          counsellor: 'anaswara dev',
          courseType: 'online',
          source: 'Google',
          date: d(3)),
      AcademyRegistration(
          regId: 'REG2026096',
          name: 'Mhmd Jasim',
          email: 'mhmdjasim123@gmail.com',
          phone: '9847012345',
          course: 'javaa',
          counsellor: 'Alan mathew',
          courseType: 'offline',
          source: 'Walk-in',
          date: d(4)),
      AcademyRegistration(
          regId: 'REG2026095',
          name: 'hidha kk',
          email: 'hidhakk@gmail.com',
          phone: '9567012345',
          course: 'Game Development',
          counsellor: 'Abhal Benny',
          courseType: 'offline',
          source: 'Instagram',
          date: d(5)),
      AcademyRegistration(
          regId: 'REG2026080',
          name: 'Arjun Nair',
          email: 'arjun.nair@gmail.com',
          phone: '9745012345',
          course: 'MEAN Stack test',
          counsellor: 'Shaheem Mahmood',
          courseType: 'online',
          source: 'Website',
          date: d(34)),
      AcademyRegistration(
          regId: 'REG2026079',
          name: 'Sneha Raj',
          email: 'sneharaj@gmail.com',
          phone: '9645098765',
          course: 'data analytics',
          counsellor: 'John Peter',
          courseType: 'online',
          source: 'Referral',
          date: d(40)),
    ];
  }

  static List<AcademyAdmission> _dummyAdmissions(DateTime now) {
    DateTime d(int ago) => now.subtract(Duration(days: ago));
    return [
      AcademyAdmission(
          studentId: 'ST2026072',
          name: 'Mhmd Jasim',
          email: 'mhmdjasim123@gmail.com',
          phone: '9847012345',
          course: 'javaa',
          counsellor: 'Alan mathew',
          courseType: 'offline',
          center: 'Main Campus',
          admissionDate: d(0),
          totalFee: 45000,
          paidAmount: 15000),
      AcademyAdmission(
          studentId: 'ST2026067',
          name: 'hidha kk',
          email: 'hidhakk@gmail.com',
          phone: '9567012345',
          course: 'Game Development',
          counsellor: 'Abhal Benny',
          courseType: 'offline',
          center: 'Main Campus',
          admissionDate: d(2),
          totalFee: 59000,
          paidAmount: 59000),
      AcademyAdmission(
          studentId: 'ST2026058',
          name: 'Arjun Nair',
          email: 'arjun.nair@gmail.com',
          phone: '9745012345',
          course: 'MEAN Stack test',
          counsellor: 'Shaheem Mahmood',
          courseType: 'online',
          center: 'Online Batch',
          admissionDate: d(4),
          totalFee: 30000,
          paidAmount: 10000),
    ];
  }

  static List<AcademyPayment> _dummyPayments(DateTime now) {
    DateTime d(int ago) => now.subtract(Duration(days: ago));
    return [
      AcademyPayment(
          studentId: 'ST2026072',
          name: 'Mhmd Jasim',
          email: 'mhmdjasim123@gmail.com',
          course: 'javaa',
          counsellor: 'Alan mathew',
          courseType: 'offline',
          category: 'installment',
          paymentType: 'Installment',
          status: 'Completed',
          transactionId: 'TXN84512037',
          amount: 15000,
          date: d(0)),
      AcademyPayment(
          studentId: 'ST2026067',
          name: 'hidha kk',
          email: 'hidhakk@gmail.com',
          course: 'Game Development',
          counsellor: 'Abhal Benny',
          courseType: 'offline',
          category: 'installment',
          paymentType: 'Installment',
          status: 'Completed',
          transactionId: 'TXN84512036',
          amount: 29500,
          date: d(0)),
      AcademyPayment(
          studentId: 'ST2026067',
          name: 'hidha kk',
          email: 'hidhakk@gmail.com',
          course: 'Game Development',
          counsellor: 'Abhal Benny',
          courseType: 'offline',
          category: 'installment',
          paymentType: 'Installment',
          status: 'Completed',
          transactionId: 'TXN84512035',
          amount: 29500,
          date: d(0)),
      AcademyPayment(
          studentId: 'ST2026058',
          name: 'Arjun Nair',
          email: 'arjun.nair@gmail.com',
          course: 'MEAN Stack test',
          counsellor: 'Shaheem Mahmood',
          courseType: 'online',
          category: 'advance',
          paymentType: 'Advance',
          status: 'Completed',
          transactionId: 'TXN84511980',
          amount: 10000,
          date: d(4)),
      AcademyPayment(
          studentId: 'ST2026075',
          name: 'Fidha Sudheer',
          email: 'fidhaah123@gmail.com',
          course: 'digital marketing',
          counsellor: 'Abhal Benny',
          courseType: 'offline',
          category: 'advance',
          paymentType: 'Advance',
          status: 'Pending',
          transactionId: 'TXN84512040',
          amount: 5000,
          date: d(0)),
    ];
  }
}