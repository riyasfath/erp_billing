import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/course_item_model.dart';
import '../models/create_course_request_model.dart';
import '../services/course_service.dart';

enum CourseStatusFilter { all, active, inactive }

class CourseViewModel extends ChangeNotifier {
  final CourseService _service;

  CourseViewModel(this._service) {
    load();
  }

  List<CourseItem> _all = [];
  String query = '';
  bool loading = true;
  String? error;

  // Filters
  CourseStatusFilter statusFilter = CourseStatusFilter.all;
  String? department; // null = All Categories

  // Create / delete state
  bool creating = false;
  String? createError;
  final Set<int> deletingIds = {};

  // ---------- Stats (same as web cards) ----------
  int get totalCount => _all.length;
  int get activeCount => _all.where((c) => c.isActive).length;
  int get inactiveCount => totalCount - activeCount;

  /// Unique department names for the "All Categories" dropdown.
  List<String> get departments {
    final list = _all
        .map((c) => c.departmentName.trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  /// Search + status + department applied.
  List<CourseItem> get courses {
    final q = query.trim().toLowerCase();
    return _all.where((c) {
      if (statusFilter == CourseStatusFilter.active && !c.isActive) {
        return false;
      }
      if (statusFilter == CourseStatusFilter.inactive && c.isActive) {
        return false;
      }
      if (department != null &&
          c.departmentName.trim().toLowerCase() !=
              department!.toLowerCase()) {
        return false;
      }
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.departmentName.toLowerCase().contains(q) ||
          c.faculties.any((f) => f.name.toLowerCase().contains(q));
    }).toList();
  }

  bool get hasFilters =>
      query.trim().isNotEmpty ||
      statusFilter != CourseStatusFilter.all ||
      department != null;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      _all = await _service.getCourses();
      // Alphabetical, same as the web
      _all.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      if (department != null && !departments.contains(department)) {
        department = null;
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load courses. Please try again.';
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

  void setStatusFilter(CourseStatusFilter f) {
    statusFilter = f;
    notifyListeners();
  }

  void setDepartment(String? d) {
    department = d;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    statusFilter = CourseStatusFilter.all;
    department = null;
    notifyListeners();
  }

  /// Returns null on success, or an error message.
  Future<String?> deleteCourse(int id) async {
    if (deletingIds.contains(id)) return null;
    deletingIds.add(id);
    notifyListeners();
    try {
      await _service.deleteCourse(id);
      _all.removeWhere((c) => c.id == id);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not delete course. Please try again.';
    } finally {
      deletingIds.remove(id);
      notifyListeners();
    }
  }

  /// Returns true only if the API created the course.
  Future<bool> createCourse(CreateCourseRequest request) async {
    if (creating) return false;
    creating = true;
    createError = null;
    notifyListeners();

    try {
      await _service.createCourse(request);
      await load(); // refresh list + stats
      return true;
    } on ApiException catch (e) {
      createError = e.message;
      return false;
    } catch (_) {
      createError = 'Could not create course. Please try again.';
      return false;
    } finally {
      creating = false;
      notifyListeners();
    }
  }

  void clearCreateError() {
    if (createError == null) return;
    createError = null;
    notifyListeners();
  }
}