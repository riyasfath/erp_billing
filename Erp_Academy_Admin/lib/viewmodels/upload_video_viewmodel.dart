import 'package:erp_academy/models/video_upload_data_model.dart';
import 'package:flutter/material.dart';
import '../services/course_service.dart';

class UploadVideoViewModel extends ChangeNotifier {
  final CourseService _service;
  UploadVideoViewModel(this._service) {
    _loadDomains();
  }

  List<String> domains = ['Digital Marketing'];
  String selectedDomain = 'Digital Marketing';
  bool busy = false;

  Future<void> _loadDomains() async {
    domains = await _service.getDomains();
    if (!domains.contains(selectedDomain)) selectedDomain = domains.first;
    notifyListeners();
  }

  void setDomain(String? v) {
    if (v == null) return;
    selectedDomain = v;
    notifyListeners();
  }

  Future<bool> upload(String title, String subtitle, String module) =>
      _run(() => _service.uploadVideo(_data(title, subtitle, module)));

  Future<bool> saveDraft(String title, String subtitle, String module) =>
      _run(() => _service.saveDraft(_data(title, subtitle, module)));

  VideoUploadData _data(String t, String s, String m) => VideoUploadData(
      title: t, subtitle: s, module: m, domain: selectedDomain);

  Future<bool> _run(Future<bool> Function() job) async {
    busy = true;
    notifyListeners();
    final ok = await job();
    busy = false;
    notifyListeners();
    return ok;
  }
}