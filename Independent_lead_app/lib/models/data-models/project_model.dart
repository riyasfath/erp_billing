class ProjectModel {
  int projectId;
  int contractId;
  String clientFirstName;
  String clientLastName;
  String projectName;
  String projectDescription;
  String startDate;
  String endDate;
  String duration;
  String status;
  String displayStatus;
  int membersCount;
  List<ProjectMembers>? projectMembers;

  ProjectModel({
    required this.projectId,
    required this.contractId,
    required this.clientFirstName,
    required this.clientLastName,
    required this.projectName,
    required this.projectDescription,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.status,
    required this.displayStatus,
    required this.membersCount,
    required this.projectMembers,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['id'] ?? 0,
      contractId: json['contract'] ?? 0,
      clientFirstName: json['client_first_name'] ?? '',
      clientLastName: json['client_last_name'] ?? '',
      projectName: json['project_name'] ?? '',
      projectDescription: json['project_description'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      duration: json['duration'] ?? '',
      status: json['status'] ?? '',
      displayStatus: json['status_display'] ?? '',
      membersCount: json['members_count'] ?? 0,
      projectMembers:
          (json['project_members'] != null && json['project_members'] is List)
              ? (json['project_members'] as List)
                  .map((e) => ProjectMembers.fromJson(e))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': projectId,
      'contract': contractId,
      'client_first_name': clientFirstName,
      'client_last_name': clientLastName,
      'project_name': projectName,
      'project_description': projectDescription,
      'start_date': startDate,
      'end_date': endDate,
      'duration': duration,
      'status': status,
      'status_display': displayStatus,
      'members_count': membersCount,
      "projectMembers": projectMembers?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProjectMembers {
  int id;
  String stackName;
  String memberName;
  int memberId;
  int stackId;

  ProjectMembers({
    required this.id,
    required this.stackName,
    required this.memberName,
    required this.memberId,
    required this.stackId,
  });

  factory ProjectMembers.fromJson(Map<String, dynamic> json) => ProjectMembers(
        id: json["id"] ?? 0,
        stackName: json["stack_name"] ?? "",
        memberName: json["member_name"] ?? "",
        memberId: json["member"] ?? 0,
        stackId: json["stack"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "stack_name": stackName,
        "member_name": memberName,
        "member": memberId,
        "stack": stackId,
      };
}
