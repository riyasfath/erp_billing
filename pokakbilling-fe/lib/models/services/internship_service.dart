// lib/models/services/internship_services.dart

import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/student/course_model.dart';
import 'package:pokakbilling/models/student/student_model.dart';

class InternshipServices {
  // ── GET ALL STUDENTS ──────────────────────────────────────────────────────
  static Future<List<StudentModel>> getStudents() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.internshipStudentsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            list = data['data'] as List;
          } else if (data['results'] is List) {
            list = data['results'] as List;
          }
        }

        return list
            .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Network error fetching students: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }

  // ── GET ALL COURSES ───────────────────────────────────────────────────────
  static Future<List<InternshipCourseModel>> getCourses() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.internshipCourseEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            list = data['data'] as List;
          } else if (data['results'] is List) {
            list = data['results'] as List;
          }
        }

        return list
            .map((e) =>
                InternshipCourseModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Network error fetching courses: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }
}
