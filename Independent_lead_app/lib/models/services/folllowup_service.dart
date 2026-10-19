import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/followup_model.dart';

class FollowupServices {
  /// GET all followups
  static Future<List<FollowupModel>> getFollowups({
    String? activityType,
    String? status,
    String? dueDateAfter,
    String? dueDateBefore,
  }) async {
    final dio = await DioClient().getAuthorizedDio();

    final queryParams = <String, dynamic>{};
    if (activityType != null) queryParams['activity_type'] = activityType;
    if (status != null) queryParams['status'] = status;
    if (dueDateAfter != null) queryParams['due_date_after'] = dueDateAfter;
    if (dueDateBefore != null) queryParams['due_date_before'] = dueDateBefore;

    final response = await dio.get(
      ApiConstants.followupsEndpoint,
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      List<dynamic> rawList = [];

      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        if (data.containsKey('data') && data['data'] is List) {
          rawList = data['data'];
        } else if (data.containsKey('results') && data['results'] is List) {
          rawList = data['results'];
        }
      }

      return rawList
          .map((e) =>
              FollowupModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw Exception(
          'Failed to load followups. Status: ${response.statusCode}');
    }
  }

  /// GET followups for a specific lead
  static Future<List<FollowupModel>> getFollowupsByLead(int leadId) async {
    final dio = await DioClient().getAuthorizedDio();
    final endpoint = '${ApiConstants.leadsEndpoint}$leadId/followups/';

    try {
      final response = await dio.get(endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List<dynamic> rawList = [];

        if (data is List) {
          rawList = data;
        } else if (data is Map && data.containsKey('data')) {
          rawList = data['data'] is List ? data['data'] : [];
        } else if (data is Map && data.containsKey('results')) {
          rawList = data['results'] is List ? data['results'] : [];
        }

        return rawList
            .map((e) =>
                FollowupModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        return <FollowupModel>[];
      }
    } on DioException {
      return <FollowupModel>[];
    } catch (e) {
      return <FollowupModel>[];
    }
  }

  /// GET followup stats
  static Future<Map<String, dynamic>> getFollowupStats() async {
    final dio = await DioClient().getAuthorizedDio();

    try {
      final response = await dio.get(ApiConstants.followupsStatsEndpoint);

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Create a followup activity
  static Future<FollowupModel?> createFollowup({
    required int lead,
    required String title,
    String? description,
    required String dueDate,
    String status = 'PENDING',
    String activityType = 'FOLLOW_UP',
    String? location,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final Map<String, dynamic> payload = {
        'lead': lead,
        'title': title,
        'due_date': dueDate,
        'status': status.toUpperCase(),
        'activity_type': activityType.toUpperCase(),
      };

      if (description != null && description.isNotEmpty) {
        payload['description'] = description;
      }

      if (location != null && location.isNotEmpty) {
        payload['location'] = location;
      }

      debugPrint('📤 Creating followup with payload: $payload');
      debugPrint('📍 Endpoint: ${ApiConstants.followupsEndpoint}');

      final response = await dio.post(
        ApiConstants.followupsEndpoint,
        data: payload,
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map) {
          if (responseData.containsKey('data') && responseData['data'] is Map) {
            return FollowupModel.fromJson(
              Map<String, dynamic>.from(responseData['data']),
            );
          }
          if (responseData.containsKey('id') ||
              responseData.containsKey('lead')) {
            return FollowupModel.fromJson(
              Map<String, dynamic>.from(responseData),
            );
          }
        }
        return null;
      } else {
        return null;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      debugPrint('❌ Status code: ${e.response?.statusCode}');

      final resp = e.response;
      if (resp?.data != null) {
        try {
          if (resp!.data is Map && (resp.data as Map).containsKey('detail')) {
            throw Exception(resp.data['detail'].toString());
          } else if (resp.data is Map) {
            final errors = <String>[];
            (resp.data as Map).forEach((key, value) {
              if (value is List) {
                errors.add('$key: ${value.join(", ")}');
              } else {
                errors.add('$key: $value');
              }
            });
            throw Exception(errors.join(' | '));
          } else {
            throw Exception(resp.data.toString());
          }
        } catch (ex) {
          throw Exception('Request failed: ${ex.toString()}');
        }
      }
      throw Exception('Request failed: ${e.message}');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update a followup — tries PATCH first, falls back to PUT
  static Future<String?> updateFollowup(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.patch(
        ApiConstants.followupByIdEndpoint(id),
        data: updates,
      );

      debugPrint(
          '✅ updateFollowup PATCH ${response.statusCode}: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      debugPrint(
          '❌ PATCH updateFollowup failed: ${e.response?.statusCode} → ${e.response?.data}');

      // Fallback to PUT
      try {
        final dio2 = await DioClient().getAuthorizedDio();
        final response2 = await dio2.put(
          ApiConstants.followupByIdEndpoint(id),
          data: updates,
        );

        debugPrint(
            '✅ updateFollowup PUT fallback ${response2.statusCode}: ${response2.data}');

        if (response2.statusCode == 200 || response2.statusCode == 204) {
          return null;
        }
        return response2.data.toString();
      } on DioException catch (e2) {
        debugPrint(
            '❌ PUT updateFollowup also failed: ${e2.response?.statusCode} → ${e2.response?.data}');
        return e2.response?.data?.toString() ??
            e2.message ??
            'Something went wrong.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Delete a followup
  static Future<String?> deleteFollowup(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.delete(
        ApiConstants.followupByIdEndpoint(id),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return e.response?.data.toString();
      }
      return 'Something went wrong. Please try again.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Mark followup as completed
  /// Tries PATCH first, falls back to PUT
  static Future<String?> markCompleted(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final response = await dio.patch(
        ApiConstants.followupByIdEndpoint(id),
        data: {'status': 'COMPLETED'},
      );

      debugPrint(
          '✅ markCompleted PATCH ${response.statusCode}: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }
      return response.data.toString();
    } on DioException catch (e) {
      debugPrint('❌ markCompleted PATCH failed');
      debugPrint('   status : ${e.response?.statusCode}');
      debugPrint('   body   : ${e.response?.data}');
      debugPrint('   message: ${e.message}');

      // Fallback to PUT
      try {
        final dio2 = await DioClient().getAuthorizedDio();
        final response2 = await dio2.put(
          ApiConstants.followupByIdEndpoint(id),
          data: {'status': 'COMPLETED'},
        );

        debugPrint(
            '✅ markCompleted PUT fallback ${response2.statusCode}: ${response2.data}');

        if (response2.statusCode == 200 || response2.statusCode == 204) {
          return null;
        }
        return response2.data.toString();
      } on DioException catch (e2) {
        debugPrint('❌ markCompleted PUT also failed');
        debugPrint('   status : ${e2.response?.statusCode}');
        debugPrint('   body   : ${e2.response?.data}');
        return e2.response?.data?.toString() ??
            e2.message ??
            'Something went wrong.';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }
}
