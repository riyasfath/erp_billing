import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart'; // <- uses your authorized Dio client
import 'package:pokakbilling/models/data-models/salesperson_model.dart';

class SalesPersonService {
  static Future<String?> createSalesPerson(
    String firstName,
    String lastName,
    String designation,
    String country,
    String state,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'designation': designation,
        'country': country,
        'state': state,
        'address': address,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'incentive': incentive,
      };

      final response =
          await dio.post(ApiConstants.salesPersonEndPoint, data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      } else {
        return response.data.toString();
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        return "Unauthorized: Please login.";
      }
      final err = e.response?.data ?? e.message;
      return err.toString();
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  // Helper: normalize various shapes into List<SalesPersonModel>
  static List<SalesPersonModel> _parseSalesPersonList(dynamic raw) {
    try {
      if (raw == null) return [];

      if (raw is List) {
        return raw
            .where((e) => e != null)
            .map((e) =>
                SalesPersonModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('id') || raw.containsKey('first_name')) {
          return [SalesPersonModel.fromJson(Map<String, dynamic>.from(raw))];
        }
        if (raw.containsKey('Data')) {
          return _parseSalesPersonList(raw['Data']);
        }
        if (raw.containsKey('data')) {
          return _parseSalesPersonList(raw['data']);
        }
      }

      return [];
    } catch (e) {
      print('[SalesPersonService] _parseSalesPersonList error: $e');
      return [];
    }
  }

  /// GET all sales persons (uses authorized dio)
  static Future<List<SalesPersonModel>> getSalesPersons() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.salesPersonEndPoint);

      if (response.statusCode == 200) {
        final respData = response.data;

        if (respData is Map<String, dynamic>) {
          final status = respData['Status']?.toString();
          if (status != null && status != '1') {
            final msg = respData['message'] ?? 'Server returned error';
            throw Exception(msg);
          }
          if (respData.containsKey('Data')) {
            return _parseSalesPersonList(respData['Data']);
          }
          return _parseSalesPersonList(respData);
        }

        if (respData is List) {
          return _parseSalesPersonList(respData);
        }

        return [];
      } else if (response.statusCode == 401) {
        // explicit unauthorized response handling
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'Unauthorized');
      } else {
        throw Exception('Failed to load Sales Persons: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        // bubble up a friendly exception message for viewmodel to handle
        throw Exception('Unauthorized (401). Please login again.');
      }
      final err = e.response?.data ?? e.message;
      throw Exception(err.toString());
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<String?> deleteSalesPerson(int salesPersonId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.delete(ApiConstants.salesPersonByIdEndpoint(salesPersonId));
      if (response.statusCode == 200 || response.statusCode == 204) return null;
      return response.data.toString();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        return "Unauthorized: Please login.";
      }
      final err = e.response?.data ?? e.message;
      return err.toString();
    } catch (e) {
      return "Unexpected error: $e";
    }
  }

  static Future<List<SalesPersonModel>> getSalesPersonById(
      int salesPersonId) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.get(ApiConstants.salesPersonByIdEndpoint(salesPersonId));

      if (response.statusCode == 200) {
        final respData = response.data;
        if (respData is Map<String, dynamic>) {
          if (respData.containsKey('Data')) {
            return _parseSalesPersonList(respData['Data']);
          }
          if (respData.containsKey('id') ||
              respData.containsKey('first_name')) {
            return _parseSalesPersonList(respData);
          }
          if (respData.containsKey('data')) {
            return _parseSalesPersonList(respData['data']);
          }
        }
        if (respData is List) {
          return _parseSalesPersonList(respData);
        }
        print(
            '[SalesPersonService] getSalesPersonById: unexpected type ${respData.runtimeType}');
        return [];
      } else if (response.statusCode == 401) {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: 'Unauthorized');
      } else {
        throw Exception('Failed to load Sales Person: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        throw Exception('Unauthorized (401). Please login again.');
      }
      final err = e.response?.data ?? e.message;
      throw Exception(err.toString());
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<String?> editSalesPerson(
    int salesPersonId,
    String firstName,
    String lastName,
    String designation,
    String country,
    String state,
    String address,
    String email,
    String phone,
    String mobile,
    String incentive,
  ) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'designation': designation,
        'country': country,
        'state': state,
        'address': address,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'incentive': incentive,
      };

      final response = await dio.patch(
          ApiConstants.salesPersonByIdEndpoint(salesPersonId),
          data: data);

      if (response.statusCode == 200) return null;
      return response.data.toString();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        return "Unauthorized: Please login.";
      }
      final err = e.response?.data ?? e.message;
      return err.toString();
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
