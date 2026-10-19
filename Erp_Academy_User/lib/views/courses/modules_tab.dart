import 'package:erp_user/models/module_session.dart';
import 'package:erp_user/views/courses/lesson_tile.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/course_detail.dart';

class ModulesTab extends StatelessWidget {
  final CourseDetail detail;
  const ModulesTab({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Course overview card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.grayCard,
              borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Course overview',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              _pill('${detail.overviewPercent}% complete', true),
            ]),
            const SizedBox(height: 12),
            Text(detail.overview,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.muted, height: 1.45)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Lessons',
                        style:
                            TextStyle(fontSize: 14, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text(detail.lessonsCount,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        ...detail.modules.map(_module),
      ]),
    );
  }

  Widget _module(ModuleSection m) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(m.subtitle,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
          ),
          _pill(m.doneLabel, m.active),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.grayCard,
              borderRadius: BorderRadius.circular(14)),
          child: Text(m.description,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF374151), height: 1.45)),
        ),
        const SizedBox(height: 12),
        ...m.lessons.map((l) => LessonTile(l)),
        const SizedBox(height: 14),
      ]);

  Widget _pill(String t, bool active) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: active ? AppColors.chip : AppColors.grayCard,
            borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: TextStyle(
                fontSize: 13,
                color: active ? AppColors.chipText : AppColors.muted)),
      );
}