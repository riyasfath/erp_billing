import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/project_members_model.dart';
import 'package:pokakbilling/models/data-models/project_model.dart';

class ProjectServices {
  static Future<Map<String, dynamic>?> createProject(
    int clientId,
    String projectName,
    String projectDescription,
    String startDate,
    String endDate,
    String status,
    String duration,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "contract": clientId,
        'project_name': projectName,
        'project_description': projectDescription,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
        'duration': duration,
      };

      final response = await dio.post(
        ApiConstants.projectEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        print("error occurred");
        return {
          'status': '0',
          'message': 'Unexpected error',
          'error': response.data.toString(),
        };
      }
    } on DioException catch (e) {
      print(e);
      return {
        'status': '0',
        'message': 'Error',
        'error': e.response?.data.toString() ?? "Unknown error",
      };
    } catch (e) {
      print(e);
      return {
        'status': '0',
        'message': 'Unexpected error',
        'error': e.toString(),
      };
    }
  }

  static Future<List<ProjectModel>> getAllProjects() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.projectEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> projectJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ProjectModel> projectList =
            projectJson.map((json) => ProjectModel.fromJson(json)).toList();

        return projectList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Projects');
    }
  }

  static Future<String?> deleteProject(int projectId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.projectByIdEndpoint(projectId),
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      Map<String, dynamic>? errorData = e.response?.data;

      if (errorData != null) {
        String? errorMessage = errorData.values.firstWhere(
          (value) => value is String,
          orElse: () => "Unknown error occurred",
        );
        return errorMessage;
      }
      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<List<ProjectModel>> getProjectById(int projectId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.projectByIdEndpoint(projectId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> projectJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<ProjectModel> projectList =
            projectJson.map((json) => ProjectModel.fromJson(json)).toList();

        return projectList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Project');
    }
  }

  static Future<String?> updateProject(
    int projectId,
    int clientId,
    String projectName,
    String projectDescription,
    String startDate,
    String endDate,
    String status,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "contract": clientId,
        'project_name': projectName,
        'description': projectDescription,
        'start_date': startDate,
        'end_date': endDate,
        'status': status,
      };

      final response = await dio.patch(
        ApiConstants.projectByIdEndpoint(projectId),
        data: data,
      );

      if (response.statusCode == 200) {
        return null;
      } else {
        return 'Error: ${response.data}';
      }
    } on DioException catch (e) {
      return e.response?.data.toString() ?? 'Request failed: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  static Future<String?> addMembers(
    int projectId,
    int memberId,
    int stackId,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        "project": projectId,
        'member': memberId,
        'stack': stackId,
      };

      final response = await dio.post(
        ApiConstants.projectTeamMemberEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      print("❌ Dio Error: $e");

      if (e.response != null) {
        final responseData = e.response!.data;

        if (responseData is Map<String, dynamic>) {
          String? errorMessage = responseData.values.firstWhere(
            (value) => value is String,
            orElse: () => "Unknown error occurred",
          );
          return errorMessage;
        } else if (responseData is String) {
          print("⚠️ Server responded with HTML or non-JSON: $responseData");
          return "Server error occurred. Try again later.";
        }
      }

      return "Something went wrong. Please try again.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<List<ProjectMembersModel>> getAllProjectsMembers() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.projectTeamMemberEndpoint,
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
}
