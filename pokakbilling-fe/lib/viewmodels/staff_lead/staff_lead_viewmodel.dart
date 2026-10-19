import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/services/staff_lead/staff_lead_service.dart';
import 'package:pokakbilling/models/staff_lead/staff_lead_model.dart';
import 'package:pokakbilling/views/staff_lead/staff_lead_dashboard.dart' hide LeadStage, AcademicLead;

class StaffLeadViewmodel extends ChangeNotifier {
  // ── state ──────────────────────────────────────────────────────────────────
  LeadStage tab = LeadStage.priorityPending;
  Map<LeadStage, int> counts = {for (final s in LeadStage.values) s: 0};
  List<AcademicLead> leads = [];
  bool loading = false;
  String? error;

  // ── filters ────────────────────────────────────────────────────────────────
  String search = '';
  int? courseId;
  DateTimeRange? dateRange;

  // ── courses ────────────────────────────────────────────────────────────────
  List<StaffCourse> courses = [];
  bool coursesLoading = false;

  Timer? _debounce;
  int _reqId = 0; // ignore stale responses when tabs/filters change quickly

  bool get hasFilters =>
      search.trim().isNotEmpty || courseId != null || dateRange != null;

  String? get courseName {
    if (courseId == null) return null;
    for (final c in courses) {
      if (c.id == courseId) return c.name;
    }
    return 'Course #$courseId';
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void clearData() {
    tab = LeadStage.priorityPending;
    counts = {for (final s in LeadStage.values) s: 0};
    leads = [];
    error = null;
    search = '';
    courseId = null;
    dateRange = null;
    courses = [];
    notifyListeners();
  }

  // ── load ───────────────────────────────────────────────────────────────────
  /// Called when the dashboard screen opens.
  Future<void> init() async {
    loadCourses();
    await fetch();
  }

  /// Silent reload (pull-to-refresh, home page banner counts).
  Future<void> refresh() => fetch(showLoader: false);

  Future<void> fetch({bool showLoader = true}) async {
    final id = ++_reqId;
    if (showLoader) loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await StaffLeadService.dashboard(
        tab: tab,
        courseId: courseId,
        name: search,
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
      if (id != _reqId) return;
      leads = res.leads;
      counts = res.counts;
    } catch (e) {
      if (id != _reqId) return;
      debugPrint('StaffLead fetch: $e');
      error = _msg(e);
      leads = [];
    } finally {
      if (id == _reqId) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadCourses({bool force = false}) async {
    if (coursesLoading || (courses.isNotEmpty && !force)) return;
    coursesLoading = true;
    notifyListeners();
    try {
      courses = await StaffLeadService.courses();
    } catch (e) {
      debugPrint('StaffLead courses: $e');
    } finally {
      coursesLoading = false;
      notifyListeners();
    }
  }

  // ── tab + filters ──────────────────────────────────────────────────────────
  void setTab(LeadStage s) {
    if (tab == s) return;
    tab = s;
    fetch();
  }

  void onSearch(String v) {
    search = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), fetch);
  }

  void setCourse(int? id) {
    courseId = id;
    fetch();
  }

  void setDateRange(DateTimeRange? r) {
    dateRange = r;
    fetch();
  }

  void clearFilters() {
    _debounce?.cancel();
    search = '';
    courseId = null;
    dateRange = null;
    fetch();
  }

  // ── create / update ────────────────────────────────────────────────────────
  /// Returns null on success, error text otherwise.
  Future<String?> createLead({
    required String name,
    String phone = '',
    String email = '',
    int? courseId,
    String qualification = '',
    String addOn = '',
    DateTime? expectedStart,
    required String leadStatus,
    required LeadStage priority, // one of the 4 priority stages
    String enquiry = '',
  }) async {
    final err = await StaffLeadService.createLead(
      name: name,
      phone: phone,
      email: email,
      courseId: courseId,
      qualification: qualification,
      addOn: addOn,
      expectedStart: expectedStart,
      leadStatus: leadStatus,
      priorityStatus: priority.priorityValue,
      enquiry: enquiry,
    );
    if (err == null) {
      tab = priority; // jump to the tab where the new lead lives
      await fetch(showLoader: false);
    }
    return err;
  }

  /// [body] only contains the changed fields.
  Future<String?> updateLead(int id, Map<String, dynamic> body) async {
    final err = await StaffLeadService.updateLead(id, body);
    if (err == null) await fetch(showLoader: false);
    return err;
  }
}