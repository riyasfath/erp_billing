// lib/models/data-models/followup_model.dart
class FollowupModel {
  final int id;
  final int lead;
  final String title;
  final String activityType; // CALL, EMAIL, FOLLOW_UP, WHATSAPP, MEETING
  final String? subtype;
  final String? location;
  final String description;
  final String dueDate; // ISO 8601: 2024-01-01T10:00:00Z
  final String status; // PENDING, COMPLETED
  final int? assignedTo;
  final String? assignedToName;
  final String createdAt;

  // Computed properties for backward compatibility with UI
  String get date {
    // Extract date part from dueDate (ISO format)
    if (dueDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(dueDate);
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dueDate.split('T').first;
    }
  }

  String get time {
    // Extract time part from dueDate (ISO format)
    if (dueDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(dueDate);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      final parts = dueDate.split('T');
      if (parts.length > 1) {
        return parts[1].replaceAll('Z', '').split('.').first;
      }
      return '';
    }
  }

  String get type {
    // Map activity_type to UI-friendly lowercase format
    switch (activityType.toUpperCase()) {
      case 'CALL':
        return 'call';
      case 'EMAIL':
        return 'email';
      case 'WHATSAPP':
        return 'whatsapp';
      case 'MEETING':
        return 'meeting';
      default:
        return 'call';
    }
  }

  String get notes => description;

  FollowupModel({
    required this.id,
    required this.lead,
    required this.title,
    required this.activityType,
    this.subtype,
    this.location,
    required this.description,
    required this.dueDate,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    required this.createdAt,
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
      return v.toString().trim();
    }

    int? toIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      try {
        return int.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return FollowupModel(
      id: toInt(json['id']),
      lead: toInt(json['lead']),
      title: safeString(json['title']).isEmpty
          ? 'Follow-up'
          : safeString(json['title']),
      activityType: safeString(json['activity_type']).isEmpty
          ? 'FOLLOW_UP'
          : safeString(json['activity_type']).toUpperCase(),
      subtype: json['subtype']?.toString().trim(),
      location: json['location']?.toString().trim(),
      description: safeString(json['description']),
      dueDate: safeString(json['due_date']),
      status: safeString(json['status']).isEmpty
          ? 'PENDING'
          : safeString(json['status']).toUpperCase(),
      assignedTo: toIntNullable(json['assigned_to']),
      assignedToName: json['assigned_to_name']?.toString().trim(),
      createdAt: safeString(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead': lead,
      'title': title,
      'activity_type': activityType,
      'subtype': subtype,
      'location': location,
      'description': description,
      'due_date': dueDate,
      'status': status,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'created_at': createdAt,
    };
  }
}
