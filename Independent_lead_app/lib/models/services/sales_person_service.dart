import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';

class SalesPersonService {
  // ================= CREATE =================
  static Future<String?> createSalesPerson(
      String firstName,
      String lastName,
      String designation,
      String country,
      String state,
      String city,
      String address,
      String email,
      String phone,
      String mobile,
      String incentive,
      String password,
      {int? linkedUser,
      String? profilePicture}) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = {
        'user': {
          'username': email,
          'password': password,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
        },
        'designation': designation,
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'mobile': mobile,
        'incentive': incentive,
        if (linkedUser != null) 'linked_user': linkedUser,
        if (profilePicture != null) 'profile_picture': profilePicture,
      };

      final response =
          await dio.post(ApiConstants.salesPersonEndPoint, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      }
      return response.data.toString();
    } on DioException catch (e) {
      return (e.response?.data ?? e.message).toString();
    }
  }

  // ================= PARSER =================
  static List<SalesPersonModel> _parseSalesPersonList(dynamic raw) {
    try {
      if (raw == null) return [];

      if (raw is List) {
        return raw
            .map((e) => SalesPersonModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('data')) {
          return _parseSalesPersonList(raw['data']);
        }
        if (raw.containsKey('Data')) {
          return _parseSalesPersonList(raw['Data']);
        }
        if (raw.containsKey('id')) {
          return [SalesPersonModel.fromJson(raw)];
        }
      }

      return [];
    } catch (e) {
      print('[SalesPersonService] parse error: $e');
      return [];
    }
  }

  // ================= GET ALL =================
  static Future<List<SalesPersonModel>> getSalesPersons() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.salesPersonEndPoint);

      if (response.statusCode == 200) {
        return _parseSalesPersonList(response.data);
      }

      throw Exception('Failed to load sales persons');
    } on DioException catch (e) {
      throw Exception((e.response?.data ?? e.message).toString());
    }
  }

  // ================= GET BY ID =================
  static Future<List<SalesPersonModel>> getSalesPersonById(
      int salesPersonId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.get(ApiConstants.salesPersonByIdEndpoint(salesPersonId));

      if (response.statusCode == 200) {
        return _parseSalesPersonList(response.data);
      }

      throw Exception('Failed to load sales person');
    } on DioException catch (e) {
      throw Exception((e.response?.data ?? e.message).toString());
    }
  }

  // ================= DELETE =================
  static Future<String?> deleteSalesPerson(int salesPersonId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.delete(ApiConstants.salesPersonByIdEndpoint(salesPersonId));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }
      return response.data.toString();
    } on DioException catch (e) {
      return (e.response?.data ?? e.message).toString();
    }
  }

  // ================= EDIT =================
  static Future<String?> editSalesPerson(
    int salesPersonId,
    String firstName,
    String lastName,
    String designation,
    String country,
    String state,
    String city,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive, {
    int? linkedUser,
    String? profilePicture,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      final data = {
        'user': {
          'email': email,
          'username': email, // required
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
        },
        'designation': designation,
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'mobile': mobile,
        'incentive': incentive,
        if (linkedUser != null) 'linked_user': linkedUser,
        if (profilePicture != null) 'profile_picture': profilePicture,
      };

      final response = await dio.put(
        ApiConstants.salesPersonByIdEndpoint(salesPersonId),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) return null;
      return response.data.toString();
    } on DioException catch (e) {
      return (e.response?.data ?? e.message).toString();
    }
  }
}
