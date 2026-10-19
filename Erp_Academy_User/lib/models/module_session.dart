import 'lesson_item.dart';

class ModuleSection {
  final String title, subtitle, description, doneLabel;
  final bool active; // blue chip when true, grey when false
  final List<LessonItem> lessons;
  const ModuleSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.doneLabel,
    required this.active,
    required this.lessons,
  });
}