// lib/viewmodels/meeting_viewmodel.dart
// ✅ UPDATED: Full support for NEW API structure
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/meeting_model.dart';
import 'package:pokakbilling/models/services/meeting_services.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/meeting.dart';
import 'package:pokakbilling/views/Screens/leads/meeting/shedule_dialoge.dart';

class MeetingViewmodel extends ChangeNotifier {
  String selectedTime = "";
  DateTime selectedDate = DateTime.now();
  int selectedTimeIndex = 0;
  bool createLoading = false;
  bool getMeetingLoader = false;
  List<MeetingModel> meetingList = [];
  Map<String, dynamic> stats = {};
  String selectedStatus = "";
  String selectedStatusKey = "";

  final List<String> timeSlots = [
    "09:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
  ];

  final List<String> meetingTypes = ["Video Call", "In-Person", "Phone Call"];

  MeetingViewmodel() {
    getAllMeetings();
    fetchStats();
  }

  void selectStatus(String status) {
    selectedStatus = status;
    switch (status) {
      case "Scheduled":
        selectedStatusKey = "PENDING";
        break;
      case "Completed":
        selectedStatusKey = "COMPLETED";
        break;
      case "Cancelled":
        selectedStatusKey = "CANCELLED";
        break;
      default:
        selectedStatusKey = "PENDING";
    }
    notifyListeners();
  }

  void updateTimeIndex(String time, int index) {
    selectedTime = time;
    selectedTimeIndex = index;
    notifyListeners();
  }

  void updateDate(DateTime newDate) {
    selectedDate = newDate;
    notifyListeners();
  }

  Future<void> fetchStats() async {
    try {
      stats = await MeetingServices.getMeetingStats();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchStats error: $e');
      stats = {};
    }
  }

  /// Create meeting with NEW API - /meetings/
  Future<bool> createMeeting({
    required int leadId,
    required String title,
    required String subtype,
    String? location,
    String? description,
  }) async {
    try {
      createLoading = true;
      notifyListeners();

      // ✅ FIXED: Proper string concatenation
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final timeStr = selectedTime.padRight(5, ':00'); // 14:00 → 14:00:00
      final dueDateISO = '$dateStr' + 'T' + '$timeStr' + 'Z'; // ✅ CORRECTED

      final success = await MeetingServices.createMeeting(
        leadId: leadId,
        title: title,
        dueDate: dueDateISO,
        status: 'PENDING',
        subtype: subtype,
        location: location,
        description: description,
      );

      createLoading = false;
      notifyListeners();

      if (success == null) {
        await getAllMeetings();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      createLoading = false;
      notifyListeners();
      debugPrint('createMeeting error: $e');
      return false;
    }
  }

  Future<void> getAllMeetings({String? status}) async {
    try {
      getMeetingLoader = true;
      notifyListeners();

      meetingList = await MeetingServices.getMeetings(
        status: status ?? selectedStatusKey,
      );
    } catch (e) {
      debugPrint('getAllMeetings error: $e');
      meetingList.clear();
    } finally {
      getMeetingLoader = false;
      notifyListeners();
    }
  }

  Future<List<MeetingModel>> getMeetingsByLead(int leadId) async {
    return await MeetingServices.getMeetingsByLead(leadId);
  }

  Future<MeetingModel?> getMeetingById(int id) async {
    return await MeetingServices.getMeetingById(id);
  }

  Future<bool> updateMeeting(int id, Map<String, dynamic> updates) async {
    final result = await MeetingServices.updateMeeting(id, updates);
    if (result == null) {
      await getAllMeetings();
      await fetchStats();
      return true;
    }
    return false;
  }

  Future<bool> deleteMeeting(int id) async {
    final result = await MeetingServices.deleteMeeting(id);
    if (result == null) {
      await getAllMeetings();
      await fetchStats();
      return true;
    }
    return false;
  }

  Future<bool> markCompleted(int id) async {
    return await updateMeeting(id, {'status': 'COMPLETED'});
  }

  Future<bool> markCancelled(int id) async {
    return await updateMeeting(id, {'status': 'CANCELLED'});
  }

  void applyStatusFilter(String status) {
    selectStatus(status);
    getAllMeetings(status: selectedStatusKey);
  }

  void clearFilters() {
    selectedStatus = "";
    selectedStatusKey = "";
    getAllMeetings();
  }

  Future<void> refresh() async {
    await getAllMeetings();
    await fetchStats();
  }

  void reset() {
    // clear your quotation lists and loading flags
    notifyListeners();
  }
}
