import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

class ClassViewModel extends ChangeNotifier {
  ClassViewModel(this._service) {
    load();
  }

  final ClassService _service;

  List<ClassItem> _all = [];
  bool loading = true;
  String? error;
  int? centerId; // null = All Centers

  int get totalClasses => _all.length;
  int get totalSections => _all.fold(0, (s, c) => s + c.sectionsCount);

  /// (id, name) of each center found in the classes list
  List<(int, String)> get centers {
    final map = <int, String>{};
    for (final c in _all) {
      if (c.centerId != null && c.centerName.isNotEmpty) {
        map[c.centerId!] = c.centerName;
      }
    }
    final list = map.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));
    return list;
  }

  List<ClassItem> get classes => centerId == null
      ? _all
      : _all.where((c) => c.centerId == centerId).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      _all = await _service.getClasses();
      if (centerId != null && !centers.any((c) => c.$1 == centerId)) {
        centerId = null;
      }
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Could not load classes. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  void setCenter(int? id) {
    centerId = id;
    notifyListeners();
  }
}