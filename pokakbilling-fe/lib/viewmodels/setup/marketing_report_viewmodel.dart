// // lib/viewmodels/setup/marketing_report_viewmodel.dart

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
// import 'package:pokakbilling/models/services/marketing_report_service.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

// class MarketingReportViewmodel extends ChangeNotifier {
//   List<MarketingReport> _reports = [];
//   List<MarketingReport> _allReports = [];

//   bool _isLoading = false;
//   bool _addReportLoading = false;
//   bool _editReportLoading = false;
//   bool _deleteReportLoading = false;
//   String? _errorMessage;
//   bool _disposed = false;

//   List<MarketingReport> get reports => _reports;
//   bool get isLoading => _isLoading;
//   bool get addReportLoading => _addReportLoading;
//   bool get editReportLoading => _editReportLoading;
//   bool get deleteReportLoading => _deleteReportLoading;
//   String? get errorMessage => _errorMessage;

//   // Filter fields (api-format dates: yyyy-MM-dd)
//   String? fromDate;
//   String? toDate;
//   int? selectedSourceId;
//   int? selectedCategoryId;
//   int? selectedLocationId;
//   int? selectedSalespersonId;

//   bool get hasActiveFilters =>
//       (fromDate?.isNotEmpty ?? false) ||
//       (toDate?.isNotEmpty ?? false) ||
//       selectedSourceId != null ||
//       selectedCategoryId != null ||
//       selectedLocationId != null ||
//       selectedSalespersonId != null;

//   MarketingReportViewmodel() {
//     fetchReports();
//   }

//   Future<void> fetchReports(
//       {bool useFilters = false, Map<String, dynamic>? explicitFilters}) async {
//     if (_disposed) return;
//     _isLoading = true;
//     _safeNotifyListeners();

//     try {
//       Map<String, dynamic>? filters;
//       if (explicitFilters != null) {
//         filters = Map<String, dynamic>.from(explicitFilters);
//       } else if (useFilters) {
//         filters = <String, dynamic>{};
//         if (fromDate?.isNotEmpty ?? false) filters['from_date'] = fromDate;
//         if (toDate?.isNotEmpty ?? false) filters['to_date'] = toDate;
//         if (selectedSourceId != null) filters['source_id'] = selectedSourceId;
//         if (selectedCategoryId != null) {
//           filters['category_id'] = selectedCategoryId;
//         }
//         if (selectedLocationId != null) {
//           filters['location_id'] = selectedLocationId;
//         }
//         if (selectedSalespersonId != null) {
//           filters['salesperson_id'] = selectedSalespersonId;
//         }
//         if (filters.isEmpty) filters = null;
//       } else {
//         filters = null;
//       }

//       final fetched = await MarketingReportService.getReports(filters: filters);
//       if (!_disposed) {
//         _allReports = fetched.map((e) {
//           if (e is Map<String, dynamic>) return MarketingReport.fromJson(e);
//           return MarketingReport.fromJson(Map<String, dynamic>.from(e));
//         }).toList();
//         _reports = _applyLocalFilters(_allReports);
//         _errorMessage = null;
//       }
//     } catch (e) {
//       if (!_disposed) {
//         _errorMessage = e.toString();
//         _reports = [];
//         _allReports = [];
//       }
//     }

//     if (!_disposed) {
//       _isLoading = false;
//       _safeNotifyListeners();
//     }
//   }

//   List<MarketingReport> _applyLocalFilters(List<MarketingReport> items) {
//     if (!hasActiveFilters) return List<MarketingReport>.from(items);

//     final List<MarketingReport> filtered = [];
//     final apiFormat = DateFormat('yyyy-MM-dd');

//     DateTime? from;
//     DateTime? to;
//     try {
//       if (fromDate != null && fromDate!.isNotEmpty) {
//         from = apiFormat.parse(fromDate!);
//       }
//     } catch (_) {}
//     try {
//       if (toDate != null && toDate!.isNotEmpty) to = apiFormat.parse(toDate!);
//     } catch (_) {}

