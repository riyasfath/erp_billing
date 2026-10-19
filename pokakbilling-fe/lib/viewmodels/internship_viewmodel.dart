// lib/viewmodels/internship_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:pokakbilling/models/services/internship_service.dart';
import 'package:pokakbilling/models/student/course_model.dart';
import 'package:pokakbilling/models/student/student_model.dart';

class InternshipViewmodel extends ChangeNotifier {
  // ── loaders ────────────────────────────────────────────────────────────────
  bool getStudentsLoader = false;
  bool getCoursesLoader = false;

  // ── data ───────────────────────────────────────────────────────────────────
  List<StudentModel> studentList = [];
  List<InternshipCourseModel> courseList = [];

  InternshipViewmodel() {
    getAllStudents();
    getAllCourses();
  }

  // ── GET STUDENTS ───────────────────────────────────────────────────────────
  Future<void> getAllStudents() async {
    try {
      getStudentsLoader = true;
      notifyListeners();

      final list = await InternshipServices.getStudents();
      studentList = list;
    } catch (e) {
      debugPrint('Error fetching students: $e');
      studentList = [];
    } finally {
      getStudentsLoader = false;
      notifyListeners();
    }
  }

  // ── GET COURSES ────────────────────────────────────────────────────────────
  Future<void> getAllCourses() async {
    try {
      getCoursesLoader = true;
      notifyListeners();

      final list = await InternshipServices.getCourses();
      courseList = list;
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      courseList = [];
    } finally {
      getCoursesLoader = false;
      notifyListeners();
    }
  }

  void clearData() {
    studentList = [];
    courseList = [];
    notifyListeners();
  }
}
