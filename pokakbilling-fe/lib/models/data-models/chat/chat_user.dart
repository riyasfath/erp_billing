class ChatUser {
  final int id;
  final String email;

  ChatUser({
    required this.id,
    required this.email,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
      };
}
