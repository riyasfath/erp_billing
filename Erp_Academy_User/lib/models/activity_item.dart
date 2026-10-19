import 'package:flutter/material.dart';

class ActivityItem {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  const ActivityItem(this.title, this.subtitle, this.time, this.icon, this.color);
}