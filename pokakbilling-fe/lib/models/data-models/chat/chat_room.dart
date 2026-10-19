// class ChatRoom {
//   final int id;
//   final String type;
//   final List<int> participants;

//   ChatRoom({
//     required this.id,
//     required this.type,
//     required this.participants,
//   });

//   factory ChatRoom.fromJson(Map<String, dynamic> json) {
//     final rawParticipants = json['participants'];

//     List<int> parsedParticipants = [];

//     if (rawParticipants is List) {
//       parsedParticipants = rawParticipants
//           .map((e) {
//             if (e is int) return e;
//             if (e is String) return int.tryParse(e) ?? 0;
//             return 0;
//           })
//           .where((id) => id != 0)
//           .toList();
//     }

//     return ChatRoom(
//       id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
//       type: json['type']?.toString() ?? 'one_to_one',
//       participants: parsedParticipants,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "type": type,
//       "participants": participants,
//     };
//   }
// }
class ChatRoom {
  final int id;
  final String type;
  final List<int> participants;

  ChatRoom({
    required this.id,
    required this.type,
    required this.participants,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    List<int> parsedParticipants = [];
    final raw = json['participants'];

    if (raw is List) {
      parsedParticipants = raw
          .map((e) {
            if (e is int) return e;
            if (e is String) return int.tryParse(e) ?? 0;
            if (e is Map && e['id'] != null) {
              final v = e['id'];
              return v is int ? v : int.tryParse('$v') ?? 0;
            }
            return 0;
          })
          .where((id) => id != 0)
          .toList();
    }

    return ChatRoom(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? 'one_to_one',
      participants: parsedParticipants,
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'type': type, 'participants': participants};
}
