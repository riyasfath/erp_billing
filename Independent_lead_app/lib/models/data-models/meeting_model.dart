// // lib/models/data-models/meeting_model.dart
// ✅ UPDATED: Matches NEW API response structure
class MeetingModel {
  final int id;
  final int lead;
  final String title;
  final String activityType;
  final String? subtype;
  final String? location;
  final String? description;
  final String dueDate; // ISO: "2024-01-05T14:00:00Z"
  final String status;
  final int? assignedTo;
  final String? assignedToName;
  final String? createdAt;
  final String leadName;
  final String phone;

  MeetingModel({
    required this.id,
    required this.lead,
    required this.title,
    required this.activityType,
    this.subtype,
    this.location,
    this.description,
    required this.dueDate,
    required this.status,
    this.assignedTo,
    this.assignedToName,
    this.createdAt,
    required this.leadName,
    required this.phone,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      try {
        return int.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return MeetingModel(
      id: toInt(json['id']) ?? 0,
      lead: toInt(json['lead']) ?? 0,
      title: json['title']?.toString() ?? '',
      activityType: json['activity_type']?.toString() ?? '',
      subtype: json['subtype']?.toString(),
      location: json['location']?.toString(),
      description: json['description']?.toString(),
      dueDate: json['due_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      assignedTo: toInt(json['assigned_to']),
      assignedToName: json['assigned_to_name']?.toString(),
      createdAt: json['created_at']?.toString(),
      leadName: json['lead_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
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
      'lead_name': leadName,
      'phone': phone,
    };
  }

  // Helper getters for UI
  String get formattedDate =>
      _parseDateTime().toLocal().toString().split(' ')[0];
  String get formattedTime =>
      _parseDateTime().toLocal().toString().split(' ')[1].substring(0, 5);
  DateTime _parseDateTime() => DateTime.parse(dueDate);

  String get statusDisplay {
    switch (status) {
      case 'PENDING':
        return 'Scheduled';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
