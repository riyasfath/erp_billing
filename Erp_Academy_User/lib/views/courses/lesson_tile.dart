import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/image_placeholder.dart';
import '../../models/lesson_item.dart';

class LessonTile extends StatelessWidget {
  final LessonItem lesson;
  const LessonTile(this.lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        ImagePlaceholder(
            width: 72,
            height: 62,
            radius: 8,
            color: lesson.color,
            icon: Icons.play_circle_outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 6),
            Text(lesson.duration,
                style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          ]),
        ),
        const SizedBox(width: 6),
        _status(),
        const SizedBox(width: 4),
        const Icon(Icons.more_horiz, color: AppColors.muted),
      ]),
    );
  }

  Widget _status() {
    switch (lesson.status) {
      case LessonStatus.done:
        return const Icon(Icons.verified, color: AppColors.green, size: 20);
      case LessonStatus.next:
        return _pill('Next');
      case LessonStatus.locked:
        return _pill('Locked');
    }
  }

  Widget _pill(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(20)),
        child: Text(t,
            style: const TextStyle(fontSize: 13, color: AppColors.muted)),
      );
}