// // lib/models/services/marketing_report_service.dart

// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';

// class MarketingReportService {
//   // CREATE marketing report
//   static Future<String?> createReport(Map<String, dynamic> data) async {
//     try {
//       final dio = await DioClient().getAuthorizedDio();
//       final payload = _buildPayload(data);

//       print('[MarketingReportService] POST payload: ${jsonEncode(payload)}');

//       final response = await dio.post(
//         ApiConstants.marketingReportEndpoint,
//         data: payload,
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         print('[MarketingReportService] Report created successfully');
//         return null;
//       }

//       print('[MarketingReportService] Unexpected response: ${response.data}');
//       return 'Failed to create report';
//     } on DioException catch (e) {
//       print('[MarketingReportService] DioException: ${e.response?.data}');
//       if (e.response?.data != null) {
//         return e.response?.data.toString();
//       }
//       if (e.response?.statusCode == 401) return 'Unauthorized. Please login.';
//       return 'Server error: ${e.message}';
//     } catch (e) {
//       print('[MarketingReportService] Exception: $e');
//       return 'Error creating marketing report';
//     }
//   }

//   // GET reports (kept similar to your previous method)
//   static Future<List<dynamic>> getReports(
//       {Map<String, dynamic>? filters}) async {
//     try {
//       final dio = await DioClient().getAuthorizedDio();
//       final response = await dio.get(ApiConstants.marketingReportEndpoint,
//           queryParameters: filters);
//       if (response.statusCode == 200) {
//         final data = response.data;
//         if (data is List) return data;
//         if (data is Map && data['data'] is List) return data['data'] as List;
//       }
//       return [];
//     } on DioException catch (e) {
//       print('[MarketingReportService] Fetch DioException: ${e.response?.data}');
//       return [];
//     } catch (e) {
//       print('[MarketingReportService] Fetch Exception: $e');
//       return [];
//     }
//   }

//   // UPDATE report
//   static Future<String?> updateReport(int id, Map<String, dynamic> data) async {
//     try {
//       final dio = await DioClient().getAuthorizedDio();
//       final payload = _buildPayload(data);
//       print('[MarketingReportService] PATCH payload: ${jsonEncode(payload)}');

//       final response = await dio.patch(
//           ApiConstants.marketingReportByIdEndpoint(id),
//           data: payload,
//           options: Options(headers: {'Content-Type': 'application/json'}));
//       if (response.statusCode == 200) {
//         return null;
//       }
//       return 'Failed to update report';
//     } on DioException catch (e) {
//       print(
//           '[MarketingReportService] Update DioException: ${e.response?.data}');
//       if (e.response?.data != null) return e.response?.data.toString();
//       if (e.response?.statusCode == 401) return 'Unauthorized';
//       return 'Error updating report';
//     } catch (e) {
//       print('[MarketingReportService] Update Exception: $e');
//       return 'Error updating report';
//     }
//   }

//   // DELETE report
//   static Future<String?> deleteReport(int id) async {
//     try {
//       final dio = await DioClient().getAuthorizedDio();
//       final response =
//           await dio.delete(ApiConstants.marketingReportByIdEndpoint(id));
//       if (response.statusCode == 200 || response.statusCode == 204) return null;
//       return 'Failed to delete report';
//     } on DioException catch (e) {
//       print(
//           '[MarketingReportService] Delete DioException: ${e.response?.data}');
//       if (e.response?.data != null) return e.response?.data.toString();
//       if (e.response?.statusCode == 401) return 'Unauthorized';
//       return 'Error deleting report';
//     } catch (e) {
//       print('[MarketingReportService] Delete Exception: $e');
//       return 'Error deleting report';
//     }
//   }

//   // Build payload - accepts 'sources' (nested), or 'entries' (flat list), or single flat values
//   static Map<String, dynamic> _buildPayload(Map<String, dynamic> data) {
//     final payload = <String, dynamic>{};

//     if (data.containsKey('date')) {
//       payload['date'] = data['date']?.toString() ?? '';
//     }
//     if (data.containsKey('salesperson_id')) {
//       payload['salesperson_id'] = data['salesperson_id'];
//     }

//     // If caller provided nested 'sources', sanitize and pass through
//     if (data.containsKey('sources') && data['sources'] is List) {
//       payload['sources'] = _sanitizeSources(data['sources'] as List);
//       return payload;
//     }

