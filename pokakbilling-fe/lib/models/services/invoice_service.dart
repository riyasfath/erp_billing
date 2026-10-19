// lib/models/services/invoice_service.dart

import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:pokakbilling/models/data-models/invoice/invoice_model.dart';

class InvoiceServices {
  // ── GET ALL ──────────────────────────────────────────────────────────────
  static Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.invoiceEndpoint);

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        List<dynamic> invoiceJson = [];

        if (responseData is List) {
          invoiceJson = responseData;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData['Data'] is List) {
            invoiceJson = responseData['Data'] as List;
          } else if (responseData['data'] is List) {
            invoiceJson = responseData['data'] as List;
          } else if (responseData['results'] is List) {
            invoiceJson = responseData['results'] as List;
          } else {
            invoiceJson = [responseData];
          }
        }

        return invoiceJson
            .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load invoices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Network error fetching invoices: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Error fetching invoices: $e');
    }
  }

  // ── CREATE CLIENT INVOICE ─────────────────────────────────────────────────
  static Future<String?> createClientInvoice({
    required String invoiceNumber,
    required String invoiceDate,
    required int clientId,
    required List<Map<String, dynamic>> items,
    required String remark,
    int? termsAndConditions,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final data = <String, dynamic>{
        'invoice_type': 'client',
        'invoice_number': invoiceNumber,
        'invoice_date': invoiceDate,
        'client': clientId,
        'remark': remark,
        'items': items,
      };

      if (termsAndConditions != null) {
        data['termsandconditions'] = termsAndConditions;
      }

      final response = await dio.post(
        ApiConstants.invoiceEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      }
      return response.data?.toString() ?? 'Unexpected error';
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── CREATE INTERN/STUDENT INVOICE ─────────────────────────────────────────
  static Future<String?> createInternInvoice({
    required String invoiceNumber,
    required String invoiceDate,
    required int studentId,
    required int courseId,
    required String feeAmount,
    required String sgstPercentage,
    required String cgstPercentage,
    required String remark,
    required String description,
    int? termsAndConditions,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final data = <String, dynamic>{
        'invoice_type': 'intern',
        'invoice_number': invoiceNumber,
        'invoice_date': invoiceDate,
        'intern': studentId,
        'course': courseId,
        'fee_amount': feeAmount,
        'sgst_percentage': sgstPercentage,
        'cgst_percentage': cgstPercentage,
        'remark': remark,
        'description': description,
      };

      if (termsAndConditions != null) {
        data['termsandconditions'] = termsAndConditions;
      }

      final response = await dio.post(
        ApiConstants.invoiceEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      }
      return response.data?.toString() ?? 'Unexpected error';
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── EDIT CLIENT INVOICE ───────────────────────────────────────────────────
  static Future<String?> editClientInvoice(
    int invoiceId, {
    required List<Map<String, dynamic>> items,
    required String remark,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(
        ApiConstants.invoiceByIdEndpoint(invoiceId),
        data: {'items': items, 'remark': remark},
      );

      if (response.statusCode == 200) return null;
      return response.data?.toString() ?? 'Unexpected error';
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── EDIT INTERN INVOICE ───────────────────────────────────────────────────
  static Future<String?> editInternInvoice(
    int invoiceId, {
    required String feeAmount,
    required String sgstPercentage,
    required String cgstPercentage,
    required String remark,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.patch(
        ApiConstants.invoiceByIdEndpoint(invoiceId),
        data: {
          'fee_amount': feeAmount,
          'sgst_percentage': sgstPercentage,
          'cgst_percentage': cgstPercentage,
          'remark': remark,
        },
      );

      if (response.statusCode == 200) return null;
      return response.data?.toString() ?? 'Unexpected error';
    } on DioException catch (e) {
      return _extractError(e);
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // ── private helper ─────────────────────────────────────────────────────────
  static String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      for (final key in ['detail', 'message', 'error']) {
        if (data[key] is String) return data[key] as String;
      }
      for (final val in data.values) {
        if (val is String && val.isNotEmpty) return val;
        if (val is List && val.isNotEmpty) return val.first.toString();
      }
    }
    return e.message ?? 'Network error';
  }
}
