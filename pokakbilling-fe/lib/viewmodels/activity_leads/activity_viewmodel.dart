import 'package:flutter/material.dart';
import 'package:pokakbilling/models/activity_leads/activity.dart';
import 'package:pokakbilling/models/services/activity_leads_service/activity_service.dart';

class ActivityScreenViewmodel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  bool isLoading = false;
  String? error;
  bool _disposed = false;

  // Separate data stores for each tab
  ActivityResponse _allData = ActivityResponse.empty();
  ActivityResponse _completedData = ActivityResponse.empty();
  ActivityResponse _overdueData = ActivityResponse.empty();

  bool _initialFetchDone = false;

  // ── Getters ────────────────────────────────────────────────────────────────
  ActivityCounts get counts => _allData.counts;
  List<ActivityFollowup> get followups => _allData.followups;
  List<ActivityMeeting> get meetings => _allData.meetings;
  List<ActivityReminder> get reminders => _allData.reminders;

  /// All Tasks tab — every meeting + followup + reminder from today endpoint
  List<Map<String, dynamic>> get allItems => _buildList(
        _allData.meetings,
        _allData.followups,
        _allData.reminders,
      );

  /// Completed tab items
  List<Map<String, dynamic>> get completedItems => _buildList(
        _completedData.meetings,
        _completedData.followups,
        _completedData.reminders,
      );

  /// Overdue tab items
  List<Map<String, dynamic>> get overdueItems => _buildList(
        _overdueData.meetings,
        _overdueData.followups,
        _overdueData.reminders,
      );

  // ── Build combined + sorted list ───────────────────────────────────────────
  List<Map<String, dynamic>> _buildList(
    List<ActivityMeeting> meetings,
    List<ActivityFollowup> followups,
    List<ActivityReminder> reminders,
  ) {
    final list = <Map<String, dynamic>>[];

    for (final m in meetings) {
      list.add({
        'kind': 'meeting',
        'date': m.date,
        'time': m.time,
        'status': m.status,
        'item': m,
      });
    }
    for (final f in followups) {
      list.add({
        'kind': 'followup',
        'date': f.date,
        'time': f.time,
        'status': f.status,
        'item': f,
      });
    }
    for (final r in reminders) {
      list.add({
        'kind': 'reminder',
        'date': r.date,
        'time': r.time,
        'status': r.status,
        'item': r,
      });
    }

    // Sort by date ascending
    list.sort((a, b) {
      try {
        final da = DateTime.tryParse(a['date'] as String) ?? DateTime(2100);
        final db = DateTime.tryParse(b['date'] as String) ?? DateTime(2100);
        return da.compareTo(db);
      } catch (_) {
        return 0;
      }
    });

    return list;
  }

  // ── Init — fetch all three tabs in parallel on first open ──────────────────
  Future<void> init() async {
    if (_initialFetchDone) return;
    await fetchAll();
  }

  /// Fetch today + completed + overdue simultaneously
  Future<void> fetchAll() async {
    if (_disposed) return;
    isLoading = true;
    error = null;
    _safeNotifyListeners();

    try {
      final results = await Future.wait([
        ActivityService.fetchActivities(filter: 'today'),
        ActivityService.fetchActivities(filter: 'completed'),
        ActivityService.fetchActivities(filter: 'overdue'),
      ]);
      _allData = results[0];
      _completedData = results[1];
      _overdueData = results[2];
      _initialFetchDone = true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      _allData = ActivityResponse.empty();
      _completedData = ActivityResponse.empty();
      _overdueData = ActivityResponse.empty();
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Refresh a specific tab only
  Future<void> fetchActivities({String filter = 'today'}) async {
    if (_disposed) return;
    isLoading = true;
    error = null;
    _safeNotifyListeners();

    try {
      final data = await ActivityService.fetchActivities(filter: filter);
      switch (filter) {
        case 'today':
          _allData = data;
          break;
        case 'completed':
          _completedData = data;
          break;
        case 'overdue':
          _overdueData = data;
          break;
        default:
          _allData = data;
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  // ── Safe helpers ───────────────────────────────────────────────────────────
  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