//     // If caller provided 'entries' (flat list), group them
//     final List<Map<String, dynamic>> flatEntries = [];
//     if (data.containsKey('entries') && data['entries'] is List) {
//       for (final item in (data['entries'] as List)) {
//         if (item is Map) {
//           flatEntries.add({
//             'source_id': item['source_id'],
//             'location_id': item['location_id'],
//             'category_id': item['category_id'],
//             'calls': item['calls'] ?? 0,
//             'leads': item['leads'] ?? 0,
//           });
//         }
//       }
//     } else if (data.containsKey('source_id') &&
//         data.containsKey('location_id') &&
//         data.containsKey('category_id')) {
//       // single flat item
//       flatEntries.add({
//         'source_id': data['source_id'],
//         'location_id': data['location_id'],
//         'category_id': data['category_id'],
//         'calls': data['calls'] ?? 0,
//         'leads': data['leads'] ?? 0,
//       });
//     }

//     if (flatEntries.isEmpty) {
//       payload['sources'] = [];
//       return payload;
//     }

//     // Group flat entries into nested sources -> locations -> categories
//     final Map<int, Map<int, List<Map<String, dynamic>>>> grouped = {};
//     for (final e in flatEntries) {
//       final sId = (e['source_id'] is int)
//           ? e['source_id'] as int
//           : int.tryParse('${e['source_id']}') ?? 0;
//       final lId = (e['location_id'] is int)
//           ? e['location_id'] as int
//           : int.tryParse('${e['location_id']}') ?? 0;
//       final cId = (e['category_id'] is int)
//           ? e['category_id'] as int
//           : int.tryParse('${e['category_id']}') ?? 0;
//       final calls = (e['calls'] is int)
//           ? e['calls'] as int
//           : int.tryParse('${e['calls']}') ?? 0;
//       final leads = (e['leads'] is int)
//           ? e['leads'] as int
//           : int.tryParse('${e['leads']}') ?? 0;

//       if (sId == 0 || lId == 0 || cId == 0) continue;

//       grouped.putIfAbsent(sId, () => {});
//       grouped[sId]!.putIfAbsent(lId, () => []);
//       grouped[sId]![lId]!.add({
//         'category_id': cId,
//         'calls': calls,
//         'leads': leads,
//       });
//     }

//     final List<Map<String, dynamic>> sourcesOut = [];
//     grouped.forEach((sId, locMap) {
//       final List<Map<String, dynamic>> locList = [];
//       locMap.forEach((lId, cats) {
//         locList.add({
//           'location_id': lId,
//           'categories': cats,
//         });
//       });
//       sourcesOut.add({
//         'source_id': sId,
//         'locations': locList,
//       });
//     });

//     payload['sources'] = sourcesOut;
//     return payload;
//   }

//   // Ensure nested sources structure uses expected keys and types
//   static List<Map<String, dynamic>> _sanitizeSources(List raw) {
//     final List<Map<String, dynamic>> out = [];
//     for (final s in raw) {
//       if (s is Map) {
//         final sId = (s['source_id'] is int)
//             ? s['source_id'] as int
//             : int.tryParse('${s['source_id']}') ?? 0;
//         final rawLocs = s['locations'];
//         if (sId == 0 || rawLocs == null || rawLocs is! List) continue;
//         final List<Map<String, dynamic>> locOut = [];
//         for (final l in rawLocs) {
//           if (l is Map) {
//             final lId = (l['location_id'] is int)
//                 ? l['location_id'] as int
//                 : int.tryParse('${l['location_id']}') ?? 0;
//             final rawCats = l['categories'];
//             if (lId == 0 || rawCats == null || rawCats is! List) continue;
//             final List<Map<String, dynamic>> catsOut = [];
//             for (final c in rawCats) {
//               if (c is Map) {
//                 final cId = (c['category_id'] is int)
//                     ? c['category_id'] as int
//                     : int.tryParse('${c['category_id']}') ?? 0;
//                 final calls = (c['calls'] is int)
//                     ? c['calls'] as int
//                     : int.tryParse('${c['calls']}') ?? 0;
//                 final leads = (c['leads'] is int)
//                     ? c['leads'] as int
//                     : int.tryParse('${c['leads']}') ?? 0;
//                 if (cId == 0) continue;
//                 catsOut
//                     .add({'category_id': cId, 'calls': calls, 'leads': leads});
//               }
//             }
//             if (catsOut.isNotEmpty) {
//               locOut.add({'location_id': lId, 'categories': catsOut});
//             }
//           }
//         }
//         if (locOut.isNotEmpty) out.add({'source_id': sId, 'locations': locOut});
//       }
//     }
//     return out;
//   }
// }
// lib/models/services/marketing_report_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/core/api/dio_client.dart';

