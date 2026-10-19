import 'package:flutter/foundation.dart';
import 'package:pokakbilling/models/academy_models/academy_payment_model.dart';

class AcademyPaymentViewmodel extends ChangeNotifier {
  List<AcademyPaymentModel> _payments = [];
  bool _loading = false;
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<AcademyPaymentModel> get payments => _payments;
  bool get getLoader => _loading;

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();
    try {
      // TODO: replace with your API call, e.g.
      // final res = await ApiService.get('/academy/payments');
      // _payments = (res['data'] as List)
      //     .map((e) => AcademyPaymentModel.fromJson(e))
      //     .toList();
      await Future.delayed(const Duration(milliseconds: 350));
      _payments = _sampleData();
    } catch (e) {
      debugPrint('AcademyPaymentViewmodel.fetchAll: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  AcademyPaymentModel? getById(int id) {
    for (final p in _payments) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ── Totals ────────────────────────────────────────────────────────────────
  double get totalFee => _payments.fold<double>(0, (s, p) => s + p.totalFee);
  double get totalCollected => _payments.fold<double>(0, (s, p) => s + p.paidAmount);
  double get totalDue => _payments.fold<double>(0, (s, p) => s + p.balance);
  double get overdueAmount => _payments.fold<double>(0, (s, p) => s + p.overdueAmount);

  double get collectionRate =>
      totalFee <= 0 ? 0 : (totalCollected / totalFee).clamp(0.0, 1.0).toDouble();

  int get installmentPlanCount =>
      _payments.where((p) => p.isInstallmentPlan).length;
  int get fullyPaidCount => _payments.where((p) => p.isFullyPaid).length;
  int get overdueCount => _payments.where((p) => p.hasOverdue).length;

  List<AcademyPaymentModel> get installmentPlans =>
      _payments.where((p) => p.isInstallmentPlan).toList();

  /// Every paid transaction, newest first.
  List<AcademyReceipt> get receipts {
    final list = <AcademyReceipt>[];
    for (final p in _payments) {
      for (final i in p.installments) {
        if (i.isPaid) list.add(AcademyReceipt(p, i));
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // ── Sample data (remove once the API is connected) ────────────────────────
  List<AcademyPaymentModel> _sampleData() {
    final now = DateTime.now();
    DateTime d(int days) => now.add(Duration(days: days));

    return [
      AcademyPaymentModel(
        id: 1,
        studentName: 'Arjun Menon',
        phone: '98470 12345',
        courseName: 'Flutter Development',
        isInstallmentPlan: false,
        totalFee: 25000,
        installments: [
          AcademyInstallment(
              number: 1,
              amount: 25000,
              dueDate: d(-20),
              paidDate: d(-20),
              receiptNo: 'RCP-1001',
              mode: AcademyPayMode.upi),
        ],
      ),
      AcademyPaymentModel(
        id: 2,
        studentName: 'Fathima Rahman',
        phone: '90371 55120',
        courseName: 'Data Science with Python',
        isInstallmentPlan: true,
        totalFee: 45000,
        installments: [
          AcademyInstallment(
              number: 1,
              amount: 15000,
              dueDate: d(-45),
              paidDate: d(-45),
              receiptNo: 'RCP-1002',
              mode: AcademyPayMode.bank),
          AcademyInstallment(
              number: 2,
              amount: 15000,
              dueDate: d(-15),
              paidDate: d(-14),
              receiptNo: 'RCP-1009',
              mode: AcademyPayMode.upi),
          AcademyInstallment(number: 3, amount: 15000, dueDate: d(15)),
        ],
      ),
      AcademyPaymentModel(
        id: 3,
        studentName: 'Rahul Krishnan',
        phone: '94460 77881',
        courseName: 'Full Stack Web',
        isInstallmentPlan: true,
        totalFee: 36000,
        installments: [
          AcademyInstallment(
              number: 1,
              amount: 12000,
              dueDate: d(-60),
              paidDate: d(-60),
              receiptNo: 'RCP-0994',
              mode: AcademyPayMode.cash),
          AcademyInstallment(number: 2, amount: 12000, dueDate: d(-10)),
          AcademyInstallment(number: 3, amount: 12000, dueDate: d(20)),
        ],
      ),
      AcademyPaymentModel(
        id: 4,
        studentName: 'Sneha Joseph',
        phone: '97455 30219',
        courseName: 'UI/UX Design',
        isInstallmentPlan: true,
        totalFee: 30000,
        installments: [
          AcademyInstallment(
              number: 1,
              amount: 10000,
              dueDate: d(-50),
              paidDate: d(-50),
              receiptNo: 'RCP-0998',
              mode: AcademyPayMode.card),
          AcademyInstallment(
              number: 2,
              amount: 10000,
              dueDate: d(-20),
              paidDate: d(-21),
              receiptNo: 'RCP-1004',
              mode: AcademyPayMode.upi),
          AcademyInstallment(
              number: 3,
              amount: 10000,
              dueDate: d(-2),
              paidDate: d(-3),
              receiptNo: 'RCP-1012',
              mode: AcademyPayMode.upi),
        ],
      ),
      AcademyPaymentModel(
        id: 5,
        studentName: 'Vishnu Prasad',
        phone: '81290 44567',
        courseName: 'Machine Learning',
        isInstallmentPlan: false,
        totalFee: 40000,
        installments: [
          AcademyInstallment(
              number: 1,
              amount: 40000,
              dueDate: d(-5),
              paidDate: d(-5),
              receiptNo: 'RCP-1011',
              mode: AcademyPayMode.bank),
        ],
      ),
      AcademyPaymentModel(
        id: 6,
        studentName: 'Anjali Nair',
        phone: '95620 18834',
        courseName: 'Digital Marketing',
        isInstallmentPlan: true,
        totalFee: 20000,
        installments: [
          AcademyInstallment(number: 1, amount: 10000, dueDate: d(-4)),
          AcademyInstallment(number: 2, amount: 10000, dueDate: d(26)),
        ],
      ),
    ];
  }
}