import 'package:flutter/material.dart';

class OnboardingModel {
  final String title;
  final String subtitle;
  final String image;

  OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}

final List<OnboardingModel> onboardingList = [
  OnboardingModel(
    title: "Start Journey\nWith Nike",
    subtitle: "Smart, Gorgeous & Fashionable\nCollection",
    image: "assets/images/shoe1.png",
  ),
  OnboardingModel(
    title: "Follow Latest\nStyle Shoes",
    subtitle: "There Are Many Beautiful And\nAttractive Plants To Your Room",
    image: "assets/images/shoe2.png",
  ),
  OnboardingModel(
    title: "Summer Shoes\nNike 2022",
    subtitle: "Amet Minim Lit Nodeseru Saku\nNandu sit Alique Dolor",
    image: "assets/images/shoe3.png",
  ),
];
