import 'package:flutter/material.dart';
import 'package:pokakbilling/models/academy_models/form_submission_model.dart';
import 'package:pokakbilling/models/services/academy/form_submission_service.dart';

class FormSubmissionViewmodel extends ChangeNotifier {
  bool getLoader = false;
  List<FormSubmissionModel> submissions = [];

  // Filters
  String searchTerm = '';
  String? typeFilter; // kFormInternship | kFormFreeCourse
  String? admissionFilter; // 'taken' | 'pending'
  String? courseFilter;

  FormSubmissionViewmodel() {
    fetchAll();
  }

  void clearData() {
    submissions = [];
    getLoader = false;
    resetFilters(notify: false);
    notifyListeners();
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  int get totalRegistered => submissions.length;
  int get admissionTaken => submissions.where((s) => s.isConverted).length;
  int get admissionPending => totalRegistered - admissionTaken;
  int get internshipCount =>
      submissions.where((s) => s.formType == kFormInternship).length;
  int get freeCourseCount =>
      submissions.where((s) => s.formType == kFormFreeCourse).length;
  double get conversionRate =>
      totalRegistered == 0 ? 0 : admissionTaken / totalRegistered;
  int get thisMonthCount {
    final now = DateTime.now();
    return submissions.where((s) {
      final d = DateTime.tryParse(s.appliedDate);
      return d != null && d.year == now.year && d.month == now.month;
    }).length;
  }

  // ── Aliases for older screens (fixes "totalCount isn't defined") ───────────
  int get totalCount => totalRegistered;
  int get convertedCount => admissionTaken;
  int get notConvertedCount => admissionPending;

  // ── Filtered list ──────────────────────────────────────────────────────────
  List<FormSubmissionModel> get filtered {
    final q = searchTerm.trim().toLowerCase();
    final list = submissions.where((s) {
      if (q.isNotEmpty &&
          !(s.fullName.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q) ||
              s.phone.toLowerCase().contains(q))) {
        return false;
      }
      if (typeFilter != null && s.formType != typeFilter) return false;
      if (admissionFilter == 'taken' && !s.isConverted) return false;
      if (admissionFilter == 'pending' && s.isConverted) return false;
      if (courseFilter != null && s.courseName != courseFilter) return false;
      return true;
    }).toList();
    list.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    return list;
  }

  List<String> get courseOptions => (submissions
          .where((s) => s.courseName.isNotEmpty)
          .map((s) => s.courseName)
          .toSet()
          .toList()
        ..sort());

  FormSubmissionModel? getById(int id) {
    for (final s in submissions) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ── Filter setters ─────────────────────────────────────────────────────────
  void setSearch(String v) {
    searchTerm = v;
    notifyListeners();
  }

  void setType(String? v) {
    typeFilter = v;
    notifyListeners();
  }

  void setAdmission(String? v) {
    admissionFilter = v;
    notifyListeners();
  }

  void setCourse(String? v) {
    courseFilter = v;
    notifyListeners();
  }

  bool get hasAnyFilter =>
      searchTerm.isNotEmpty ||
      typeFilter != null ||
      admissionFilter != null ||
      courseFilter != null;

  void resetFilters({bool notify = true}) {
    searchTerm = '';
    typeFilter = null;
    admissionFilter = null;
    courseFilter = null;
    if (notify) notifyListeners();
  }

  Future<void> fetchAll() async {
    try {
      getLoader = true;
      notifyListeners();
      submissions = await FormSubmissionService.fetchSubmissions();
    } catch (e) {
      debugPrint('FormSubmissionViewmodel.fetchAll error: $e');
      submissions = [];
    } finally {
      getLoader = false;
      notifyListeners();
    }
  }
}