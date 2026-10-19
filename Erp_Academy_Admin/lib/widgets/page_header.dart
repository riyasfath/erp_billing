import 'package:erp_academy/widgets/header_action.dart';
import 'package:flutter/material.dart';


class PageHeader extends StatelessWidget {
  final String title;
  const PageHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700))),
        const HeaderActions(),
      ]);
}