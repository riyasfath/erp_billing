import 'package:flutter/foundation.dart';

class CallActivityDashboardModel {
  final int totalCalls;
  final int answeredCalls;
  final int missedNoAnswer;
  final String totalCallDuration;
  final String averageCallTime;

  final String? filterPeriod;
  final String? filterStatus;
  final String? filterStage;

  CallActivityDashboardModel({
    required this.totalCalls,
    required this.answeredCalls,
    required this.missedNoAnswer,
    required this.totalCallDuration,
    required this.averageCallTime,
    this.filterPeriod,
    this.filterStatus,
    this.filterStage,
  });

  factory CallActivityDashboardModel.fromJson(Map<String, dynamic> json) {
    final topCards = json['top_cards'] as Map<String, dynamic>? ?? {};
    final filters = json['filters_applied'] as Map<String, dynamic>? ?? {};

    return CallActivityDashboardModel(
      totalCalls: topCards['total_calls'] ?? 0,
      answeredCalls: topCards['answered_calls'] ?? 0,
      missedNoAnswer: topCards['missed_no_answer'] ?? 0,
      totalCallDuration: topCards['total_call_duration']?.toString() ?? '0Sec',
      averageCallTime: topCards['average_call_time']?.toString() ?? '0Sec',
      filterPeriod: filters['period']?.toString(),
      filterStatus: filters['status']?.toString(),
      filterStage: filters['stage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top_cards': {
        'total_calls': totalCalls,
        'answered_calls': answeredCalls,
        'missed_no_answer': missedNoAnswer,
        'total_call_duration': totalCallDuration,
        'average_call_time': averageCallTime,
      },
      'filters_applied': {
        'period': filterPeriod,
        'status': filterStatus,
        'stage': filterStage,
      },
    };
  }

  factory CallActivityDashboardModel.empty() {
    return CallActivityDashboardModel(
      totalCalls: 0,
      answeredCalls: 0,
      missedNoAnswer: 0,
      totalCallDuration: '0Sec',
      averageCallTime: '0Sec',
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────
/// Generic item used for Today's Tasks / Overdue Tasks / Follow-ups.
///
/// ✅ FIX: leadId resolution is now robust to several possible API key
/// shapes (`lead_id`, `leadId`, or a nested `lead: { id: ... }` object),
/// and logs which one matched for each task. This is critical: all
/// call/update actions must use `leadId`, never the task's own `id` — they
/// are different numbers in the live API (e.g. task id 61, lead id 228),
/// and silently falling back to `id` when `leadId` is missing causes a
/// PATCH/call against the wrong record (backend returns 404 "Call not
/// found" — see chat history).
///
/// ✅ FIX: added `isOverdue` (parsed from `is_overdue`) since the live
/// today-tasks response marks overdue items with this flag instead of
/// returning them in a separate array.
/// ─────────────────────────────────────────────────────────────────────────
class CallTaskModel {
  final int? id;
  final int? leadId;
  final String name;
  final String phone;
  final String? scheduledTime;
  final String? scheduledDate;
  final String status;
  final String stage;
  final String? notes;
  final String? type;
  final String? source;
  final bool isOverdue;

  CallTaskModel({
    this.id,
    this.leadId,
    required this.name,
    required this.phone,
    this.scheduledTime,
    this.scheduledDate,
    required this.status,
    required this.stage,
    this.notes,
    this.type,
    this.source,
    this.isOverdue = false,
  });

  static String _pick(Map<String, dynamic> j, List<String> keys,
      [String fallback = '']) {
    for (final k in keys) {
      if (j[k] != null && j[k].toString().isNotEmpty) {
        return j[k].toString();
      }
    }
    return fallback;
  }

  // Tries several likely key names/shapes for the lead id, since the API
  // has been inconsistent about this across endpoints. Logged so we can
  // see exactly which key (if any) actually matched for a given task.
  static int? _pickLeadId(Map<String, dynamic> j) {
    for (final k in ['lead_id', 'leadId', 'lead']) {
      final v = j[k];
      if (v == null) continue;
      if (v is int) return v;
      if (v is Map && v['id'] != null) {
        // handles a possible nested { "lead": { "id": 239, ... } } shape
        return v['id'] is int
            ? v['id'] as int
            : int.tryParse(v['id'].toString());
      }
      final parsed = int.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  factory CallTaskModel.fromJson(Map<String, dynamic> json) {
    final parsedLeadId = _pickLeadId(json);

    debugPrint(
        '[CallTaskModel] task id=${json['id']} lead_id_raw=${json['lead_id']} '
        'resolved_lead_id=$parsedLeadId name=${json['name'] ?? json['lead_name']}');

    return CallTaskModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      leadId: parsedLeadId,
      name: _pick(json, ['lead_name', 'name', 'client_name', 'contact_name'],
          'Unknown'),
      phone: _pick(json, ['phone_number', 'phone', 'mobile', 'contact_number']),
      scheduledTime: json['scheduled_time']?.toString() ??
          json['time']?.toString() ??
          json['due_time']?.toString(),
      scheduledDate: json['scheduled_date']?.toString() ??
          json['date']?.toString() ??
          json['due_date']?.toString() ??
          json['next_followup_date']?.toString(),
      status: _pick(json, ['status', 'call_status'], 'Pending'),
      stage: _pick(json, ['stage', 'lead_stage'], 'New'),
      notes: json['notes']?.toString() ?? json['remarks']?.toString(),
      type: json['type']?.toString() ?? json['task_type']?.toString(),
      source: json['source']?.toString() ?? json['lead_source']?.toString(),
      isOverdue: json['is_overdue'] == true ||
          json['is_overdue']?.toString().toLowerCase() == 'true',
    );
  }
}

class TodayTasksResponseModel {
  final int todayTasksCount;
  final List<CallTaskModel> todayTasks;
  final int overdueTasksCount;
  final List<CallTaskModel> overdueTasks;

  TodayTasksResponseModel({
    required this.todayTasksCount,
    required this.todayTasks,
    required this.overdueTasksCount,
    required this.overdueTasks,
  });

  factory TodayTasksResponseModel.fromJson(Map<String, dynamic> json) {
    final rawToday = ((json['today_tasks'] as List?) ?? [])
        .map((e) => CallTaskModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // ✅ If the backend ever sends a real separate `overdue_tasks` array,
    // prefer that (original behaviour).
    if (json.containsKey('overdue_tasks')) {
      final overdue = ((json['overdue_tasks'] as List?) ?? [])
          .map((e) => CallTaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return TodayTasksResponseModel(
        todayTasksCount: json['today_tasks_count'] ?? rawToday.length,
        todayTasks: rawToday,
        overdueTasksCount: json['overdue_tasks_count'] ?? overdue.length,
        overdueTasks: overdue,
      );
    }

    // ✅ FIX: confirmed live response returns ONE `today_tasks` array where
    // each item carries an `is_overdue` flag (see testCall / id 23 in the
    // sample payload) instead of two separate arrays. Split on that flag so
    // the "Overdue" section in the UI actually populates.
    final overdue = rawToday.where((t) => t.isOverdue).toList();
    final dueToday = rawToday.where((t) => !t.isOverdue).toList();

    return TodayTasksResponseModel(
      // Keep the top-level count as reported by the backend (matches the
      // "Today's Tasks (8)" tab badge in the web UI, which counts overdue
      // items too).
      todayTasksCount: json['today_tasks_count'] ?? rawToday.length,
      todayTasks: dueToday,
      overdueTasksCount: overdue.length,
      overdueTasks: overdue,
    );
  }

  factory TodayTasksResponseModel.empty() => TodayTasksResponseModel(
        todayTasksCount: 0,
        todayTasks: [],
        overdueTasksCount: 0,
        overdueTasks: [],
      );
}

/// ─────────────────────────────────────────────────────────────────────────
/// Call history item — a completed call record.
/// ─────────────────────────────────────────────────────────────────────────
class CallHistoryItemModel {
  final int? id;
  final String name;
  final String phone;
  final String status;
  final String stage;
  final String? duration;
  final String? callTime;
  final String? callDate;
  final String? callType;
  final String? notes;

  CallHistoryItemModel({
    this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.stage,
    this.duration,
    this.callTime,
    this.callDate,
    this.callType,
    this.notes,
  });

  static String _pick(Map<String, dynamic> j, List<String> keys,
      [String fallback = '']) {
    for (final k in keys) {
      if (j[k] != null && j[k].toString().isNotEmpty) {
        return j[k].toString();
      }
    }
    return fallback;
  }

  factory CallHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return CallHistoryItemModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: _pick(json, ['lead_name', 'name', 'client_name', 'contact_name'],
          'Unknown'),
      phone: _pick(json, ['phone_number', 'phone', 'mobile', 'contact_number']),
      status: _pick(json, ['status', 'call_status'], 'Unknown'),
      stage: _pick(json, ['stage', 'lead_stage'], '-'),
      duration:
          json['duration']?.toString() ?? json['call_duration']?.toString(),
      callTime: json['call_time']?.toString() ?? json['time']?.toString(),
      callDate: json['call_date']?.toString() ?? json['date']?.toString(),
      callType: _pick(json, ['call_type', 'direction', 'type'], 'Outgoing'),
      notes: json['notes']?.toString() ?? json['remarks']?.toString(),
    );
  }
}

class CallHistoryResponseModel {
  final int count;
  final List<CallHistoryItemModel> results;

  CallHistoryResponseModel({required this.count, required this.results});

  factory CallHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CallHistoryResponseModel(
      count: json['count'] ?? 0,
      results: ((json['results'] as List?) ?? [])
          .map((e) => CallHistoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CallHistoryResponseModel.empty() =>
      CallHistoryResponseModel(count: 0, results: []);
}

/// ─────────────────────────────────────────────────────────────────────────
/// Follow-up item (call-activity specific follow-up list).
/// ─────────────────────────────────────────────────────────────────────────
class CallFollowUpModel {
  final int? id;
  final String name;
  final String phone;
  final String? followUpDate;
  final String? followUpTime;
  final String status;
  final String stage;
  final String? notes;
  final String? source;

  CallFollowUpModel({
    this.id,
    required this.name,
    required this.phone,
    this.followUpDate,
    this.followUpTime,
    required this.status,
    required this.stage,
    this.notes,
    this.source,
  });

  static String _pick(Map<String, dynamic> j, List<String> keys,
      [String fallback = '']) {
    for (final k in keys) {
      if (j[k] != null && j[k].toString().isNotEmpty) {
        return j[k].toString();
      }
    }
    return fallback;
  }

  factory CallFollowUpModel.fromJson(Map<String, dynamic> json) {
    return CallFollowUpModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: _pick(json, ['lead_name', 'name', 'client_name', 'contact_name'],
          'Unknown'),
      phone: _pick(json, ['phone_number', 'phone', 'mobile', 'contact_number']),
      followUpDate:
          json['follow_up_date']?.toString() ?? json['date']?.toString(),
      followUpTime:
          json['follow_up_time']?.toString() ?? json['time']?.toString(),
      status: _pick(json, ['status'], 'Pending'),
      stage: _pick(json, ['stage', 'lead_stage'], 'New'),
      notes: json['notes']?.toString() ?? json['remarks']?.toString(),
      source: json['source']?.toString() ?? json['lead_source']?.toString(),
    );
  }
}

class CallFollowUpResponseModel {
  final int count;
  final List<CallFollowUpModel> results;

  CallFollowUpResponseModel({required this.count, required this.results});

  factory CallFollowUpResponseModel.fromJson(Map<String, dynamic> json) {
    return CallFollowUpResponseModel(
      count: json['count'] ?? 0,
      results: ((json['results'] as List?) ?? [])
          .map((e) => CallFollowUpModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CallFollowUpResponseModel.empty() =>
      CallFollowUpResponseModel(count: 0, results: []);
}

/// ─────────────────────────────────────────────────────────────────────────
/// Performance Summary — status / lead-stage / source breakdowns.
/// Backend returns dynamic key sets (e.g. new call statuses can be added),
/// so each section is parsed into an ordered list of {label, value} pairs
/// rather than fixed fields.
/// ─────────────────────────────────────────────────────────────────────────
class BreakdownItem {
  final String label;
  final int value;

  BreakdownItem({required this.label, required this.value});
}

class CallPerformanceSummaryModel {
  final List<BreakdownItem> callStatusBreakdown;
  final List<BreakdownItem> callsByLeadStage;
  final List<BreakdownItem> callsBySource;

  CallPerformanceSummaryModel({
    required this.callStatusBreakdown,
    required this.callsByLeadStage,
    required this.callsBySource,
  });

  static String _prettyLabel(String key) {
    // "no_answer" -> "No Answer", "NEW" -> "New", "facebook" -> "Facebook"
    final normalized = key.replaceAll('_', ' ').trim();
    return normalized
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  static List<BreakdownItem> _parseMap(Map<String, dynamic>? map) {
    if (map == null) return [];
    return map.entries
        .map((e) => BreakdownItem(
              label: _prettyLabel(e.key),
              value: e.value is int
                  ? e.value as int
                  : int.tryParse(e.value.toString()) ?? 0,
            ))
        .toList();
  }

  factory CallPerformanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return CallPerformanceSummaryModel(
      callStatusBreakdown:
          _parseMap(json['call_status_breakdown'] as Map<String, dynamic>?),
      callsByLeadStage:
          _parseMap(json['calls_by_lead_stage'] as Map<String, dynamic>?),
      callsBySource:
          _parseMap(json['calls_by_source'] as Map<String, dynamic>?),
    );
  }

  factory CallPerformanceSummaryModel.empty() => CallPerformanceSummaryModel(
        callStatusBreakdown: [],
        callsByLeadStage: [],
        callsBySource: [],
      );
}
