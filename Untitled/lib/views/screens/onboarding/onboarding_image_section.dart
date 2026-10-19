import 'package:flutter/material.dart';
import 'onboarding_data.dart';

class OnboardingImageSection extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingImageSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2563EB),
      child: Center(
        child: Image.asset(
          data.image, // ✅ FIXED (use image instead of icon)
          height: 200,
        ),
      ),
    );
  }
}
