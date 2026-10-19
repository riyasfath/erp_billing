import 'package:flutter/material.dart';

import '../models/course_item_model.dart';

/// Course detail page state. All data comes from the real course object.
class CourseDetailViewModel extends ChangeNotifier {
  CourseDetailViewModel(this.course);

  final CourseItem course;

  static const tabs = [
    'Study Materials',
    'Enrolled Students',
    'Fee Configuration',
    'Faculty',
    'Class Schedule',
  ];

  static const materialTypes = ['All Types', 'PDF', 'Video', 'Document', 'Link'];

  int tab = 0;
  String materialQuery = '';
  String materialType = materialTypes.first;

  void setTab(int i) {
    if (i == tab) return;
    tab = i;
    notifyListeners();
  }

  void searchMaterials(String q) {
    materialQuery = q;
    notifyListeners();
  }

  void setMaterialType(String? t) {
    materialType = t ?? materialTypes.first;
    notifyListeners();
  }
}