class AllActivityModel {
  final int id;
  final int lead;
  final String title;
  final String activityType;
  final String? subtype;
  final String? location;
  final String? description;
  final String? completionNotes;
  final DateTime dueDate;
  final String status;
  final int assignedTo;
  final String assignedToName;
  final DateTime createdAt;

  AllActivityModel({
    required this.id,
    required this.lead,
    required this.title,
    required this.activityType,
    this.subtype,
    this.location,
    this.description,
    this.completionNotes,
    required this.dueDate,
    required this.status,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdAt,
  });

  /// FROM JSON
  factory AllActivityModel.fromJson(Map<String, dynamic> json) {
    return AllActivityModel(
      id: json['id'] ?? 0,
      lead: json['lead'] ?? 0,
      title: json['title'] ?? '',
      activityType: json['activity_type'] ?? '',
      subtype: json['subtype'],
      location: json['location'],
      description: json['description'],
      completionNotes: json['completion_notes'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'] ?? '',
      assignedTo: json['assigned_to'] ?? 0,
      assignedToName: json['assigned_to_name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "lead": lead,
      "title": title,
      "activity_type": activityType,
      "subtype": subtype,
      "location": location,
      "description": description,
      "completion_notes": completionNotes,
      "due_date": dueDate.toIso8601String(),
      "status": status,
      "assigned_to": assignedTo,
      "assigned_to_name": assignedToName,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
