class ChatUser {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String? department;
  final String? employeeId;

  const ChatUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    this.department,
    this.employeeId,
  });

  String get fullName {
    final n = '${firstName.trim()} ${lastName.trim()}'.trim();
    return n.isEmpty ? username : n;
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty && firstName.length >= 2) {
      return firstName.substring(0, 2).toUpperCase();
    }
    if (username.length >= 2) return username.substring(0, 2).toUpperCase();
    return username.toUpperCase();
  }

  factory ChatUser.fromJson(Map<String, dynamic> j) => ChatUser(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
        username: j['username']?.toString() ?? '',
        firstName: j['first_name']?.toString() ?? '',
        lastName: j['last_name']?.toString() ?? '',
        profilePicture: j['profile_picture']?.toString(),
        department: j['department']?.toString(),
        employeeId: j['employee_id']?.toString(),
      );
}

// ─── ChatParticipant ──────────────────────────────────────────────────────────
class ChatParticipant {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  const ChatParticipant({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  String get fullName {
    final n = '${firstName.trim()} ${lastName.trim()}'.trim();
    return n.isEmpty ? username : n;
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty && firstName.length >= 2) {
      return firstName.substring(0, 2).toUpperCase();
    }
    if (username.length >= 2) return username.substring(0, 2).toUpperCase();
    return username.toUpperCase();
  }

  factory ChatParticipant.fromJson(Map<String, dynamic> j) => ChatParticipant(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
        username: j['username']?.toString() ?? '',
        firstName: j['first_name']?.toString() ?? '',
        lastName: j['last_name']?.toString() ?? '',
        profilePicture: j['profile_picture']?.toString(),
      );
}

// ─── ChatMessageModel ─────────────────────────────────────────────────────────
class ChatMessageModel {
  final int id;
  final ChatParticipant sender;
  final String text;
  final String? attachment;
  final bool isRead;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.attachment,
    required this.isRead,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> j) {
    final senderRaw = j['sender'];
    final ChatParticipant sender;
    if (senderRaw is Map<String, dynamic>) {
      sender = ChatParticipant.fromJson(senderRaw);
    } else {
      final senderId =
          senderRaw is int ? senderRaw : int.tryParse('$senderRaw') ?? 0;
      sender = ChatParticipant(
        id: senderId,
        username: '',
        firstName: '',
        lastName: '',
      );
    }

    DateTime parsedTime;
    final rawTs = j['timestamp']?.toString() ??
        j['created_at']?.toString() ??
        j['sent_at']?.toString() ??
        '';
    if (rawTs.isNotEmpty) {
      final parsed = DateTime.tryParse(rawTs);
      if (parsed != null) {
        parsedTime = parsed.toLocal();
      } else {
        parsedTime = DateTime.now();
      }
    } else {
      parsedTime = DateTime.now();
    }

    return ChatMessageModel(
      id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
      sender: sender,
      text: (j['text'] ?? j['content'] ?? j['message'] ?? '').toString(),
      attachment: j['attachment']?.toString(),
      isRead: j['is_read'] == true,
      timestamp: parsedTime,
    );
  }
}

// ─── ChatConversation ─────────────────────────────────────────────────────────
class ChatConversation {
  final int id;
  final String rawName;
  final String? image;
  final bool isGroup;
  final bool isPinned;
  final bool isMuted;
  int unreadCount;
  final ChatMessageModel? lastMessage;
  final List<ChatParticipant> participants;

  /// The logged-in user's id — set this once after login.
  /// Also store username as fallback for cases where id matching fails.
  static int? currentUserId;
  static String? currentUsername;

  ChatConversation({
    required this.id,
    required String name,
    this.image,
    required this.isGroup,
    required this.isPinned,
    required this.isMuted,
    required this.unreadCount,
    this.lastMessage,
    required this.participants,
  }) : rawName = name;

