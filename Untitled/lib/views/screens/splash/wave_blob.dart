import 'package:flutter/material.dart';

class WaveBlob extends StatelessWidget {
  final double size;

  const WaveBlob({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        shape: BoxShape.circle,
      ),
    );
  }
}
