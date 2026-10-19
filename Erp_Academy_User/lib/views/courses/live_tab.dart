import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/image_placeholder.dart';
import '../../models/course_detail.dart';
import '../live/live_class_screen.dart';

class LiveTab extends StatelessWidget {
  final CourseDetail detail;
  const LiveTab({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Upcoming',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        ...detail.upcoming.map((s) => _card(
              s.title,
              s.subtitle,
              s.color,
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LiveClassScreen())),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Join',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            )),
        const SizedBox(height: 14),
        const Text('Completed Lives',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        ...detail.completed.map((s) => _card(s.title, s.subtitle, s.color,
            const Icon(Icons.more_horiz, color: AppColors.muted))),
      ]),
    );
  }

  Widget _card(String title, String sub, Color color, Widget trailing) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          ImagePlaceholder(
              width: 74,
              height: 74,
              radius: 8,
              color: color,
              icon: Icons.videocam_outlined),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text(sub,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.muted)),
            ]),
          ),
          const SizedBox(width: 8),
          trailing,
        ]),
      );
}