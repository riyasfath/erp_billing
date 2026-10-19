// lib/models/data-models/reminder_model.dart
// ✅ Updated to match NEW API structure
// API Fields: id, title, lead, subtype, due_date, description, status

class ReminderModel {
  final String id;
  final String? leadId; // maps to "lead" in API
  final String? leadName; // resolved locally
  final String? title; // maps to "title" in API (changed from subject)
  final String?
      subtype; // maps to "subtype" in API - Email, Call, WhatsApp, Message, Follow-up
  final String? date; // extracted from due_date (yyyy-mm-dd)
  final String? time; // extracted from due_date (HH:mm:ss)
  final String?
      description; // maps to "description" in API (changed from notes)
  final String? status; // PENDING, COMPLETED, CANCELLED
  final bool completed; // derived from status == 'COMPLETED'
  final String? phone; // resolved from lead
  final String? email; // resolved from lead
  final String? dueDate; // full ISO 8601 from API (2024-01-10T09:00:00Z)

  ReminderModel({
    required this.id,
    this.leadId,
    this.leadName,
    this.title,
    this.subtype,
    this.date,
    this.time,
    this.description,
    this.status,
    this.completed = false,
    this.phone,
    this.email,
    this.dueDate,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    // Extract date and time from due_date if present
    String? extractedDate;
    String? extractedTime;
    final dueDateStr = json['due_date']?.toString();

    if (dueDateStr != null && dueDateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dueDateStr);
        extractedDate =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        extractedTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      } catch (_) {
        // If parsing fails, try to extract manually
        if (dueDateStr.contains('T')) {
          final parts = dueDateStr.split('T');
          extractedDate = parts[0];
          if (parts.length > 1) {
            extractedTime = parts[1].replaceAll('Z', '').split('.')[0];
          }
        }
      }
    }

    final statusStr = json['status']?.toString().toUpperCase() ?? 'PENDING';

    return ReminderModel(
      id: (json['id'] ?? '').toString(),
      leadId: json['lead']?.toString(),
      leadName: json['lead_name']?.toString(),
      title: json['title']?.toString(),
      subtype: json['subtype']?.toString(),
      date: extractedDate ?? json['date']?.toString(),
      time: extractedTime ?? json['time']?.toString(),
      description: json['description']?.toString(),
      status: statusStr,
      completed: statusStr == 'COMPLETED',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      dueDate: dueDateStr,
    );
  }

  Map<String, dynamic> toJson() {
    // Combine date and time into due_date for API
    String? dueDateForApi;
    if (date != null && time != null) {
      dueDateForApi = '${date}T$time';
      if (!dueDateForApi.endsWith('Z') && !dueDateForApi.contains('+')) {
        dueDateForApi += 'Z';
      }
    } else if (dueDate != null) {
      dueDateForApi = dueDate;
    }

    return {
      if (leadId != null) 'lead': int.tryParse(leadId!) ?? leadId,
      if (title != null) 'title': title,
      if (subtype != null) 'subtype': subtype,
      if (dueDateForApi != null) 'due_date': dueDateForApi,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? leadId,
    String? leadName,
    String? title,
    String? subtype,
    String? date,
    String? time,
    String? description,
    String? status,
    bool? completed,
    String? phone,
    String? email,
    String? dueDate,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      title: title ?? this.title,
      subtype: subtype ?? this.subtype,
      date: date ?? this.date,
      time: time ?? this.time,
      description: description ?? this.description,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  // Helper getters for backward compatibility
  String? get subject => title;
  String? get type => subtype;
  String? get notes => description;
}
