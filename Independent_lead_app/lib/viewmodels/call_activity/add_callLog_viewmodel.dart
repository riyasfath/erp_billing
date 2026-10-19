import 'package:flutter/material.dart';
import 'package:pokakbilling/models/call_activity/call_log_model.dart';
import 'package:pokakbilling/models/services/call_activity/dashboard_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// ViewModel for the Add Call Log form.
/// Submits to POST /add-call-logs/ via CallActivityService.addCallLog().
/// ─────────────────────────────────────────────────────────────────────────
class AddCallLogViewmodel extends ChangeNotifier {
  bool submitting = false;
  String? errorMessage;
  int? lastCallLogId;

  /// Returns true on success, false on failure (errorMessage will be set).
  Future<bool> submit(AddCallLogRequestModel payload) async {
    try {
      submitting = true;
      errorMessage = null;
      notifyListeners();

      final result = await CallActivityService.addCallLog(payload);
      lastCallLogId = result.callLogId;
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Add Call Log Error : $e');
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
