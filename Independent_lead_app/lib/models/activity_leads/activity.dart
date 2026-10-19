// lib/models/data-models/activity_model.dart
class ActivityModel {
  final String id;
  final int leadId;
  final String activityType;
  final String action;
  final String? createdAt;
  final String? createdBy;

  ActivityModel({
    required this.id,
    required this.leadId,
    required this.activityType,
    required this.action,
    this.createdAt,
    this.createdBy,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      leadId: json['lead'] is int
          ? json['lead'] as int
          : int.tryParse('${json['lead']}') ?? 0,
      activityType: json['activity_type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
      createdBy:
          json['created_by']?.toString() ?? json['createdBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lead': leadId,
      'activity_type': activityType,
      'action': action,
    };
  }
}
