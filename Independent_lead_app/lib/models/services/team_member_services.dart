import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/member_project_task_model.dart';
import 'package:pokakbilling/models/data-models/teamMember_model.dart';

class TeamMemberServices {
  static Future<String?> createTeamMember(
    String name,
    String role,
    String emailId,
    String phoneNumber,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      var data = {
        'name': name,
        'role': role,
        'email': emailId,
        'phone_number': phoneNumber,
      };

      final response = await dio.post(
        ApiConstants.teamMemberEndpoint,
        data: data,
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        return 'Error: ${response.data}';
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

  static Future<List<TeamMemberModel>> getTeamMembers() async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.teamMemberEndpoint,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> teamMemberJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<TeamMemberModel> teamMemberList = teamMemberJson
            .map((json) => TeamMemberModel.fromJson(json))
            .toList();

        return teamMemberList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Team Members');
    }
  }

  static Future<List<TeamMemberModel>> getTeamMemberById(
      int teamMemberId) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.teamMemberByIdEndpoint(teamMemberId),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> teamMemberJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<TeamMemberModel> teamMemeberList = teamMemberJson
            .map((json) => TeamMemberModel.fromJson(json))
            .toList();

        return teamMemeberList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Team Member');
    }
  }

  static Future<String?> deleteTeamMember(int teamMemberId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.teamMemberByIdEndpoint(teamMemberId),
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

  static Future<String?> editTeamMember(
    int teamMemberId,
    String name,
    String role,
    String emailId,
    String phoneNumber,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      var data = {
        'name': name,
        'role': role,
        'email': emailId,
        'phone_number': phoneNumber,
      };

      final response = await dio
          .patch(ApiConstants.teamMemberByIdEndpoint(teamMemberId), data: data);

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

  static Future<List<TeamMemberModel>> searchByName(String name) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.searchByNameEndpoint(name),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = response.data;
      List<dynamic> teamMemberJson = jsonData["data"];

      if (jsonData["status"] == "1") {
        List<TeamMemberModel> teamMemberList = teamMemberJson
            .map((json) => TeamMemberModel.fromJson(json))
            .toList();

        return teamMemberList;
      } else {
        throw Exception('Error: ${jsonData["message"]}');
      }
    } else {
      throw Exception('Failed to load Team Members');
    }
  }

  static Future<List<MemberProjectTaskModel>> getTaskByMemberId(
    int memberId,
  ) async {
    final dio = await DioClient().getAuthorizedDio();

    final response = await dio.get(
      ApiConstants.taskByMembersEndPoint(memberId),
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
