import 'package:flutter/material.dart';
import 'package:pokakbilling/models/call_activity/call_recording_model.dart';
import 'package:pokakbilling/models/services/call_activity/dashboard_service.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// ViewModel for the standalone Call Recordings screen.
/// Kept separate from CallActivityViewmodel since recordings are opened
/// from the dashboard's action row as a dedicated page, not a dashboard tab.
/// ─────────────────────────────────────────────────────────────────────────
class CallRecordingsViewmodel extends ChangeNotifier {
  bool getRecordingsLoader = false;
  bool recordingsLoaded = false;
  CallRecordingsResponseModel recordingsData =
      CallRecordingsResponseModel.empty();

  String _search = '';
  String get search => _search;

  Future<void> getCallRecordings({bool force = false}) async {
    if (recordingsLoaded && !force) return;
    try {
      getRecordingsLoader = true;
      notifyListeners();

      recordingsData = await CallActivityService.getCallRecordings(
        search: _search.isEmpty ? null : _search,
      );
      recordingsLoaded = true;
    } catch (e) {
      debugPrint('Call Recordings Fetch Error : $e');
    } finally {
      getRecordingsLoader = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => getCallRecordings(force: true);

  Future<void> updateSearch(String value) async {
    _search = value;
    await getCallRecordings(force: true);
  }

  void reset() {
    recordingsData = CallRecordingsResponseModel.empty();
    recordingsLoaded = false;
    getRecordingsLoader = false;
    _search = '';
    notifyListeners();
  }
}
