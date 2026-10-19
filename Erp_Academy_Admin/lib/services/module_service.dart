import 'package:erp_academy/models/modules_item.dart';
import 'package:flutter/material.dart';
import '../models/lesson_item.dart';

class ModuleService {
  /// Later: API call with course id.
  Future<List<ModuleItem>> getModules(String course) async => const [
        ModuleItem(
            number: 1,
            name: 'Foundations',
            videos: 8,
            duration: '2h 15m',
            description:
                'Learn the core setup for data science projects, including environment setup, data loading, and exploratory checks.'),
        ModuleItem(
            number: 2,
            name: 'AI & Machine Learning Specialization',
            videos: 10,
            duration: '3h 40m',
            description:
                'Dive into neural networks, model training and evaluation workflows.'),
      ];

  Future<List<LessonItem>> getLessons(int moduleNumber) async => const [
        LessonItem('Introduction to Pythagorean Theorem', '10:45',
            Color(0xFF9DB8E0)),
        LessonItem('Practical Applications 3D Space', '08:20',
            Color(0xFFC9A77C)),
        LessonItem('Deriving the Theorem from First Principles', '14:10',
            Color(0xFF1B2A4A)),
        LessonItem('Solving Complex Trigonometric Problems', '12:05',
            Color(0xFF4A5560)),
      ];
}