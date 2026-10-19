import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

enum StudentStatusFilter { all, active, inactive, completed }

class StudentViewModel extends ChangeNotifier {
  StudentViewModel(this._service) {
    load();
  }

  final StudentService _service;

  List<StudentListItem> _all = [];
  bool loading = true;
  String? error;

  // Filters
  String query = '';
  String? center;
  String? course;
  String? batch;
  StudentStatusFilter status = StudentStatusFilter.all;

  // ---------- Stats ----------
  int get totalCount => _all.length;
  int get activeCount => _count('active');
  int get inactiveCount => _count('inactive');
  int get completedCount => _count('completed');

  int _count(String s) =>
      _all.where((e) => e.status.toLowerCase() == s).length;

  // ---------- Dropdown options ----------
  List<String> get centers => _unique(_all.map((s) => s.centerName));
  List<String> get courseNames => _unique(_all.expand((s) => s.courses));
  List<String> get batches => _unique(_all.map((s) => s.batchNumber));

  static List<String> _unique(Iterable<String?> values) {
    final list = values
        .whereType<String>()
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  // ---------- Filtered list ----------
  List<StudentListItem> get students {
    final q = query.trim().toLowerCase();
    return _all.where((s) {
      if (status != StudentStatusFilter.all &&
          s.status.toLowerCase() != status.name) {
        return false;
      }
      if (center != null && s.centerName.trim() != center) return false;
      if (course != null && !s.courses.contains(course)) return false;
      if (batch != null && s.batchNumber?.trim() != batch) return false;
      if (q.isEmpty) return true;
      return s.fullName.toLowerCase().contains(q) ||
          s.studentCode.toLowerCase().contains(q) ||
          s.phone.toLowerCase().contains(q) ||
          s.loginEmail.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          s.courseTitle.toLowerCase().contains(q);
    }).toList();
  }

  bool get hasFilters =>
      query.trim().isNotEmpty ||
      center != null ||
      course != null ||
      batch != null ||
      status != StudentStatusFilter.all;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _service.getStudents();
      if (center != null && !centers.contains(center)) center = null;
      if (course != null && !courseNames.contains(course)) course = null;
      if (batch != null && !batches.contains(batch)) batch = null;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load students. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  void search(String q) {
    query = q;
    notifyListeners();
  }

  void setCenter(String? v) {
    center = v;
    notifyListeners();
  }

  void setCourse(String? v) {
    course = v;
    notifyListeners();
  }

  void setBatch(String? v) {
    batch = v;
    notifyListeners();
  }

  void setStatus(StudentStatusFilter v) {
    status = v;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    center = null;
    course = null;
    batch = null;
    status = StudentStatusFilter.all;
    notifyListeners();
  }
}