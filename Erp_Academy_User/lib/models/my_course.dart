import 'package:flutter/material.dart';

class MyCourse {
  final String id, title, description, instructor, date;
  final int progress, participants;
  final Color color; // image placeholder
  const MyCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.date,
    required this.progress,
    required this.participants,
    required this.color,
  });
}