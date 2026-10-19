import 'package:erp_user/models/module_session.dart';
import 'package:flutter/material.dart';
import '../models/my_course.dart';
import '../models/lesson_item.dart';
import '../models/live_session_item.dart';
import '../models/course_detail.dart';

class CourseService {
  /// Later: GET /my-courses
  Future<List<MyCourse>> getMyCourses() async => const [
        MyCourse(
            id: '1',
            title: 'Digital Marketing',
            description:
                'Learn SEO, social media and paid campaigns with real-world projects.',
            instructor: 'Dr. Maya Chen',
            date: 'May 22, 2024',
            progress: 72,
            participants: 38,
            color: Color(0xFFC9B79C)),
        MyCourse(
            id: '2',
            title: 'Python for Data Science',
            description:
                'Build practical data workflows with Python, Pandas, and real-world projects.',
            instructor: 'Dr. Maya Chen',
            date: 'May 22, 2024',
            progress: 60,
            participants: 38,
            color: Color(0xFFB9C8E8)),
        MyCourse(
            id: '3',
            title: 'UI/UX Design',
            description:
                'Design systems, prototyping and usability testing in Figma.',
            instructor: 'Dr. Anita Sharma',
            date: 'May 22, 2024',
            progress: 45,
            participants: 42,
            color: Color(0xFFF2B8C6)),
      ];

  /// Later: GET /courses/{id}
  Future<CourseDetail> getDetail(String id) async => const CourseDetail(
        overviewPercent: 68,
        overview:
            'This course teaches data preparation, visualization, and modeling with Python. You will learn how to clean datasets, build dashboards, and apply practical workflows to real-world problems.',
        lessonsCount: '24 lessons',
        modules: [
          ModuleSection(
            title: 'Module 1: Foundations',
            subtitle: '4 lessons • 2h 15m total',
            doneLabel: '3 of 4 done',
            active: true,
            description:
                'Learn the core setup for data science projects, including environment setup, data loading, and exploratory checks.',
            lessons: [
              LessonItem('Introduction to Pythagorean Theorem', '10:45',
                  LessonStatus.done, Color(0xFF9DB8E0)),
              LessonItem('Practical Applications 3D Space', '08:20',
                  LessonStatus.done, Color(0xFFC9A77C)),
              LessonItem('Deriving the Theorem from First Principles', '14:10',
                  LessonStatus.done, Color(0xFF1B2A4A)),
              LessonItem('Solving Complex Trigonometric Problems', '12:05',
                  LessonStatus.next, Color(0xFF4A5560)),
            ],
          ),
          ModuleSection(
            title: 'Module 2: Advanced Theorems',
            subtitle: '4 lessons • 2h 18m total',
            doneLabel: '1 of 4 done',
            active: false,
            description:
                'Apply deeper geometric reasoning to harder problems, including proof-based thinking and multi-step calculations.',
            lessons: [
              LessonItem('Deriving the Theorem from First Principles', '14:10',
                  LessonStatus.done, Color(0xFF1B2A4A)),
              LessonItem('Solving Complex Trigonometric Problems', '12:05',
                  LessonStatus.locked, Color(0xFF4A5560)),
              LessonItem('Project: Geometry Applications', '18:40',
                  LessonStatus.locked, Color(0xFF9DB8E0)),
              LessonItem('Advanced Proofs', '15:30', LessonStatus.locked,
                  Color(0xFFC9A77C)),
            ],
          ),
        ],
        upcoming: [
          LiveSessionItem('Live Q&A: Advanced Python', 'Tomorrow, 10:00 AM',
              Color(0xFF1B2A4A)),
        ],
        completed: [
          LiveSessionItem('Geometry Basics: Circles and Angles',
              '45:00 • Recorded', Color(0xFF9DB8E0)),
          LiveSessionItem('Problem Solving Strategies', '30:15 • Recorded',
              Color(0xFFB8A58C)),
        ],
      );
}