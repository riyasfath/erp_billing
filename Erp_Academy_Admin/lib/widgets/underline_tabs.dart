import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class UnderlineTabs extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChanged;
  const UnderlineTabs(
      {super.key,
      required this.tabs,
      required this.index,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(tabs.length, (i) {
          final sel = i == index;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(tabs[i],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          color: sel ? AppColors.text : AppColors.muted)),
                ),
                Container(
                    height: sel ? 1.5 : 1,
                    color: sel ? AppColors.text : AppColors.border),
              ]),
            ),
          );
        }),
      );
}