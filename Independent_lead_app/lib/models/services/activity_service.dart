import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/activity-model/activity_model.dart';

class OrganiserService {
  // ─────────────────────────────────────────────────────────
  // GET ALL ACTIVITIES  →  GET /organiser/
  // ─────────────────────────────────────────────────────────
  Future<List<AllActivityModel>> getAllActivities() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.organiserEndpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;
        List data;

        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('results')) {
          data = responseData['results'];
        } else {
          throw Exception("Unexpected response format");
        }

        return data.map((e) => AllActivityModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load organiser items");
      }
    } catch (e) {
      throw Exception("OrganiserService.getAllActivities error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────
  // SCHEDULE MEETING  →  POST /meetings/
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> scheduleMeeting({
    required int leadId,
    required String title,
    required String description,
    required String subtype,
    required String location,
    required String dueDate, // ISO-8601
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.meetingsEndpoint,
        data: {
          "lead": leadId,
          "title": title,
          "description": description,
          "subtype": subtype,
          "location": location,
          "due_date": dueDate,
          "status": "PENDING",
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to schedule meeting");
      }
    } catch (e) {
      throw Exception("OrganiserService.scheduleMeeting error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────
  // SCHEDULE FOLLOW-UP  →  POST /follow-ups/
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> scheduleFollowUp({
    required int leadId,
    required String title,
    required String description,
    required String dueDate,
    String activityType = "FOLLOW_UP", // CALL, EMAIL, FOLLOW_UP
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.followupsEndpoint,
        data: {
          "lead": leadId,
          "title": title,
          "description": description,
          "due_date": dueDate,
          "status": "PENDING",
          "activity_type": activityType,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to schedule follow-up");
      }
    } catch (e) {
      throw Exception("OrganiserService.scheduleFollowUp error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────
  // SET REMINDER  →  POST /reminders/
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> setReminder({
    required int leadId,
    required String title,
    required String description,
    required String subtype,
    required String dueDate,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.remindersEndpoint,
        data: {
          "lead": leadId,
          "title": title,
          "description": description,
          "subtype": subtype,
          "due_date": dueDate,
          "status": "PENDING",
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to set reminder");
      }
    } catch (e) {
      throw Exception("OrganiserService.setReminder error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────
  // LOG CALL  →  POST /communications/log_call/
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> logCall({
    required int leadId,
    required String phoneNumber,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.logCallEndpoint,
        data: {
          "lead": leadId,
          "phone_number": phoneNumber,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to log call");
      }
    } catch (e) {
      throw Exception("OrganiserService.logCall error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────
  // LOG WHATSAPP  →  POST /communications/log_whatsapp/
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> logWhatsApp({
    required int leadId,
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.logWhatsappEndpoint,
        data: {
          "lead": leadId,
          "phone_number": phoneNumber,
          "message": message,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to log WhatsApp");
      }
    } catch (e) {
      throw Exception("OrganiserService.logWhatsApp error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────
  // LOG EMAIL  →  POST /communications/log_email/
  // ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> logEmail({
    required int leadId,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.post(
        ApiConstants.logEmailEndpoint,
        data: {
          "lead": leadId,
          "email": email,
          "subject": subject,
          "message": message,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to log email");
      }
    } catch (e) {
      throw Exception("OrganiserService.logEmail error: $e");
    }
  }
}
