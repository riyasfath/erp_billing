/// ─────────────────────────────────────────────────────────────────────────
/// Call Recording — item returned by GET /call-recordings/
/// Response shape confirmed so far:
///   { "count": 0, "recordings": [] }
/// Item shape isn't confirmed yet (list is currently empty in prod), so
/// parsing is defensive with common key-name fallbacks, mirroring the
/// pattern used for CallTaskModel / CallHistoryItemModel. Update the key
/// fallbacks here once a real recording object is seen from the API.
/// ─────────────────────────────────────────────────────────────────────────
class CallRecordingModel {
  final int? id;
  final String name;
  final String phone;
  final String? recordingUrl;
  final String? duration;
  final String? callDate;
  final String? callTime;
  final String? status;
  final String? stage;
  final String? notes;

  CallRecordingModel({
    this.id,
    required this.name,
    required this.phone,
    this.recordingUrl,
    this.duration,
    this.callDate,
    this.callTime,
    this.status,
    this.stage,
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

  factory CallRecordingModel.fromJson(Map<String, dynamic> json) {
    return CallRecordingModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: _pick(json, ['lead_name', 'name', 'client_name', 'contact_name'],
          'Unknown'),
      phone: _pick(json, ['phone_number', 'phone', 'mobile', 'contact_number']),
      recordingUrl: json['recording_url']?.toString() ??
          json['audio_url']?.toString() ??
          json['file_url']?.toString() ??
          json['url']?.toString(),
      duration:
          json['duration']?.toString() ?? json['call_duration']?.toString(),
      callDate: json['call_date']?.toString() ?? json['date']?.toString(),
      callTime: json['call_time']?.toString() ?? json['time']?.toString(),
      status: json['status']?.toString() ?? json['call_status']?.toString(),
      stage: json['stage']?.toString() ?? json['lead_stage']?.toString(),
      notes: json['notes']?.toString() ?? json['remarks']?.toString(),
    );
  }
}

class CallRecordingsResponseModel {
  final int count;
  final List<CallRecordingModel> recordings;

  CallRecordingsResponseModel({
    required this.count,
    required this.recordings,
  });

  factory CallRecordingsResponseModel.fromJson(Map<String, dynamic> json) {
    return CallRecordingsResponseModel(
      count: json['count'] ?? 0,
      recordings: ((json['recordings'] as List?) ?? [])
          .map((e) => CallRecordingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory CallRecordingsResponseModel.empty() =>
      CallRecordingsResponseModel(count: 0, recordings: []);
}