class MarketingReportService {
  // CREATE marketing report
  static Future<String?> createReport(Map<String, dynamic> data) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final payload = _buildPayload(data);

      print('[MarketingReportService] POST payload: ${jsonEncode(payload)}');

      final response = await dio.post(
        ApiConstants.marketingReportEndpoint,
        data: payload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[MarketingReportService] Report created successfully');
        return null;
      }

      print('[MarketingReportService] Unexpected response: ${response.data}');
      return 'Failed to create report';
    } on DioException catch (e) {
      print('[MarketingReportService] DioException: ${e.response?.data}');
      if (e.response?.data != null) {
        return e.response?.data.toString();
      }
      if (e.response?.statusCode == 401) return 'Unauthorized. Please login.';
      return 'Server error: ${e.message}';
    } catch (e) {
      print('[MarketingReportService] Exception: $e');
      return 'Error creating marketing report';
    }
  }

  // GET reports (kept similar to your previous method)
  static Future<List<dynamic>> getReports(
      {Map<String, dynamic>? filters}) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response = await dio.get(ApiConstants.marketingReportEndpoint,
          queryParameters: filters);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) return data;
        if (data is Map && data['data'] is List) return data['data'] as List;
      }
      return [];
    } on DioException catch (e) {
      print('[MarketingReportService] Fetch DioException: ${e.response?.data}');
      return [];
    } catch (e) {
      print('[MarketingReportService] Fetch Exception: $e');
      return [];
    }
  }

  // ✅ UPDATE report - FIXED: Uses flat payload directly without nesting
  static Future<String?> updateReport(int id, Map<String, dynamic> data) async {
    try {
      final dio = await DioClient().getAuthorizedDio();

      // ✅ FIX: Build a simple flat payload for updates
      final payload = <String, dynamic>{};

      if (data.containsKey('date')) {
        payload['date'] = data['date']?.toString() ?? '';
      }
      if (data.containsKey('salesperson_id')) {
        payload['salesperson_id'] = data['salesperson_id'];
      }
      if (data.containsKey('source_id')) {
        payload['source_id'] = data['source_id'];
      }
      if (data.containsKey('location_id')) {
        payload['location_id'] = data['location_id'];
      }
      if (data.containsKey('category_id')) {
        payload['category_id'] = data['category_id'];
      }
      if (data.containsKey('calls')) {
        payload['calls'] = data['calls'];
      }
      if (data.containsKey('leads')) {
        payload['leads'] = data['leads'];
      }

      print('[MarketingReportService] PATCH payload: ${jsonEncode(payload)}');

      final response = await dio.patch(
          ApiConstants.marketingReportByIdEndpoint(id),
          data: payload,
          options: Options(headers: {'Content-Type': 'application/json'}));

      print(
          '[MarketingReportService] PATCH response status: ${response.statusCode}');
      print('[MarketingReportService] PATCH response data: ${response.data}');

      if (response.statusCode == 200) {
        return null;
      }
      return 'Failed to update report';
    } on DioException catch (e) {
      print(
          '[MarketingReportService] Update DioException: ${e.response?.data}');
      if (e.response?.data != null) return e.response?.data.toString();
      if (e.response?.statusCode == 401) return 'Unauthorized';
      return 'Error updating report';
    } catch (e) {
      print('[MarketingReportService] Update Exception: $e');
      return 'Error updating report';
    }
  }

  // DELETE report
  static Future<String?> deleteReport(int id) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      final response =
          await dio.delete(ApiConstants.marketingReportByIdEndpoint(id));
      if (response.statusCode == 200 || response.statusCode == 204) return null;
      return 'Failed to delete report';
    } on DioException catch (e) {
      print(
          '[MarketingReportService] Delete DioException: ${e.response?.data}');
      if (e.response?.data != null) return e.response?.data.toString();
      if (e.response?.statusCode == 401) return 'Unauthorized';
      return 'Error deleting report';
    } catch (e) {
      print('[MarketingReportService] Delete Exception: $e');
      return 'Error deleting report';
    }
  }

  // Build payload - accepts 'sources' (nested), or 'entries' (flat list), or single flat values
  // ✅ This is ONLY used for CREATE now, not UPDATE
  static Map<String, dynamic> _buildPayload(Map<String, dynamic> data) {
    final payload = <String, dynamic>{};

    if (data.containsKey('date')) {
      payload['date'] = data['date']?.toString() ?? '';
    }
    if (data.containsKey('salesperson_id')) {
      payload['salesperson_id'] = data['salesperson_id'];
    }

    // If caller provided nested 'sources', sanitize and pass through
    if (data.containsKey('sources') && data['sources'] is List) {
      payload['sources'] = _sanitizeSources(data['sources'] as List);
      return payload;
    }

    // If caller provided 'entries' (flat list), group them
    final List<Map<String, dynamic>> flatEntries = [];
    if (data.containsKey('entries') && data['entries'] is List) {
      for (final item in (data['entries'] as List)) {
        if (item is Map) {
          flatEntries.add({
            'source_id': item['source_id'],
            'location_id': item['location_id'],
            'category_id': item['category_id'],
            'calls': item['calls'] ?? 0,
            'leads': item['leads'] ?? 0,
          });
        }
      }
    } else if (data.containsKey('source_id') &&
        data.containsKey('location_id') &&
        data.containsKey('category_id')) {
      // single flat item
      flatEntries.add({
        'source_id': data['source_id'],
        'location_id': data['location_id'],
        'category_id': data['category_id'],
        'calls': data['calls'] ?? 0,
        'leads': data['leads'] ?? 0,
      });
    }

    if (flatEntries.isEmpty) {
      payload['sources'] = [];
      return payload;
    }

    // Group flat entries into nested sources -> locations -> categories
    final Map<int, Map<int, List<Map<String, dynamic>>>> grouped = {};
    for (final e in flatEntries) {
      final sId = (e['source_id'] is int)
          ? e['source_id'] as int
          : int.tryParse('${e['source_id']}') ?? 0;
      final lId = (e['location_id'] is int)
          ? e['location_id'] as int
          : int.tryParse('${e['location_id']}') ?? 0;
      final cId = (e['category_id'] is int)
          ? e['category_id'] as int
          : int.tryParse('${e['category_id']}') ?? 0;
      final calls = (e['calls'] is int)
          ? e['calls'] as int
          : int.tryParse('${e['calls']}') ?? 0;
      final leads = (e['leads'] is int)
          ? e['leads'] as int
          : int.tryParse('${e['leads']}') ?? 0;

      if (sId == 0 || lId == 0 || cId == 0) continue;

      grouped.putIfAbsent(sId, () => {});
      grouped[sId]!.putIfAbsent(lId, () => []);
      grouped[sId]![lId]!.add({
        'category_id': cId,
        'calls': calls,
        'leads': leads,
      });
    }

    final List<Map<String, dynamic>> sourcesOut = [];
    grouped.forEach((sId, locMap) {
      final List<Map<String, dynamic>> locList = [];
      locMap.forEach((lId, cats) {
        locList.add({
          'location_id': lId,
          'categories': cats,
        });
      });
      sourcesOut.add({
        'source_id': sId,
        'locations': locList,
      });
    });

    payload['sources'] = sourcesOut;
    return payload;
  }

  // Ensure nested sources structure uses expected keys and types
  static List<Map<String, dynamic>> _sanitizeSources(List raw) {
    final List<Map<String, dynamic>> out = [];
    for (final s in raw) {
      if (s is Map) {
        final sId = (s['source_id'] is int)
            ? s['source_id'] as int
            : int.tryParse('${s['source_id']}') ?? 0;
        final rawLocs = s['locations'];
        if (sId == 0 || rawLocs == null || rawLocs is! List) continue;
        final List<Map<String, dynamic>> locOut = [];
        for (final l in rawLocs) {
          if (l is Map) {
            final lId = (l['location_id'] is int)
                ? l['location_id'] as int
                : int.tryParse('${l['location_id']}') ?? 0;
            final rawCats = l['categories'];
            if (lId == 0 || rawCats == null || rawCats is! List) continue;
            final List<Map<String, dynamic>> catsOut = [];
            for (final c in rawCats) {
              if (c is Map) {
                final cId = (c['category_id'] is int)
                    ? c['category_id'] as int
                    : int.tryParse('${c['category_id']}') ?? 0;
                final calls = (c['calls'] is int)
                    ? c['calls'] as int
                    : int.tryParse('${c['calls']}') ?? 0;
                final leads = (c['leads'] is int)
                    ? c['leads'] as int
                    : int.tryParse('${c['leads']}') ?? 0;
                if (cId == 0) continue;
                catsOut
                    .add({'category_id': cId, 'calls': calls, 'leads': leads});
              }
            }
            if (catsOut.isNotEmpty) {
              locOut.add({'location_id': lId, 'categories': catsOut});
            }
          }
        }
        if (locOut.isNotEmpty) out.add({'source_id': sId, 'locations': locOut});
      }
    }
    return out;
  }
}
