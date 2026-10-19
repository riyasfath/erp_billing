import 'package:flutter/material.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';
import 'package:pokakbilling/models/services/folllowup_service.dart';

class FollowupViewmodel extends ChangeNotifier {
  List<FollowupModel> _followups = [];
  bool _loading = false;
  Map<String, dynamic> _stats = {};

  List<FollowupModel> get followups => _followups;
  bool get loading => _loading;
  Map<String, dynamic> get stats => _stats;

  // Selected filters
  String? _selectedStatus;
  String? _selectedType;

  String? get selectedStatus => _selectedStatus;
  String? get selectedType => _selectedType;

  FollowupViewmodel() {
    fetchFollowups();
  }

  /// Instantly marks a followup as COMPLETED in the local list so the UI
  /// updates before the API responds. If the API call fails, call
  /// [fetchFollowups] to revert back to the server state.
  void optimisticallyMarkCompleted(int id) {
    final idx = _followups.indexWhere((f) => f.id == id);
    if (idx == -1) return;

    final old = _followups[idx];
    _followups[idx] = FollowupModel(
      id: old.id,
      lead: old.lead,
      title: old.title,
      activityType: old.activityType,
      subtype: old.subtype,
      location: old.location,
      description: old.description,
      dueDate: old.dueDate,
      status: 'COMPLETED', // ← only this changes
      assignedTo: old.assignedTo,
      assignedToName: old.assignedToName,
      createdAt: old.createdAt,
    );
    notifyListeners();
  }

  /// Fetch all followups with optional filters
  Future<void> fetchFollowups({
    String? status,
    String? activityType,
    String? dueDateAfter,
    String? dueDateBefore,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final fetched = await FollowupServices.getFollowups(
        status: status ?? _selectedStatus,
        activityType: activityType ?? _selectedType,
        dueDateAfter: dueDateAfter,
        dueDateBefore: dueDateBefore,
      );

      _followups = fetched;

      // Sort by due_date (earliest first)
      _followups.sort((a, b) {
        final da = _parseDateTimeForSort(a);
        final db = _parseDateTimeForSort(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    } catch (e) {
      debugPrint("Followup fetch error: $e");
      _followups = [];
    }

    _loading = false;
    notifyListeners();
  }

  /// Fetch followups for a specific lead
  Future<List<FollowupModel>> fetchFollowupsForLead(int leadId) async {
    try {
      final leadFollowups = await FollowupServices.getFollowupsByLead(leadId);

      leadFollowups.sort((a, b) {
        final da = _parseDateTimeForSort(a);
        final db = _parseDateTimeForSort(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

      return leadFollowups;
    } catch (e) {
      debugPrint('fetchFollowupsForLead error: $e');
      return [];
    }
  }

  /// Fetch followup stats
  Future<void> fetchStats() async {
    try {
      _stats = await FollowupServices.getFollowupStats();
      notifyListeners();
    } catch (e) {
      debugPrint('fetchStats error: $e');
      _stats = {};
    }
  }

  /// Create a new followup - converts separate date/time to ISO format
  Future<bool> createFollowup({
    required int lead,
    required String title,
    String? description,
    required String date,
    required String time,
    String status = 'PENDING',
    String activityType = 'FOLLOW_UP',
    String? location,
  }) async {
    try {
      String dueDate = _combineDateTimeToISO(date, time);

      final created = await FollowupServices.createFollowup(
        lead: lead,
        title: title,
        description: description,
        dueDate: dueDate,
        status: status.toUpperCase(),
        activityType: activityType.toUpperCase(),
        location: location,
      );

      if (created != null) {
        await fetchFollowups();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('createFollowup error: $e');
      return false;
    }
  }

  /// Create followup with ISO datetime (new format)
  Future<bool> createFollowupISO({
    required int lead,
    required String title,
    String? description,
    required String dueDate,
    String status = 'PENDING',
    String activityType = 'FOLLOW_UP',
    String? location,
  }) async {
    try {
      final created = await FollowupServices.createFollowup(
        lead: lead,
        title: title,
        description: description,
        dueDate: dueDate,
        status: status.toUpperCase(),
        activityType: activityType.toUpperCase(),
        location: location,
      );

      if (created != null) {
        await fetchFollowups();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('createFollowupISO error: $e');
      return false;
    }
  }

  /// Update a followup
  Future<bool> updateFollowup(int id, Map<String, dynamic> updates) async {
    try {
      if (updates.containsKey('status')) {
        updates['status'] = updates['status'].toString().toUpperCase();
      }
      if (updates.containsKey('activity_type')) {
        updates['activity_type'] =
            updates['activity_type'].toString().toUpperCase();
      }

      final error = await FollowupServices.updateFollowup(id, updates);

      if (error == null) {
        await fetchFollowups();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateFollowup error: $e');
      return false;
    }
  }

  /// Delete a followup
  Future<bool> deleteFollowup(int id) async {
    try {
      final error = await FollowupServices.deleteFollowup(id);

      if (error == null) {
        await fetchFollowups();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('deleteFollowup error: $e');
      return false;
    }
  }

  /// Mark a followup as completed
  Future<bool> markCompleted(int id) async {
    try {
      final error = await FollowupServices.markCompleted(id);

      if (error == null) {
        await fetchFollowups();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('markCompleted error: $e');
      return false;
    }
  }

  /// Set status filter
  void setStatusFilter(String? status) {
    _selectedStatus = status?.toUpperCase();
    fetchFollowups();
  }

  /// Set type filter
  void setTypeFilter(String? type) {
    _selectedType = type?.toUpperCase();
    fetchFollowups();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedStatus = null;
    _selectedType = null;
    fetchFollowups();
  }

  /// Get followups filtered by lead (local filter)
  List<FollowupModel> followupsForLead(int leadId) {
    return _followups.where((f) => f.lead == leadId).toList();
  }

  /// Helper: Combine date and time strings into ISO 8601 format
  String _combineDateTimeToISO(String date, String time) {
    String combined = '${date}T$time';
    if (!combined.endsWith('Z') &&
        !combined.contains('+') &&
        !combined.contains('-', 10)) {
      combined += 'Z';
    }
    return combined;
  }

  /// Parse datetime for sorting from dueDate field
  DateTime? _parseDateTimeForSort(FollowupModel f) {
    try {
      if (f.dueDate.isNotEmpty) {
        return DateTime.tryParse(f.dueDate);
      }
    } catch (_) {}
    return null;
  }

  /// Refresh all data
  Future<void> refresh() async {
    await fetchFollowups();
    await fetchStats();
  }

  void reset() {
    _followups = [];
    _loading = false;
    _stats = {};
    _selectedStatus = null;
    _selectedType = null;
    notifyListeners();
  }
}
