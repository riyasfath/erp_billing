// lib/models/data-models/followup_model.dart
class FollowupModel {
  final int id;
  final int lead;
  final String title;
  final String date; // yyyy-mm-dd or ISO date
  final String time; // hh:mm or time string
  final String status; // new / completed
  final String type; // call / meeting / email / whatsapp
  final String notes;

  FollowupModel({
    required this.id,
    required this.lead,
    required this.title,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    required this.notes,
  });

  factory FollowupModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      try {
        return int.parse(v.toString());
      } catch (_) {
        return 0;
      }
    }

    String safeString(dynamic v) {
      if (v == null) return '';
      final s = v.toString().trim();
      return s;
    }

    // raw values from API (strings trimmed)
    final rawType = safeString(json['type']).toLowerCase();
    final rawStatus = safeString(json['status']).toLowerCase();
    final rawTitle = safeString(json['title']);
    final rawDate = safeString(json['date']);
    final rawTime = safeString(json['time']);
    final rawNotes = safeString(json['notes']);

    // Normalize type to an expected non-empty value
    String normalizedType;
    if (rawType.isEmpty) {
      normalizedType = 'call'; // safe default when API doesn't supply type
    } else {
      if (rawType.startsWith('call')) {
        normalizedType = 'call';
      } else if (rawType.startsWith('meet') || rawType.startsWith('meeting'))
        normalizedType = 'meeting';
      else if (rawType.startsWith('email'))
        normalizedType = 'email';
      else if (rawType.startsWith('whatsapp') || rawType.startsWith('whats'))
        normalizedType = 'whatsapp';
      else
        normalizedType = rawType; // keep whatever unusual value API returned
    }

    // Normalize status to a sensible default
    String normalizedStatus;
    if (rawStatus.isEmpty) {
      normalizedStatus = 'new';
    } else {
      if (rawStatus.startsWith('comp')) {
        normalizedStatus = 'completed';
      } else {
        normalizedStatus = rawStatus;
      }
    }

    // Title fallback so UI text doesn't break / shows something meaningful
    final normalizedTitle = rawTitle.isEmpty ? 'Follow-up' : rawTitle;

    return FollowupModel(
      id: toInt(json['id']),
      lead: toInt(json['lead']),
      title: normalizedTitle,
      date: rawDate,
      time: rawTime,
      status: normalizedStatus,
      type: normalizedType,
      notes: rawNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead': lead,
      'title': title,
      'date': date,
      'time': time,
      'status': status,
      'type': type,
      'notes': notes,
    };
  }
}