//     for (final r in items) {
//       bool keep = true;
//       if (selectedSourceId != null) {
//         if (r.sourceId != 0) {
//           if (r.sourceId != selectedSourceId) keep = false;
//         } else {
//           keep = false;
//         }
//       }
//       if (keep && selectedCategoryId != null) {
//         if (r.categoryId != 0) {
//           if (r.categoryId != selectedCategoryId) keep = false;
//         } else {
//           keep = false;
//         }
//       }
//       if (keep && selectedLocationId != null) {
//         if (r.locationId != 0) {
//           if (r.locationId != selectedLocationId) keep = false;
//         } else {
//           keep = false;
//         }
//       }
//       if (keep && selectedSalespersonId != null) {
//         if (r.salespersonId != 0) {
//           if (r.salespersonId != selectedSalespersonId) keep = false;
//         } else {
//           keep = false;
//         }
//       }
//       if (keep && (from != null || to != null)) {
//         try {
//           final rd = apiFormat.parse(r.date);
//           if (from != null && rd.isBefore(from)) keep = false;
//           if (to != null && rd.isAfter(to)) keep = false;
//         } catch (_) {
//           keep = false;
//         }
//       }
//       if (keep) filtered.add(r);
//     }

//     return filtered;
//   }

//   // CREATE - now accepts optional extraData (nested payload)
//   Future<void> createReport({
//     required String date,
//     required int salespersonId,
//     required int sourceId,
//     required int locationId,
//     required int categoryId,
//     required int calls,
//     required int leads,
//     required BuildContext context,
//     Map<String, dynamic>? extraData,
//   }) async {
//     if (_disposed) return;

//     try {
//       _addReportLoading = true;
//       _safeNotifyListeners();

//       final payload = extraData ??
//           {
//             'date': date,
//             'salesperson_id': salespersonId,
//             'source_id': sourceId,
//             'location_id': locationId,
//             'category_id': categoryId,
//             'calls': calls,
//             'leads': leads,
//           };

