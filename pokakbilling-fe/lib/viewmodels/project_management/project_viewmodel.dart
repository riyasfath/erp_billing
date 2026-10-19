import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/project_members_model.dart';
import 'package:pokakbilling/models/data-models/project_model.dart';
import 'package:pokakbilling/models/services/project_services.dart';
import 'package:pokakbilling/models/services/task_management_services.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/project/add_members.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/project/project_main.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class ProjectViewmodel extends ChangeNotifier {
  String selectedStatus = "";
  String selectedStatusKey = "";
  int selectedClientId = 0;
  bool createProjectLoader = false;
  bool getProjectLoader = false;
  bool deleteProjectLoading = false;
  bool singleProjectLoading = false;
  bool editProject = false;
  bool addTeamMemberLoader = false;
  bool getMembersLoader = false;
  bool getProjectMemberByProjectIdLoader = false;
  var projectList = <ProjectModel>[];
  var singleProjectList = <ProjectModel>[];
  var projectMemberList = <ProjectMembersModel>[];
  var projectMemberByProjectIdList = <ProjectMembersModel>[];
  int selectedMemberId = 0;
  int selectedStackId = 0;

  void updateMemberId(int memberId) {
    selectedMemberId = memberId;
    notifyListeners();
  }

  void updateStackId(int stackId) {
    selectedStackId = stackId;
    notifyListeners();
  }

  void updateClientId(int clientId) {
    selectedClientId = clientId;
    notifyListeners();
  }

  var statusList = [
    "Not Started",
    "In Progress",
    "Completed",
    "On Hold",
    "Cancelled"
  ];

  ProjectViewmodel() {
    getAllProjects();
  }

  void selectStatus(String status) {
    selectedStatus = status;
    switch (status) {
      case "Not Started":
        selectedStatusKey = "not_started";
        break;
      case "In Progress":
        selectedStatusKey = "in_progress";
        break;
      case "Completed":
        selectedStatusKey = "completed ";
        break;
      case "On Hold":
        selectedStatusKey = "on_hold";
        break;
      case "Cancelled":
        selectedStatusKey = "cancelled";
        break;
      default:
        selectedStatusKey = "";
    }
    notifyListeners();
  }

  Future<void> createProject(
    clientId,
    projectName,
    projectDescription,
    startDate,
    endDate,
    status,
    duration,
    BuildContext context,
  ) async {
    try {
      print("clientId => $clientId");
      print("projectName => $projectName");
      print("projectDescription => $projectDescription");
      print("startDate => $startDate");
      print("endDate => $endDate");
      print("status => $status");
      print("duration => ${duration.runtimeType}");

      createProjectLoader = true;
      notifyListeners();
      final response = await ProjectServices.createProject(
        clientId,
        projectName,
        projectDescription,
        startDate,
        endDate,
        status,
        duration,
      );

      if (response != null && response['status'] == '1') {
        if (!context.mounted) return;

        final int projectId = response['project_id'] ?? 0;
        showSuccessMessage(
            context, response['message'] ?? "Project Created Successfully!");

        getAllProjects();

        pushNavigation(context, AddMembers(projectId: projectId));
      } else {
        if (!context.mounted) return;
        showOverlayError(
            context, response?['message'] ?? "Something went wrong.");
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        showOverlayError(context, "Unexpected error: $e");
      }
    } finally {
      createProjectLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllProjects() async {
    try {
      getProjectLoader = true;
      notifyListeners();
      List<ProjectModel> projectItems = await ProjectServices.getAllProjects();

      if (projectItems.isNotEmpty) {
        projectList = projectItems;
      } else {
        projectList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getProjectLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(projectId, BuildContext context) async {
    try {
      deleteProjectLoading = true;
      notifyListeners();
      String? response = await ProjectServices.deleteProject(projectId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Project Deleted Successfully!",
        );
        getAllProjects();
        pushNavigation(context, const ProjectMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      deleteProjectLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProjectById(projectId) async {
    try {
      singleProjectLoading = true;
      notifyListeners();
      List<ProjectModel> projectItems =
          await ProjectServices.getProjectById(projectId);

      if (projectItems.isNotEmpty) {
        singleProjectList = projectItems;
      } else {
        singleProjectList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      singleProjectLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(
    projectId,
    clientId,
    projectName,
    projectDescription,
    startDate,
    endDate,
    status,
    BuildContext context,
  ) async {
    try {
      editProject = true;
      notifyListeners();

      String? response = await ProjectServices.updateProject(
        projectId,
        clientId,
        projectName,
        projectDescription,
        startDate,
        endDate,
        status,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Project has been successfully updated!",
        );
        getAllProjects();
        pushNavigation(context, const ProjectMain());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      editProject = false;
      notifyListeners();
    }
  }

  Future<void> addTeamMember(
    projectId,
    memberId,
    stackId,
    BuildContext context,
  ) async {
    try {
      addTeamMemberLoader = true;
      notifyListeners();

      String? response = await ProjectServices.addMembers(
        projectId,
        memberId,
        stackId,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Team Member Created Successfully!",
        );
        getProjectMembersByProjectId(projectId);
        pushNavigation(context, AddMembers(projectId: projectId));
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print(e);
    } finally {
      addTeamMemberLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllProjectMembers() async {
    try {
      getMembersLoader = true;
      notifyListeners();
      List<ProjectMembersModel> projectMemberItems =
          await ProjectServices.getAllProjectsMembers();

      if (projectMemberItems.isNotEmpty) {
        projectMemberList = projectMemberItems;
      } else {
        projectMemberList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getMembersLoader = false;
      notifyListeners();
    }
  }

  Future<void> getProjectMembersByProjectId(projectId) async {
    try {
      getProjectMemberByProjectIdLoader = true;
      notifyListeners();
      List<ProjectMembersModel> projectMemberItems =
          await TaskManagementServices.getAllProjectsMembers(projectId);

      if (projectMemberItems.isNotEmpty) {
        projectMemberByProjectIdList = projectMemberItems;
      } else {
        projectMemberByProjectIdList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getProjectMemberByProjectIdLoader = false;
      notifyListeners();
    }
  }
}
