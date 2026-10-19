import 'package:flutter/material.dart';
import '../models/my_course.dart';
import '../models/course_detail.dart';
import '../services/course_service.dart';

class CourseDetailViewModel extends ChangeNotifier {
  final CourseService _service;
  final MyCourse course;
  CourseDetailViewModel(this._service, this.course) {
    load();
  }

  int tab = 0; // 0 Modules, 1 Live
  CourseDetail? detail;

  Future<void> load() async {
    detail = await _service.getDetail(course.id);
    notifyListeners();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }
}