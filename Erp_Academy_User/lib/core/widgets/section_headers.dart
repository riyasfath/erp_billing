import 'package:flutter/material.dart';
import '../app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Row(children: [
            Text('See All',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
            Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
          ]),
        ],
      );
}