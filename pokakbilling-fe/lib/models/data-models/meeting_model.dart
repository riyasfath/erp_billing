// lib/models/data-models/meeting_model.dart
class MeetingModel {
  int meetingId;
  String leadName;
  int leadId;
  String date;
  String time;
  String status;
  String phone;
  String title;
  String? meetingType;
  String? meetingPlace;
  String? description;

  MeetingModel({
    required this.meetingId,
    required this.leadName,
    required this.leadId,
    required this.date,
    required this.time,
    required this.status,
    required this.phone,
    required this.title,
    this.meetingType,
    this.meetingPlace,
    this.description,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse('$v') ?? 0;
    }

    return MeetingModel(
      meetingId: toInt(json['id']),
      leadName: json['lead_name']?.toString() ?? '',
      leadId: toInt(json['lead_id']),
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      title: json['title']?.toString() ?? json['subject']?.toString() ?? '',
      meetingType: json['meeting_type']?.toString(),
      meetingPlace: json['meeting_place']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': meetingId,
      'lead_name': leadName,
      'lead_id': leadId,
      'date': date,
      'time': time,
      'status': status,
      'phone': phone,
      'title': title,
      'meeting_type': meetingType,
      'meeting_place': meetingPlace,
      'description': description,
    };
  }
}
