import 'package:flutter/material.dart';

enum LessonStatus { done, next, locked }

class LessonItem {
  final String title, duration;
  final LessonStatus status;
  final Color color; // thumbnail placeholder
  const LessonItem(this.title, this.duration, this.status, this.color);
}