  /// For DMs: always returns the OTHER person's name, never yours.
  /// For groups: returns the group name.
  String get name {
    if (isGroup) return rawName;

    // ── Find the other participant, not the logged-in user ──────────────────
    // Strategy 1: match by id (most reliable)
    final myId = currentUserId;
    if (myId != null && myId != -1 && participants.length > 1) {
      final other = participants.firstWhere(
        (p) => p.id != myId,
        orElse: () => participants.first,
      );
      final n = other.fullName;
      if (n.isNotEmpty) return n;
    }

    // Strategy 2: match by username (fallback when id not yet loaded)
    final myUsername = currentUsername?.toLowerCase().trim();
    if (myUsername != null &&
        myUsername.isNotEmpty &&
        participants.length > 1) {
      final other = participants.firstWhere(
        (p) => p.username.toLowerCase().trim() != myUsername,
        orElse: () => participants.first,
      );
      final n = other.fullName;
      if (n.isNotEmpty) return n;
    }

    // Strategy 3: single participant (the other person, API excluded you)
    if (participants.length == 1) {
      final n = participants.first.fullName;
      if (n.isNotEmpty) return n;
    }

    // Strategy 4: rawName if it looks meaningful
    if (rawName.isNotEmpty &&
        rawName.toLowerCase() != 'chat' &&
        rawName.toLowerCase() != 'direct message') {
      return rawName;
    }

    return 'Unknown';
  }

  /// Initials for the avatar — same logic as name, picks the other person.
  String get avatarInitials {
    if (isGroup) {
      if (rawName.length >= 2) return rawName.substring(0, 2).toUpperCase();
      return rawName.toUpperCase();
    }

    final myId = currentUserId;
    if (myId != null && myId != -1 && participants.length > 1) {
      final other = participants.firstWhere(
        (p) => p.id != myId,
        orElse: () => participants.first,
      );
      return other.initials;
    }

    final myUsername = currentUsername?.toLowerCase().trim();
    if (myUsername != null &&
        myUsername.isNotEmpty &&
        participants.length > 1) {
      final other = participants.firstWhere(
        (p) => p.username.toLowerCase().trim() != myUsername,
        orElse: () => participants.first,
      );
      return other.initials;
    }

    if (participants.length == 1) return participants.first.initials;
    if (participants.isNotEmpty) return participants.first.initials;
    return '??';
  }

  /// The other participant object (used for avatar image in DMs).
  ChatParticipant? get otherParticipant {
    if (isGroup || participants.isEmpty) return null;

    final myId = currentUserId;
    if (myId != null && myId != -1 && participants.length > 1) {
      return participants.firstWhere(
        (p) => p.id != myId,
        orElse: () => participants.first,
      );
    }

    final myUsername = currentUsername?.toLowerCase().trim();
    if (myUsername != null &&
        myUsername.isNotEmpty &&
        participants.length > 1) {
      return participants.firstWhere(
        (p) => p.username.toLowerCase().trim() != myUsername,
        orElse: () => participants.first,
      );
    }

    return participants.length == 1 ? participants.first : participants.first;
  }

  factory ChatConversation.fromJson(Map<String, dynamic> j) {
    final rawParticipants = j['participants'];
    final List<ChatParticipant> participants = rawParticipants is List
        ? rawParticipants
            .whereType<Map<String, dynamic>>()
            .map(ChatParticipant.fromJson)
            .toList()
        : [];

    ChatMessageModel? lastMsg;
    if (j['last_message'] is Map<String, dynamic>) {
      try {
        lastMsg = ChatMessageModel.fromJson(
            j['last_message'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return ChatConversation(
      id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
      name: j['name']?.toString() ?? 'Chat',
      image: j['image']?.toString(),
      isGroup: j['is_group'] == true,
      isPinned: j['is_pinned'] == true,
      isMuted: j['is_muted'] == true,
      unreadCount: j['unread_count'] is int
          ? j['unread_count']
          : int.tryParse('${j['unread_count']}') ?? 0,
      lastMessage: lastMsg,
      participants: participants,
    );
  }
}
