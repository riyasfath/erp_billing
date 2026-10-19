import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/academy_model.dart';
import 'package:pokakbilling/models/services/academy/academy_service.dart';

class AcademyViewmodel extends ChangeNotifier {
  bool loading = false;
  bool loaded = false;
  String? error;

  AcadSummary? summary;
  List<AcadRegistration> registrations = [];
  List<AcadAdmission> admissions = [];
  List<AcadPayment> payments = [];

  void clearData() {
    loading = false;
    loaded = false;
    error = null;
    summary = null;
    registrations = [];
    admissions = [];
    payments = [];
    notifyListeners();
  }

  Future<void> fetchAll() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();

    String? firstErr;
    Future<T> safe<T>(Future<T> f, T fallback) async {
      try {
        return await f;
      } catch (e) {
        debugPrint('AcademyViewmodel error: $e');
        firstErr ??= e.toString();
        return fallback;
      }
    }

    final fSum = safe<AcadSummary?>(AcademyService.summary(), summary);
    final fReg = safe(AcademyService.registrations(), registrations);
    final fAdm = safe(AcademyService.admissions(), admissions);
    final fPay = safe(AcademyService.payments(), payments);

    summary = await fSum;
    registrations = await fReg;
    admissions = await fAdm;
    payments = await fPay;

    if (firstErr != null) {
      final e = firstErr!;
      error = e.length > 160 ? '${e.substring(0, 160)}…' : e;
    }
    loaded = true;
    loading = false;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static List<String> distinct(Iterable<String> v) =>
      v.where((e) => e.trim().isNotEmpty).toSet().toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  static bool sameDay(DateTime? d, DateTime n) =>
      d != null && d.year == n.year && d.month == n.month && d.day == n.day;
  static bool _sameMonth(DateTime? d, DateTime n) =>
      d != null && d.year == n.year && d.month == n.month;

  static int _byDateDesc(AcadPayment a, AcadPayment b) =>
      (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000));

  // ── Registration / admission numbers ───────────────────────────────────────
  int get totalRegistrations =>
      summary?.totalRegistrations ?? registrations.length;
  int get pendingRegistrations => registrations.length;
  int get slotPaidRegistrations =>
      registrations.where((r) => r.hasSlot).length;
  int get totalAdmissions => summary?.totalAdmissions ?? admissions.length;
  double get conversionRate => summary?.conversionRate ?? 0;

  int get todayRegistrations =>
      summary?.todayRegistrations ??
      registrations.where((r) => sameDay(r.date, DateTime.now())).length;
  int get todayAdmissions =>
      summary?.todayAdmissions ??
      admissions.where((a) => sameDay(a.date, DateTime.now())).length;

  int get registrationsThisMonth => registrations
      .where((r) => _sameMonth(r.date, DateTime.now()))
      .length;
  int get admissionsThisMonth =>
      admissions.where((a) => _sameMonth(a.date, DateTime.now())).length;

  int get pendingPayments =>
      summary?.pendingPayments ??
      admissions.where((a) => !a.hasPayment).length;

  // ── Receipts (advance / installment / first payment) ───────────────────────
  List<AcadPayment> get receipts =>
      payments.where((p) => !p.isSlot).toList()..sort(_byDateDesc);
  int get receiptCount => receipts.length;
  int get receiptStudentCount =>
      receipts.map((p) => p.studentId).where((e) => e.isNotEmpty).toSet().length;
  int get todayReceipts =>
      receipts.where((p) => sameDay(p.date, DateTime.now())).length;

  // ── Slot bookings ──────────────────────────────────────────────────────────
  List<AcadPayment> get slotPayments =>
      payments.where((p) => p.isSlot).toList()..sort(_byDateDesc);
  int get slotCount => slotPayments.length;
  int get todaySlots =>
      slotPayments.where((p) => sameDay(p.date, DateTime.now())).length;

  int countCategory(String c) => payments.where((p) => p.category == c).length;
}