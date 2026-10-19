// lib/viewmodels/staff_dashboard_viewmodel.dart  (NEW)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/models/data-models/staff_dashboard_model.dart';
import 'package:pokakbilling/models/services/staff_dashboard_service.dart';

class StaffDashboardViewModel extends ChangeNotifier {
  StaffDashboard? data;
  bool loading = false;
  String? error;

  String filterType = 'day'; // day | week | month
  String search = '';
  DateTime? startDate;
  DateTime? endDate;

  Timer? _debounce;
  int _req = 0;

  bool get hasCustomRange => startDate != null;

  bool get isSingleDay =>
      startDate != null &&
      endDate != null &&
      DateUtils.isSameDay(startDate, endDate);

  static final DateFormat _api = DateFormat('yyyy-MM-dd');

  Future<void> load({bool silent = false}) async {
    final id = ++_req;
    if (!silent) {
      loading = true;
      error = null;
      notifyListeners();
    }
    try {
      final res = await StaffDashboardService.fetch(
        search: search,
        filterType: filterType,
        startDate: startDate == null ? null : _api.format(startDate!),
        endDate: endDate == null ? null : _api.format(endDate!),
      );
      if (id != _req) return; // a newer request replaced this one
      data = res;
      error = null;
    } catch (e) {
      if (id != _req) return;
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (id == _req) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void setFilterType(String t) {
    filterType = t;
    startDate = null;
    endDate = null;
    load();
  }

  void setRange(DateTime s, DateTime e) {
    startDate = DateTime(s.year, s.month, s.day);
    endDate = DateTime(e.year, e.month, e.day);
    load();
  }

  void setDay(DateTime d) => setRange(d, d);

  void clearRange() {
    startDate = null;
    endDate = null;
    load();
  }

  void setSearch(String v) {
    search = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), load);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}