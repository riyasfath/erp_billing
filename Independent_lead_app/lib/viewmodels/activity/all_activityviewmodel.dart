// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/data-models/activity-model/activity_model.dart';
// import 'package:pokakbilling/models/services/activity_service.dart';

// class AllActivityViewModel extends ChangeNotifier {
//   final OrganiserService _service = OrganiserService();

//   List<AllActivityModel> _activities = [];
//   List<AllActivityModel> get activities => _activities;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? _error;
//   String? get error => _error;

//   bool _isSubmitting = false;
//   bool get isSubmitting => _isSubmitting;

//   String? _submitError;
//   String? get submitError => _submitError;

//   // ─────────────────────────────────────────
//   // FETCH ALL  →  GET /organiser/
//   // ─────────────────────────────────────────
//   Future<void> fetchActivities() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       _activities = await _service.getAllActivities();
//     } catch (e) {
//       _error = e.toString();
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   // ─────────────────────────────────────────
//   // SCHEDULE MEETING
//   // ─────────────────────────────────────────
//   Future<bool> scheduleMeeting({
//     required int leadId,
//     required String title,
//     required String description,
//     required String subtype,
//     required String location,
//     required String dueDate,
//   }) async {
//     return _submit(() => _service.scheduleMeeting(
//           leadId: leadId,
//           title: title,
//           description: description,
//           subtype: subtype,
//           location: location,
//           dueDate: dueDate,
//         ));
//   }

//   // ─────────────────────────────────────────
//   // SCHEDULE FOLLOW-UP
//   // ─────────────────────────────────────────
//   Future<bool> scheduleFollowUp({
//     required int leadId,
//     required String title,
//     required String description,
//     required String dueDate,
//     String activityType = "FOLLOW_UP",
//   }) async {
//     return _submit(() => _service.scheduleFollowUp(
//           leadId: leadId,
//           title: title,
//           description: description,
//           dueDate: dueDate,
//           activityType: activityType,
//         ));
//   }

//   // ─────────────────────────────────────────
//   // SET REMINDER
//   // ─────────────────────────────────────────
//   Future<bool> setReminder({
//     required int leadId,
//     required String title,
//     required String description,
//     required String subtype,
//     required String dueDate,
//   }) async {
//     return _submit(() => _service.setReminder(
//           leadId: leadId,
//           title: title,
//           description: description,
//           subtype: subtype,
//           dueDate: dueDate,
//         ));
//   }

//   // ─────────────────────────────────────────
//   // LOG CALL
//   // ─────────────────────────────────────────
//   Future<bool> logCall({
//     required int leadId,
//     required String phoneNumber,
//   }) async {
//     return _submit(() => _service.logCall(
//           leadId: leadId,
//           phoneNumber: phoneNumber,
//         ));
//   }

//   // ─────────────────────────────────────────
//   // LOG WHATSAPP
//   // ─────────────────────────────────────────
//   Future<bool> logWhatsApp({
//     required int leadId,
//     required String phoneNumber,
//     required String message,
//   }) async {
//     return _submit(() => _service.logWhatsApp(
//           leadId: leadId,
//           phoneNumber: phoneNumber,
//           message: message,
//         ));
//   }

//   // ─────────────────────────────────────────
//   // LOG EMAIL
//   // ─────────────────────────────────────────
//   Future<bool> logEmail({
//     required int leadId,
//     required String email,
//     required String subject,
//     required String message,
//   }) async {
//     return _submit(() => _service.logEmail(
//           leadId: leadId,
//           email: email,
//           subject: subject,
//           message: message,
//         ));
//   }

//   // ─────────────────────────────────────────
//   // SHARED SUBMIT WRAPPER
//   // ─────────────────────────────────────────
//   Future<bool> _submit(Future<Map<String, dynamic>> Function() call) async {
//     _isSubmitting = true;
//     _submitError = null;
//     notifyListeners();

//     bool success = false;
//     try {
//       await call();
//       success = true;
//       // Refresh the list after any successful submission
//       await fetchActivities();
//     } catch (e) {
//       _submitError = e.toString();
//       success = false;
//     }

//     _isSubmitting = false;
//     notifyListeners();
//     return success;
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/activity-model/activity_model.dart';
import 'package:pokakbilling/models/services/activity_service.dart';

class AllActivityViewModel extends ChangeNotifier {
  final OrganiserService _service = OrganiserService();

  List<AllActivityModel> _activities = [];
  List<AllActivityModel> get activities => _activities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _submitError;
  String? get submitError => _submitError;

  void reset() {
    _activities = [];
    _isLoading = false;
    _error = null;
    _isSubmitting = false;
    _submitError = null;
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _activities = await _service.getAllActivities();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> scheduleMeeting({
    required int leadId,
    required String title,
    required String description,
    required String subtype,
    required String location,
    required String dueDate,
  }) async {
    return _submit(() => _service.scheduleMeeting(
          leadId: leadId,
          title: title,
          description: description,
          subtype: subtype,
          location: location,
          dueDate: dueDate,
        ));
  }

  Future<bool> scheduleFollowUp({
    required int leadId,
    required String title,
    required String description,
    required String dueDate,
    String activityType = "FOLLOW_UP",
  }) async {
    return _submit(() => _service.scheduleFollowUp(
          leadId: leadId,
          title: title,
          description: description,
          dueDate: dueDate,
          activityType: activityType,
        ));
  }

  Future<bool> setReminder({
    required int leadId,
    required String title,
    required String description,
    required String subtype,
    required String dueDate,
  }) async {
    return _submit(() => _service.setReminder(
          leadId: leadId,
          title: title,
          description: description,
          subtype: subtype,
          dueDate: dueDate,
        ));
  }

  Future<bool> logCall({
    required int leadId,
    required String phoneNumber,
  }) async {
    return _submit(() => _service.logCall(
          leadId: leadId,
          phoneNumber: phoneNumber,
        ));
  }

  Future<bool> logWhatsApp({
    required int leadId,
    required String phoneNumber,
    required String message,
  }) async {
    return _submit(() => _service.logWhatsApp(
          leadId: leadId,
          phoneNumber: phoneNumber,
          message: message,
        ));
  }

  Future<bool> logEmail({
    required int leadId,
    required String email,
    required String subject,
    required String message,
  }) async {
    return _submit(() => _service.logEmail(
          leadId: leadId,
          email: email,
          subject: subject,
          message: message,
        ));
  }

  Future<bool> _submit(Future<Map<String, dynamic>> Function() call) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();
    bool success = false;
    try {
      await call();
      success = true;
      await fetchActivities();
    } catch (e) {
      _submitError = e.toString();
      success = false;
    }
    _isSubmitting = false;
    notifyListeners();
    return success;
  }
}
