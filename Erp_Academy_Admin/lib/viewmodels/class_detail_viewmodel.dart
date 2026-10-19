import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

class ClassDetailViewModel extends ChangeNotifier {
  ClassDetailViewModel(this._service, this.item) {
    load();
  }

  final ClassService _service;
  final ClassItem item;

  static const days = ['All', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  ClassDetail? detail;
  bool loading = true;
  String? error;

  String query = '';
  String? course;
  String? batch;
  String day = 'All';

  ClassItem get info => detail?.info ?? item;
  List<ClassSection> get _sections => detail?.sections ?? const [];

  List<String> get courses => _unique(_sections.map((s) => s.course));
  List<String> get batches => _unique(_sections.map((s) => s.batch));

  static List<String> _unique(Iterable<String> v) => v
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  List<ClassSection> get sections {
    final q = query.trim().toLowerCase();
    return _sections.where((s) {
      if (course != null && s.course != course) return false;
      if (batch != null && s.batch != batch) return false;
      if (day != 'All' && !s.runsOn(day)) return false;
      if (q.isEmpty) return true;
      return s.course.toLowerCase().contains(q) ||
          s.batch.toLowerCase().contains(q) ||
          s.time.toLowerCase().contains(q) ||
          s.days.join(' ').toLowerCase().contains(q);
    }).toList();
  }

  bool get hasFilters =>
      query.trim().isNotEmpty || course != null || batch != null || day != 'All';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      detail = await _service.getClassDetail(item.id);
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load class details. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void search(String q) {
    query = q;
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

  void setDay(String d) {
    day = d;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    course = null;
    batch = null;
    day = 'All';
    notifyListeners();
  }
}