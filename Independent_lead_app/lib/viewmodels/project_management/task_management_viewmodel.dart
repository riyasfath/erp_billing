import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
import 'package:pokakbilling/models/data-models/project_members_model.dart';
import 'package:pokakbilling/models/services/task_management_services.dart';
import 'package:pokakbilling/views/Screens/projectmanagement/task_management/task_list.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class TaskManagementViewmodel extends ChangeNotifier {
  bool getProjectMemberLoader = false;
  bool createtaskLoader = false;
  bool getTaskLoader = false;
  var projectMemberList = <ProjectMembersModel>[];
  var taskList = <MemberProjectTaskModel>[];
  String selectedStatus = "";
  String selectedStatusKey = "";
  bool updateTaskLoader = false;
  bool deleteTaskLoader = false;
  bool getSingleTaskLoader = false;
  var selectedTaskDetail = <MemberProjectTaskModel>[];

  var statusList = [
    "Not Started",
    "In Progress",
    "Completed",
    "On Hold",
    "Cancelled"
  ];

  void updateEditedStatus(String status) {
    selectedStatus = status;
    notifyListeners();
  }

  void updateEditedStatusKey(String statusKey) {
    selectedStatusKey = statusKey;
    notifyListeners();
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

  Future<void> getAllProjectMembers(projectId) async {
    try {
      getProjectMemberLoader = true;
      notifyListeners();
      List<ProjectMembersModel> projectMemberItems =
          await TaskManagementServices.getAllProjectsMembers(projectId);

      if (projectMemberItems.isNotEmpty) {
        projectMemberList = projectMemberItems;
      } else {
        projectMemberList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getProjectMemberLoader = false;
      notifyListeners();
    }
  }

  Future<void> createTask(
    projectMemberId,
    taskName,
    taskDescription,
    startDate,
    endDate,
    status,
    BuildContext context,
  ) async {
    try {
      createtaskLoader = true;
      notifyListeners();
      String? response = await TaskManagementServices.createTask(
        projectMemberId,
        taskName,
        taskDescription,
        startDate,
        endDate,
        status,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(
          context,
          "Task Created Successfully!",
        );

        await getAllTask(projectMemberId);

        if (!context.mounted) return;
        pushNavigation(context, const TaskList());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Error: $e");
      if (context.mounted) {
        showOverlayError(context, "Unexpected error: $e");
      }
    } finally {
      createtaskLoader = false;
      notifyListeners();
    }
  }

  Future<void> getAllTask(projectMemberId) async {
    try {
      getTaskLoader = true;
      notifyListeners();
      List<MemberProjectTaskModel> taskItems =
          await TaskManagementServices.getTaskList(projectMemberId);

      if (taskItems.isNotEmpty) {
        taskList = taskItems;
      } else {
        taskList.clear();
      }
    } catch (e) {
      print(e);
    } finally {
      getTaskLoader = false;
      notifyListeners();
    }
  }

  // Update Task
  Future<void> updateTask(
    int projectMemberId,
    int taskId,
    String taskName,
    String taskDescription,
    String startDate,
    String endDate,
    String status,
    BuildContext context,
  ) async {
    try {
      print("projectMemberId $projectMemberId");
      print("taskId $taskId");
      updateTaskLoader = true;
      notifyListeners();

      String? response = await TaskManagementServices.updateTask(
        taskId,
        taskName,
        taskDescription,
        startDate,
        endDate,
        status,
      );

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Task Updated Successfully!");
        await getAllTask(projectMemberId);

        if (!context.mounted) return;
        pushNavigation(context, const TaskList());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Update Task Error: $e");
      if (context.mounted) {
        showOverlayError(context, "Unexpected error: $e");
      }
    } finally {
      updateTaskLoader = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(
    int taskId,
    int projectMemberId,
    BuildContext context,
  ) async {
    try {
      print("projectMemberId $projectMemberId");
      print("taskId $taskId");
      deleteTaskLoader = true;
      notifyListeners();

      String? response = await TaskManagementServices.deleteTask(taskId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Task Deleted Successfully!");
        await getAllTask(projectMemberId);

        if (!context.mounted) return;
        pushNavigation(context, const TaskList());
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      print("Delete Task Error: $e");
      if (context.mounted) {
        showOverlayError(context, "Unexpected error: $e");
      }
    } finally {
      deleteTaskLoader = false;
      notifyListeners();
    }
  }

  Future<void> getTaskById(int taskId) async {
    try {
      getSingleTaskLoader = true;
      notifyListeners();

      List<MemberProjectTaskModel> taskList =
          await TaskManagementServices.getTaskById(taskId);

      if (taskList.isNotEmpty) {
        selectedTaskDetail = taskList;
      } else {
        selectedTaskDetail.clear();
      }
    } catch (e) {
      print("Error in getClientContractById: $e");
    } finally {
      getSingleTaskLoader = false;
      notifyListeners();
    }
  }

  void reset() {
    // clear your task lists and loading flags
    notifyListeners();
  }
}
