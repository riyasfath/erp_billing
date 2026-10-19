import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/academy_hr_model.dart';
import 'package:pokakbilling/models/services/academy/academy_hr_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class AcademyHrViewmodel extends ChangeNotifier {
  // ── counsellors ────────────────────────────────────────────────────────────
  List<AcadCounsellor> counsellors = [];
  bool counsellorsLoading = false;
  bool counsellorsLoaded = false;

  // ── conversion report ──────────────────────────────────────────────────────
  AcadCounsellor? selected;
  late DateTime start;
  late DateTime end;
  AcadConversion? conversion;
  bool conversionLoading = false;
  String? conversionError;
  bool submitting = false;

  // ── HR submissions ─────────────────────────────────────────────────────────
  List<AcadSubmission> submissions = [];
  bool submissionsLoading = false;
  bool submissionsLoaded = false;
  String? submissionsError;

  // ── detail ─────────────────────────────────────────────────────────────────
  AcadSubmissionDetail? detail;
  bool detailLoading = false;
  String? detailError;
  bool actionLoading = false;

  AcademyHrViewmodel() {
    final n = DateTime.now();
    start = DateTime(n.year, n.month, 1);
    end = DateTime(n.year, n.month, n.day);
  }

  void clearData() {
    counsellors = [];
    counsellorsLoaded = false;
    selected = null;
    conversion = null;
    conversionError = null;
    submissions = [];
    submissionsLoaded = false;
    submissionsError = null;
    detail = null;
    detailError = null;
    notifyListeners();
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  // ── counsellors ────────────────────────────────────────────────────────────
  Future<void> loadCounsellors({bool force = false}) async {
    if (counsellorsLoading || (counsellorsLoaded && !force)) return;
    counsellorsLoading = true;
    notifyListeners();
    try {
      counsellors = await AcademyHrService.counsellors();
      counsellorsLoaded = true;
    } catch (e) {
      debugPrint('loadCounsellors: $e');
      conversionError = _msg(e);
    } finally {
      counsellorsLoading = false;
      notifyListeners();
    }
  }

  // ── conversion ─────────────────────────────────────────────────────────────
  void selectCounsellor(AcadCounsellor c) {
    selected = c;
    loadConversion();
  }

  void setStart(DateTime d) {
    start = DateTime(d.year, d.month, d.day);
    if (start.isAfter(end)) end = start;
    loadConversion();
  }

  void setEnd(DateTime d) {
    end = DateTime(d.year, d.month, d.day);
    if (end.isBefore(start)) start = end;
    loadConversion();
  }

  Future<void> loadConversion() async {
    final c = selected;
    if (c == null) {
      notifyListeners();
      return;
    }
    conversionLoading = true;
    conversionError = null;
    notifyListeners();
    try {
      conversion = await AcademyHrService.conversion(
          counsellorId: c.id, start: start, end: end);
    } catch (e) {
      debugPrint('loadConversion: $e');
      conversion = null;
      conversionError = _msg(e);
    } finally {
      conversionLoading = false;
      notifyListeners();
    }
  }

  Future<void> proceedToHr({
    required BuildContext context,
    required String periodLabel,
    required String remarks,
  }) async {
    final c = selected;
    if (c == null) return;
    submitting = true;
    notifyListeners();

    final err = await AcademyHrService.proceedToHr(
      counsellorId: c.id,
      start: start,
      end: end,
      periodLabel: periodLabel,
      remarks: remarks,
    );

    submitting = false;
    notifyListeners();
    if (!context.mounted) return;

    if (err == null) {
      showSuccessMessage(context, 'Submitted to HR successfully!');
      await loadConversion();
      fetchSubmissions();
    } else {
      showOverlayError(context, err);
    }
  }

  // ── submissions ────────────────────────────────────────────────────────────
  Future<void> fetchSubmissions() async {
    if (submissionsLoading) return;
    submissionsLoading = true;
    submissionsError = null;
    notifyListeners();
    try {
      submissions = await AcademyHrService.submissions();
      submissionsLoaded = true;
    } catch (e) {
      debugPrint('fetchSubmissions: $e');
      submissionsError = _msg(e);
    } finally {
      submissionsLoading = false;
      notifyListeners();
    }
  }

  int get pendingCount => submissions.where((s) => s.isPending).length;
  int get approvedCount => submissions.where((s) => s.isApproved).length;
  int get rejectedCount => submissions.where((s) => s.isRejected).length;

  // ── detail ─────────────────────────────────────────────────────────────────
  Future<void> loadDetail(int id, {bool silent = false}) async {
    if (!silent) {
      detail = null;
      detailLoading = true;
    }
    detailError = null;
    notifyListeners();
    try {
      detail = await AcademyHrService.submissionDetail(id);
    } catch (e) {
      debugPrint('loadDetail: $e');
      detailError = _msg(e);
    } finally {
      detailLoading = false;
      notifyListeners();
    }
  }

  Future<void> review({
    required BuildContext context,
    required int id,
    required String action, // approved | rejected
    required String remarks,
  }) async {
    actionLoading = true;
    notifyListeners();

    final err = await AcademyHrService.review(
        id: id, action: action, remarks: remarks);

    actionLoading = false;
    notifyListeners();
    if (!context.mounted) return;

    if (err == null) {
      showSuccessMessage(
          context,
          action == 'approved'
              ? 'Submission approved'
              : 'Submission rejected');
      await loadDetail(id, silent: true);
      fetchSubmissions();
    } else {
      showOverlayError(context, err);
    }
  }
}