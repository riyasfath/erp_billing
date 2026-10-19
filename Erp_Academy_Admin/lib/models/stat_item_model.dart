import 'package:flutter/material.dart';

class StatItem {
  final String label, value, sub;
  final IconData icon;
  final Color bg, accent;
  const StatItem(
      this.label, this.value, this.sub, this.icon, this.bg, this.accent);
}