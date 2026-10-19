import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const DotsIndicator({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: const EdgeInsets.all(4),
          width: current == index ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: current == index ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
