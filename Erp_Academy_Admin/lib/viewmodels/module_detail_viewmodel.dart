import 'package:flutter/material.dart';
import '../models/lesson_item.dart';
import '../services/module_service.dart';

class ModuleDetailViewModel extends ChangeNotifier {
  final ModuleService _service;
  final int moduleNumber;

  ModuleDetailViewModel(this._service, this.moduleNumber) {
    load();
  }

  bool loading = true;
  List<LessonItem> lessons = [];

  Future<void> load() async {
    lessons = await _service.getLessons(moduleNumber);
    loading = false;
    notifyListeners();
  }
}