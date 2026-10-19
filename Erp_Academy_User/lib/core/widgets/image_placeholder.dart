import 'package:flutter/material.dart';

/// Colour box used in place of images. Later: replace with Image.asset / network.
class ImagePlaceholder extends StatelessWidget {
  final double? width, height;
  final Color color;
  final double radius;
  final IconData icon;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.color = const Color(0xFFB9C8E8),
    this.radius = 12,
    this.icon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          width: width,
          height: height,
          color: color,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white70),
        ),
      );
}