//       String? response = await MarketingReportService.createReport(payload);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(context, "Marketing report created successfully!");
//         await fetchReports(useFilters: hasActiveFilters);
//         Navigator.pop(context, true);
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       if (!_disposed && context.mounted) {
//         showOverlayError(context, "Failed to create report");
//       }
//     } finally {
//       if (!_disposed) {
//         _addReportLoading = false;
//         _safeNotifyListeners();
//       }
//     }
//   }

//   // UPDATE (unchanged signature) — service will accept nested payload if provided in future
//   Future<void> editReport({
//     required int reportId,
//     required String date,
//     required int salespersonId,
//     required int sourceId,
//     required int locationId,
//     required int categoryId,
//     required int calls,
//     required int leads,
//     required BuildContext context,
//   }) async {
//     if (_disposed) return;
//     try {
//       _editReportLoading = true;
//       _safeNotifyListeners();

//       String? response = await MarketingReportService.updateReport(reportId, {
//         'date': date,
//         'salesperson_id': salespersonId,
//         'source_id': sourceId,
//         'location_id': locationId,
//         'category_id': categoryId,
//         'calls': calls,
//         'leads': leads,
//       });

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(context, "Report Updated Successfully!");
//         await fetchReports(useFilters: hasActiveFilters);
//         Navigator.pop(context, true);
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       if (!_disposed && context.mounted) {
//         showOverlayError(context, "Failed to update report");
//       }
//     } finally {
//       if (!_disposed) {
//         _editReportLoading = false;
//         _safeNotifyListeners();
//       }
//     }
//   }

//   // DELETE unchanged
//   Future<void> deleteReport(int reportId, BuildContext context) async {
//     if (_disposed) return;
//     try {
//       _deleteReportLoading = true;
//       _safeNotifyListeners();

//       String? response = await MarketingReportService.deleteReport(reportId);

//       if (response == null) {
//         if (!context.mounted) return;
//         showSuccessMessage(context, "Report Deleted Successfully!");
//         await fetchReports(useFilters: hasActiveFilters);
//       } else {
//         if (!context.mounted) return;
//         showOverlayError(context, response);
//       }
//     } catch (e) {
//       if (!_disposed && context.mounted) {
//         showOverlayError(context, "Failed to delete report");
//       }
//     } finally {
//       if (!_disposed) {
//         _deleteReportLoading = false;
//         _safeNotifyListeners();
//       }
//     }
//   }

//   void applyFilters(
//       {String? from,
//       String? to,
//       int? sourceId,
//       int? categoryId,
//       int? locationId,
//       int? salespersonId}) {
//     if (_disposed) return;
//     fromDate = from;
//     toDate = to;
//     selectedSourceId = sourceId;
//     selectedCategoryId = categoryId;
//     selectedLocationId = locationId;
//     selectedSalespersonId = salespersonId;
//     fetchReports(useFilters: true);
//   }

//   void clearFilters() {
//     if (_disposed) return;
//     fromDate = null;
//     toDate = null;
//     selectedSourceId = null;
//     selectedCategoryId = null;
//     selectedLocationId = null;
//     selectedSalespersonId = null;
//     if (_allReports.isNotEmpty) {
//       _reports = List<MarketingReport>.from(_allReports);
//       _safeNotifyListeners();
//       return;
//     }
//     fetchReports();
//   }

//   void clearError() {
//     if (!_disposed) {
//       _errorMessage = null;
//       _safeNotifyListeners();
//     }
//   }

//   void _safeNotifyListeners() {
//     if (!_disposed) notifyListeners();
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     super.dispose();
//   }
// }
// lib/viewmodels/setup/marketing_report_viewmodel.dart
// COMPLETE FILE - ONLY editReport() signature changed

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
import 'package:pokakbilling/models/services/marketing_report_service.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/error_message.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';

class MarketingReportViewmodel extends ChangeNotifier {
  List<MarketingReport> _reports = [];
  List<MarketingReport> _allReports = [];

  bool _isLoading = false;
  bool _addReportLoading = false;
  bool _editReportLoading = false;
  bool _deleteReportLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  List<MarketingReport> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get addReportLoading => _addReportLoading;
  bool get editReportLoading => _editReportLoading;
  bool get deleteReportLoading => _deleteReportLoading;
  String? get errorMessage => _errorMessage;

  // Filter fields (api-format dates: yyyy-MM-dd)
  String? fromDate;
  String? toDate;
  int? selectedSourceId;
  int? selectedCategoryId;
  int? selectedLocationId;
  int? selectedSalespersonId;

  bool get hasActiveFilters =>
      (fromDate?.isNotEmpty ?? false) ||
      (toDate?.isNotEmpty ?? false) ||
      selectedSourceId != null ||
      selectedCategoryId != null ||
      selectedLocationId != null ||
      selectedSalespersonId != null;

  MarketingReportViewmodel() {
    fetchReports();
  }

  Future<void> fetchReports(
      {bool useFilters = false, Map<String, dynamic>? explicitFilters}) async {
    if (_disposed) return;
    _isLoading = true;
    _safeNotifyListeners();

    try {
      Map<String, dynamic>? filters;
      if (explicitFilters != null) {
        filters = Map<String, dynamic>.from(explicitFilters);
      } else if (useFilters) {
        filters = <String, dynamic>{};
        if (fromDate?.isNotEmpty ?? false) filters['from_date'] = fromDate;
        if (toDate?.isNotEmpty ?? false) filters['to_date'] = toDate;
        if (selectedSourceId != null) filters['source_id'] = selectedSourceId;
        if (selectedCategoryId != null) {
          filters['category_id'] = selectedCategoryId;
        }
        if (selectedLocationId != null) {
          filters['location_id'] = selectedLocationId;
        }
        if (selectedSalespersonId != null) {
          filters['salesperson_id'] = selectedSalespersonId;
        }
        if (filters.isEmpty) filters = null;
      } else {
        filters = null;
      }

      final fetched = await MarketingReportService.getReports(filters: filters);
      if (!_disposed) {
        _allReports = fetched.map((e) {
          if (e is Map<String, dynamic>) return MarketingReport.fromJson(e);
          return MarketingReport.fromJson(Map<String, dynamic>.from(e));
        }).toList();
        _reports = _applyLocalFilters(_allReports);
        _errorMessage = null;
      }
    } catch (e) {
      if (!_disposed) {
        _errorMessage = e.toString();
        _reports = [];
        _allReports = [];
      }
    }

    if (!_disposed) {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  List<MarketingReport> _applyLocalFilters(List<MarketingReport> items) {
    if (!hasActiveFilters) return List<MarketingReport>.from(items);

    final List<MarketingReport> filtered = [];
    final apiFormat = DateFormat('yyyy-MM-dd');

    DateTime? from;
    DateTime? to;
    try {
      if (fromDate != null && fromDate!.isNotEmpty) {
        from = apiFormat.parse(fromDate!);
      }
    } catch (_) {}
    try {
      if (toDate != null && toDate!.isNotEmpty) to = apiFormat.parse(toDate!);
    } catch (_) {}

    for (final r in items) {
      bool keep = true;
      if (selectedSourceId != null) {
        if (r.sourceId != 0) {
          if (r.sourceId != selectedSourceId) keep = false;
        } else {
          keep = false;
        }
      }
      if (keep && selectedCategoryId != null) {
        if (r.categoryId != 0) {
          if (r.categoryId != selectedCategoryId) keep = false;
        } else {
          keep = false;
        }
      }
      if (keep && selectedLocationId != null) {
        if (r.locationId != 0) {
          if (r.locationId != selectedLocationId) keep = false;
        } else {
          keep = false;
        }
      }
      if (keep && selectedSalespersonId != null) {
        if (r.salespersonId != 0) {
          if (r.salespersonId != selectedSalespersonId) keep = false;
        } else {
          keep = false;
        }
      }
      if (keep && (from != null || to != null)) {
        try {
          final rd = apiFormat.parse(r.date);
          if (from != null && rd.isBefore(from)) keep = false;
          if (to != null && rd.isAfter(to)) keep = false;
        } catch (_) {
          keep = false;
        }
      }
      if (keep) filtered.add(r);
    }

    return filtered;
  }

  Future<void> createReport({
    required String date,
    required int salespersonId,
    required int sourceId,
    required int locationId,
    required int categoryId,
    required int calls,
    required int leads,
    required BuildContext context,
    Map<String, dynamic>? extraData,
  }) async {
    if (_disposed) return;

    try {
      _addReportLoading = true;
      _safeNotifyListeners();

      final payload = extraData ??
          {
            'date': date,
            'salesperson_id': salespersonId,
            'source_id': sourceId,
            'location_id': locationId,
            'category_id': categoryId,
            'calls': calls,
            'leads': leads,
          };

      String? response = await MarketingReportService.createReport(payload);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Marketing report created successfully!");
        await fetchReports(useFilters: hasActiveFilters);
        Navigator.pop(context, true);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to create report");
      }
    } finally {
      if (!_disposed) {
        _addReportLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  // ✅ CHANGED: Now returns Future<bool>
  Future<bool> editReport({
    required int reportId,
    required String date,
    required int salespersonId,
    required int sourceId,
    required int locationId,
    required int categoryId,
    required int calls,
    required int leads,
    required BuildContext context,
  }) async {
    if (_disposed) return false;

    try {
      _editReportLoading = true;
      _safeNotifyListeners();

      String? response = await MarketingReportService.updateReport(reportId, {
        'date': date,
        'salesperson_id': salespersonId,
        'source_id': sourceId,
        'location_id': locationId,
        'category_id': categoryId,
        'calls': calls,
        'leads': leads,
      });

      if (response == null) {
        await fetchReports(useFilters: hasActiveFilters);
        if (context.mounted) {
          showSuccessMessage(context, "Report Updated Successfully!");
        }
        return true; // ✅ Success
      } else {
        if (context.mounted) {
          showOverlayError(context, response);
        }
        return false; // ❌ Error
      }
    } catch (e) {
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to update report");
      }
      return false; // ❌ Error
    } finally {
      if (!_disposed) {
        _editReportLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> deleteReport(int reportId, BuildContext context) async {
    if (_disposed) return;
    try {
      _deleteReportLoading = true;
      _safeNotifyListeners();

      String? response = await MarketingReportService.deleteReport(reportId);

      if (response == null) {
        if (!context.mounted) return;
        showSuccessMessage(context, "Report Deleted Successfully!");
        await fetchReports(useFilters: hasActiveFilters);
      } else {
        if (!context.mounted) return;
        showOverlayError(context, response);
      }
    } catch (e) {
      if (!_disposed && context.mounted) {
        showOverlayError(context, "Failed to delete report");
      }
    } finally {
      if (!_disposed) {
        _deleteReportLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  void applyFilters(
      {String? from,
      String? to,
      int? sourceId,
      int? categoryId,
      int? locationId,
      int? salespersonId}) {
    if (_disposed) return;
    fromDate = from;
    toDate = to;
    selectedSourceId = sourceId;
    selectedCategoryId = categoryId;
    selectedLocationId = locationId;
    selectedSalespersonId = salespersonId;
    fetchReports(useFilters: true);
  }

  void clearFilters() {
    if (_disposed) return;
    fromDate = null;
    toDate = null;
    selectedSourceId = null;
    selectedCategoryId = null;
    selectedLocationId = null;
    selectedSalespersonId = null;
    if (_allReports.isNotEmpty) {
      _reports = List<MarketingReport>.from(_allReports);
      _safeNotifyListeners();
      return;
    }
    fetchReports();
  }

  void clearError() {
    if (!_disposed) {
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
