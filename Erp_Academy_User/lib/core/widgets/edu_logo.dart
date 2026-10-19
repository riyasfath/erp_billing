import 'package:flutter/material.dart';

class EduLogo extends StatelessWidget {
  final double size; // font size of "EDU"
  const EduLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          _bar(size * .62, size * .26),
          SizedBox(height: size * .08),
          _bar(size * .62, size * .26),
        ]),
        SizedBox(width: size * .12),
        Text('EDU',
            style: TextStyle(
                color: Colors.white,
                fontSize: size,
                fontWeight: FontWeight.w900,
                height: 1)),
      ]),
      SizedBox(height: size * .18),
      Text('POKAK EDUCATION',
          style: TextStyle(
              color: Colors.white,
              fontSize: size * .26,
              letterSpacing: size * .13)),
    ]);
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(h / 2)),
      );
}