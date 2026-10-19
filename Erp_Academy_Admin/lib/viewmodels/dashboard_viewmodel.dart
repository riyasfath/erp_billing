import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._service) {
    load();
  }

  final DashboardService _service;

  AcademicDashboard? data;
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _service.getAcademicDashboard();
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load dashboard. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}