import 'package:flutter/material.dart';

void showComingSoon(BuildContext context, [String feature = 'This feature']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('$feature is coming soon')),
      ]),
      behavior: SnackBarBehavior.floating,
    ));
}