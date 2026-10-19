// lib/viewmodels/setup/course_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:pokakbilling/models/services/course_services.dart';
import 'package:pokakbilling/models/student/course_model.dart';

class CourseViewmodel extends ChangeNotifier {
  bool isLoading = false;
  List<InternshipCourseModel> courses = [];

  CourseViewmodel() {
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      isLoading = true;
      notifyListeners();

      final fetched = await CourseServices.getCourses();
      courses = fetched;
    } catch (e) {
      debugPrint('fetchCourses error: $e');
      courses = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    courses = [];
    isLoading = false;
    notifyListeners();
  }
}
