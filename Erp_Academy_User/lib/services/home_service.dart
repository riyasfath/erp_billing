import 'package:flutter/material.dart';
import '../models/upcoming_class.dart';
import '../models/continue_item.dart';
import '../models/course_item.dart';
import '../models/activity_item.dart';

class HomeService {
  Future<UpcomingClass> getUpcoming() async => const UpcomingClass(
        title: 'UI/UX Design Masterclass',
        subtitle: 'Design Systems in Figma',
        instructor: 'Dr. Anita Sharma',
        time: 'Today, 11:00 AM · 90 min',
        startsInSeconds: 2 * 3600 + 15 * 60 + 32, // 02:15:32
      );

  Future<ContinueItem> getContinue() async => const ContinueItem(
      'Module 2 · Lesson 3', 'Introduction to UI/UX Design', '24:30', 72);

  Future<List<CourseItem>> getCourses() async => const [
        CourseItem('Python for\nData Science', 45, Color(0xFF9DB8E0)),
        CourseItem('Digital\nMarketing', 88, Color(0xFFF2B8C6)),
      ];

  Future<List<ActivityItem>> getActivity() async => const [
        ActivityItem('Completed Basic Concepts', 'UI/UX Design', '2h ago',
            Icons.check, Color(0xFF22C55E)),
        ActivityItem('Downloaded Chapter 01 Notes', 'Python for Data Science',
            '5h ago', Icons.download, Color(0xFF8B5CF6)),
      ];
}