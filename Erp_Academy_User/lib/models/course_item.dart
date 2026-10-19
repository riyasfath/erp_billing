import 'package:flutter/material.dart';

class CourseItem {
  final String title;
  final int progress;
  final Color color; // placeholder for image, later: image url
  const CourseItem(this.title, this.progress, this.color);
}