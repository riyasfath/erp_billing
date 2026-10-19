class ProjectMembersModel {
  int id;
  int memberId;
  int stackId;
  int projectId;
  String memberName;
  String stackName;
  String projectName;
  int taskCount;

  ProjectMembersModel({
    required this.id,
    required this.memberId,
    required this.stackId,
    required this.projectId,
    required this.memberName,
    required this.stackName,
    required this.projectName,
    required this.taskCount,
  });

  factory ProjectMembersModel.fromJson(Map<String, dynamic> json) {
    return ProjectMembersModel(
      id: json['id'] ?? 0,
      memberId: json['member'] ?? 0,
      stackId: json['stack'] ?? 0,
      projectId: json['project'] ?? 0,
      memberName: json['member_name'] ?? '',
      stackName: json['stack_name'] ?? '',
      projectName: json['project_name'] ?? '',
      taskCount: json['task_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member': memberId,
      'stack': stackId,
      'project': projectId,
      'member_name': memberName,
      'stack_name': stackName,
      'project_name': projectName,
      'task_count': taskCount,
    };
  }
}
