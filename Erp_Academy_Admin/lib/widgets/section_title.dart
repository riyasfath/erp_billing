import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const SectionTitle(this.title, {super.key, this.action});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 14, letterSpacing: .8, color: AppColors.text)),
          if (action != null)
            Text(action!,
                style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      );
}