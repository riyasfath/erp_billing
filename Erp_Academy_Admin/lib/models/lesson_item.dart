import 'package:flutter/material.dart';

class LessonItem {
  final String title, duration;
  final Color color; // thumbnail placeholder, later: image url
  const LessonItem(this.title, this.duration, this.color);
}