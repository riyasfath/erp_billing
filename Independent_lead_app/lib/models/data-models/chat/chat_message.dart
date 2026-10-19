// class ChatMessage {
//   final int id;
//   final int chatId;
//   final int senderId;
//   final String content;
//   final DateTime createdAt;

//   ChatMessage({
//     required this.id,
//     required this.chatId,
//     required this.senderId,
//     required this.content,
//     required this.createdAt,
//   });

//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
//       chatId: json['chat'] is int
//           ? json['chat']
//           : int.tryParse('${json['chat']}') ?? 0,
//       senderId: json['sender'] is int
//           ? json['sender']
//           : int.tryParse('${json['sender']}') ?? 0,
//       content: (json['content'] ?? json['message'] ?? '').toString(),
//       createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
//           DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'chat': chatId,
//         'content': content,
//       };
// }
class ChatMessage {
  final int id;
  final int chatId;
  final int senderId;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
        chatId: json['chat'] is int
            ? json['chat']
            : int.tryParse('${json['chat']}') ?? 0,
        senderId: json['sender'] is int
            ? json['sender']
            : int.tryParse('${json['sender']}') ?? 0,
        content: (json['content'] ?? json['message'] ?? '').toString(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {'chat': chatId, 'content': content};
}
