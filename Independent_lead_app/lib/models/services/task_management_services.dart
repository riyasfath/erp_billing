import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
import 'package:pokakbilling/models/data-models/project_members_model.dart';

class TaskManagementServices {
  static Future<List<ProjectMembersModel>> getAllProjectsMembers(
    int projectId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.projectMembersEndpoint(projectId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> membersJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ProjectMembersModel> membersList = membersJson
            .map((json) => ProjectMembersModel.fromJson(json))
            .toList();

        return membersList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Members');
    }
  }

  static Future<String?> createTask(
    int projectMemberId,
    String taskName,
    String taskDescription,
    String startDate,
    String endDate,
    String status,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'project_member': projectMemberId,
        'task_name': taskName,
        'task_description': taskDescription,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
      };

      final response = await dio.post(
        ApiConstants.taskManagementEndPoint,
        data: data,
      );

      if (response.statusCode == 201) {
        return null; // Success
      } else {
        return 'Error: ${response.data}'; // Return raw response in case of failure
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          final errors = e.response?.data['Errors'];
          if (errors != null && errors.containsKey('unit')) {
            return errors['unit'][0];
          }
        } catch (_) {
          return 'Validation failed.';
        }
      }
      return 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  static Future<List<MemberProjectTaskModel>> getTaskList(
    int projectMemberId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.projectMembersByIdEndpoint(projectMemberId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> taskListJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<MemberProjectTaskModel> taskList = taskListJson
            .map((json) => MemberProjectTaskModel.fromJson(json))
            .toList();

        return taskList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to Team Member Task');
    }
  }

  // Update task by id
  static Future<String?> updateTask(
    int taskId,
    String taskName,
    String taskDescription,
    String startDate,
    String endDate,
    String status,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'task_name': taskName,
        'task_description': taskDescription,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
      };
      final response = await dio
          .patch(ApiConstants.taskManagementByIdEndPoint(taskId), data: data);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return 'Validation failed: ${e.response?.data}';
      }
      return 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // Delete task by id
  static Future<String?> deleteTask(int taskId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.delete(ApiConstants.taskManagementByIdEndPoint(taskId));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return 'Failed to delete: ${e.response?.data}';
      }
      return 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  static Future<List<MemberProjectTaskModel>> getTaskById(int memberId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.taskManagementByIdEndPoint(memberId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> taskListJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<MemberProjectTaskModel> taskList = taskListJson
            .map((json) => MemberProjectTaskModel.fromJson(json))
            .toList();

        return taskList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to Team Member Task');
    }
  }
}
