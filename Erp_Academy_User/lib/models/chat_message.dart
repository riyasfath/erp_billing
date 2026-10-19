import 'package:flutter/material.dart';

class ChatMessage {
  final String name, text, time;
  final Color color; // avatar colour
  const ChatMessage(this.name, this.text, this.time, this.color);
}