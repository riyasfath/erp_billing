class MemberProjectTaskModel {
  int id;
  int memberId;
  String projectName;
  String taskName;
  String taskDescription;
  String startDate;
  String endDate;
  String status;
  String displayStatus;

  MemberProjectTaskModel({
    required this.id,
    required this.memberId,
    required this.projectName,
    required this.taskName,
    required this.taskDescription,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.displayStatus,
  });

  factory MemberProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return MemberProjectTaskModel(
      id: json['id'] ?? 0,
      memberId: json['member'] ?? 0,
      projectName: json['project_name'] ?? '',
      taskName: json['task_name'] ?? '',
      taskDescription: json['task_description'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      displayStatus: json['status_display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member': memberId,
      'project_name': projectName,
      'task_name': taskName,
      'task_description': taskDescription,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'status_display': displayStatus,
    };
  }
}
