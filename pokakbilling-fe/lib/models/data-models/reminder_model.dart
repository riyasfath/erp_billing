// lib/models/data-models/reminder_model.dart
class ReminderModel {
  final String id;
  final String? leadId; // API returns lead as string in sample
  final String? leadName;
  final String? subject; // maps to title on backend
  final String? type;
  final String? date; // yyyy-mm-dd
  final String? time; // HH:mm:ss or HH:mm
  final String? notes; // maps to description
  final String? status; // scheduled / completed etc
  final bool completed; // local flag convenience
  final String? phone;
  final String? email;
  final String? salespersonName;
  final String? salespersonCompany;

  ReminderModel({
    required this.id,
    this.leadId,
    this.leadName,
    this.subject,
    this.type,
    this.date,
    this.time,
    this.notes,
    this.status,
    this.completed = false,
    this.phone,
    this.email,
    this.salespersonName,
    this.salespersonCompany,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: (json['id'] ?? '').toString(),
      leadId: json['lead']?.toString(),
      leadName: json['lead_name']?.toString() ?? json['lead']?.toString(),
      subject: json['title']?.toString(),
      type: json['type']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      notes: json['description']?.toString() ?? json['notes']?.toString(),
      status: json['status']?.toString(),
      completed: (json['status']?.toString().toLowerCase() == 'completed') ||
          (json['completed'] == true),
      phone: json['salesperson_phone']?.toString() ?? json['phone']?.toString(),
      email: json['salesperson_email']?.toString() ?? json['email']?.toString(),
      salespersonName: json['salesperson_name']?.toString(),
      salespersonCompany: json['salesperson_company']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (leadId != null) 'lead': leadId,
      if (subject != null) 'title': subject,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (notes != null) 'description': notes,
      if (status != null) 'status': status,
      // server may not expect these fields but include for completeness:
      if (phone != null) 'salesperson_phone': phone,
      if (email != null) 'salesperson_email': email,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? leadId,
    String? leadName,
    String? subject,
    String? type,
    String? date,
    String? time,
    String? notes,
    String? status,
    bool? completed,
    String? phone,
    String? email,
    String? salespersonName,
    String? salespersonCompany,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      leadName: leadName ?? this.leadName,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      salespersonName: salespersonName ?? this.salespersonName,
      salespersonCompany: salespersonCompany ?? this.salespersonCompany,
    );
  }
}
