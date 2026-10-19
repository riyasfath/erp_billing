/// ─────────────────────────────────────────────────────────────────────────
/// Call details shape for GET/PATCH /call-activity/call-details/<lead_id>/
///
/// PATCH body confirmed from your example:
/// { "lead_status": "Contacted", "follow_up_date": "2026-06-20" }
///
/// GET response shape wasn't confirmed against a live payload, so parsing
/// below is defensive (tries several likely key names) — same pattern
/// already used elsewhere in this codebase (see CallTaskModel._pick etc).
/// Update the key fallback lists here once you've seen a real GET response.
/// ─────────────────────────────────────────────────────────────────────────
class CallDetailsModel {
  final int leadId;
  final String? dateTime;
  final String? duration;
  final String? leadSource;
  final String leadStatus;
  final String? followUpDate;
  final String? notes;

  CallDetailsModel({
    required this.leadId,
    this.dateTime,
    this.duration,
    this.leadSource,
    required this.leadStatus,
    this.followUpDate,
    this.notes,
  });

  static String? _pick(Map<String, dynamic> j, List<String> keys) {
    for (final k in keys) {
      if (j[k] != null && j[k].toString().isNotEmpty) return j[k].toString();
    }
    return null;
  }

  factory CallDetailsModel.fromJson(
    Map<String, dynamic> json, {
    int? fallbackLeadId,
  }) {
    return CallDetailsModel(
      leadId: json['lead_id'] is int
          ? json['lead_id'] as int
          : int.tryParse(json['lead_id']?.toString() ?? '') ??
              fallbackLeadId ??
              0,
      dateTime: _pick(json, ['date_time', 'call_time', 'created_at']),
      duration: _pick(json, ['duration', 'call_duration']),
      leadSource: _pick(json, ['lead_source', 'source']),
      leadStatus: _pick(json, ['lead_status', 'status']) ?? 'NEW',
      followUpDate: _pick(json, ['follow_up_date', 'next_followup_date']),
      notes: _pick(json, ['notes', 'call_notes', 'remarks']),
    );
  }

  factory CallDetailsModel.empty(int leadId) => CallDetailsModel(
        leadId: leadId,
        leadStatus: 'NEW',
      );
}
