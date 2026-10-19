import 'package:flutter/material.dart';
import '../models/my_course.dart';
import '../services/course_service.dart';

class MyCoursesViewModel extends ChangeNotifier {
  final CourseService _service;
  MyCoursesViewModel(this._service) {
    load();
  }

  bool loading = true;
  List<MyCourse> courses = [];

  Future<void> load() async {
    courses = await _service.getMyCourses();
    loading = false;
    notifyListeners();
  }
}