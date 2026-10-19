import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class LiveClassService {
  /// Later: websocket / chat API
  Future<List<ChatMessage>> getMessages() async => const [
        ChatMessage('Priya', 'Can you share the component file?', '11:14',
            Color(0xFFE08FA8)),
        ChatMessage('Dr. Sharma', "Sure, it's in Attachments", '11:15',
            Color(0xFF8B5CF6)),
        ChatMessage('Amit', 'This makes so much sense!', '11:16',
            Color(0xFF3B82F6)),
        ChatMessage('Neha', 'Could you show the spacing tokens again?', '11:17',
            Color(0xFFF59E0B)),
        ChatMessage('Rohan', 'Love this approach 🙌', '11:18',
            Color(0xFF10B981)),
      ];
}