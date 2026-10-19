// lib/viewmodels/activity_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/activity_leads/activity.dart';
import 'package:pokakbilling/models/services/activity_leads_service/activity_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class ActivityViewmodel extends ChangeNotifier {
  final List<ActivityModel> _activities = [];
  bool _isLoading = false;
  bool _posting = false;
  String? _errorMessage;
  bool _disposed = false;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  bool get posting => _posting;
  String? get errorMessage => _errorMessage;

  ActivityViewmodel();

  // Add activity locally + post to server
  Future<void> addManualActivity({
    required int leadId,
    required String activityType,
    required String action,
    required BuildContext context,
  }) async {
    if (_disposed) return;
    _posting = true;
    _safeNotifyListeners();

    try {
      final serverError = await ActivityServices.postManualActivity(
        leadId: leadId,
        activityType: activityType,
        action: action,
      );

      if (serverError == null) {
        // success — add local instance
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        final nowIso = DateTime.now().toIso8601String();
        final item = ActivityModel(
          id: id,
          leadId: leadId,
          activityType: activityType,
          action: action,
          createdAt: nowIso,
        );
        _activities.insert(0, item);

        if (!context.mounted) return;
        showSuccessMessage(context, 'Activity added');
        Navigator.of(context).pop(true);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, serverError);
      }
    } catch (e) {
      if (!_disposed && context.mounted) {
        showOverlayError(context, 'Failed to add activity: $e');
      }
    } finally {
      if (!_disposed) {
        _posting = false;
        _safeNotifyListeners();
      }
    }
  }

  // Optional: add method to push a new activity locally (offline)
  void addLocalActivity(ActivityModel a) {
    if (_disposed) return;
    _activities.insert(0, a);
    _safeNotifyListeners();
  }

  // Optional: clear list
  void clear() {
    if (_disposed) return;
    _activities.clear();
    _safeNotifyListeners();
  }

  // Safe notify logic used across your app
  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
