import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HeaderActions extends StatelessWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context) => Row(children: const [
        Badge(
          label: Text('3'),
          backgroundColor: AppColors.primary,
          child: Icon(Icons.notifications_none),
        ),
        SizedBox(width: 16),
        CircleAvatar(
          radius: 21,
          backgroundColor: AppColors.lightBlue,
          child: Icon(Icons.person, color: AppColors.primary),
        ),
      ]);
}