class ChatUser {
  final int id;
  final String name;
  final String role;
  final String avatar; // initials
  final bool isOnline;

  const ChatUser({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.isOnline,
  });
}

class ChatMessage {
  final int id;
  final int senderId;
  final String text;
  final DateTime time;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    required this.isRead,
  });
}

class ChatConversation {
  final int id;
  final bool isGroup;
  String name;
  final String avatar;
  final List<int> memberIds;
  final List<ChatMessage> messages;
  final bool isOnline;

  ChatConversation({
    required this.id,
    required this.isGroup,
    required this.name,
    required this.avatar,
    required this.memberIds,
    required this.messages,
    this.isOnline = false,
  });

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  int get unreadCount =>
      messages.where((m) => !m.isRead && m.senderId != kMyId).length;
}

// ─── Current user ID ──────────────────────────────────────────────────────────
const int kMyId = 0;

// ─── Dummy users ──────────────────────────────────────────────────────────────
final List<ChatUser> kDummyUsers = [
  const ChatUser(
      id: 0, name: 'You', role: 'Admin', avatar: 'YO', isOnline: true),
  const ChatUser(
      id: 1,
      name: 'Arjun Kumar',
      role: 'Sales Manager',
      avatar: 'AK',
      isOnline: true),
  const ChatUser(
      id: 2,
      name: 'Priya Nair',
      role: 'Lead Executive',
      avatar: 'PN',
      isOnline: false),
  const ChatUser(
      id: 3,
      name: 'Rahul Menon',
      role: 'Field Agent',
      avatar: 'RM',
      isOnline: true),
  const ChatUser(
      id: 4,
      name: 'Sneha Iyer',
      role: 'Account Manager',
      avatar: 'SI',
      isOnline: false),
  const ChatUser(
      id: 5,
      name: 'Vikram Das',
      role: 'Support Staff',
      avatar: 'VD',
      isOnline: true),
  const ChatUser(
      id: 6,
      name: 'Meera Pillai',
      role: 'HR Executive',
      avatar: 'MP',
      isOnline: false),
  const ChatUser(
      id: 7,
      name: 'Kiran Raj',
      role: 'Billing Staff',
      avatar: 'KR',
      isOnline: true),
];

// ─── Dummy conversations ──────────────────────────────────────────────────────
List<ChatConversation> kDummyConversations = [
  ChatConversation(
    id: 101,
    isGroup: false,
    name: 'Arjun Kumar',
    avatar: 'AK',
    memberIds: [0, 1],
    isOnline: true,
    messages: [
      ChatMessage(
          id: 1,
          senderId: 1,
          text: 'Good morning! Did you check the Q2 leads report?',
          time: _dt(-2, 9, 0),
          isRead: true),
      ChatMessage(
          id: 2,
          senderId: 0,
          text: 'Yes, numbers look solid!',
          time: _dt(-2, 9, 5),
          isRead: true),
      ChatMessage(
          id: 3,
          senderId: 1,
          text: "Great. Let's target 20 closures this week.",
          time: _dt(-1, 10, 30),
          isRead: true),
      ChatMessage(
          id: 4,
          senderId: 0,
          text: "On it. I'll brief the team today.",
          time: _dt(-1, 10, 35),
          isRead: true),
      ChatMessage(
          id: 5,
          senderId: 1,
          text: 'Perfect 👍 Let me know if you need support.',
          time: _dt(0, 8, 45),
          isRead: false),
    ],
  ),
  ChatConversation(
    id: 102,
    isGroup: false,
    name: 'Priya Nair',
    avatar: 'PN',
    memberIds: [0, 2],
    isOnline: false,
    messages: [
      ChatMessage(
          id: 1,
          senderId: 2,
          text: 'Hey, can you share the client list for today?',
          time: _dt(-1, 14, 0),
          isRead: true),
      ChatMessage(
          id: 2,
          senderId: 0,
          text: 'Sending it now, check your email.',
          time: _dt(-1, 14, 10),
          isRead: true),
      ChatMessage(
          id: 3,
          senderId: 2,
          text: 'Got it, thanks!',
          time: _dt(-1, 14, 15),
          isRead: true),
      ChatMessage(
          id: 4,
          senderId: 2,
          text: 'Also the 3 PM follow-up call is confirmed.',
          time: _dt(0, 9, 0),
          isRead: false),
      ChatMessage(
          id: 5,
          senderId: 2,
          text: 'Please join on time 🙏',
          time: _dt(0, 9, 1),
          isRead: false),
    ],
  ),
  ChatConversation(
    id: 201,
    isGroup: true,
    name: 'Sales Team 🚀',
    avatar: 'ST',
    memberIds: [0, 1, 2, 3, 4],
    messages: [
      ChatMessage(
          id: 1,
          senderId: 3,
          text: "Team meeting at 11 AM today, don't miss it!",
          time: _dt(-1, 8, 0),
          isRead: true),
      ChatMessage(
          id: 2,
          senderId: 4,
          text: "Noted! I'll prepare the slides.",
          time: _dt(-1, 8, 10),
          isRead: true),
      ChatMessage(
          id: 3,
          senderId: 1,
          text: 'Rahul, bring the zone-wise data too.',
          time: _dt(-1, 8, 20),
          isRead: true),
      ChatMessage(
          id: 4,
          senderId: 0,
          text: "I'll be there. Should I present the Q2 deck?",
          time: _dt(-1, 8, 25),
          isRead: true),
      ChatMessage(
          id: 5,
          senderId: 1,
          text: 'Yes please! See everyone at 11 ✅',
          time: _dt(0, 7, 55),
          isRead: false),
    ],
  ),
  ChatConversation(
    id: 103,
    isGroup: false,
    name: 'Rahul Menon',
    avatar: 'RM',
    memberIds: [0, 3],
    isOnline: true,
    messages: [
      ChatMessage(
          id: 1,
          senderId: 3,
          text: "Boss, I've closed 3 leads today!",
          time: _dt(0, 11, 0),
          isRead: false),
      ChatMessage(
          id: 2,
          senderId: 3,
          text: 'Two more in pipeline for tomorrow.',
          time: _dt(0, 11, 1),
          isRead: false),
    ],
  ),
  ChatConversation(
    id: 202,
    isGroup: true,
    name: 'HR & Admin',
    avatar: 'HA',
    memberIds: [0, 6, 7],
    messages: [
      ChatMessage(
          id: 1,
          senderId: 6,
          text: 'Attendance sheet for this month is ready.',
          time: _dt(-3, 10, 0),
          isRead: true),
      ChatMessage(
          id: 2,
          senderId: 0,
          text: "Thanks Meera, I'll review and sign off.",
          time: _dt(-3, 10, 15),
          isRead: true),
      ChatMessage(
          id: 3,
          senderId: 7,
          text: 'Salary processing scheduled for 28th.',
          time: _dt(-1, 9, 30),
          isRead: true),
      ChatMessage(
          id: 4,
          senderId: 6,
          text: 'Reminder: submit leave applications by Friday.',
          time: _dt(0, 9, 0),
          isRead: false),
    ],
  ),
  ChatConversation(
    id: 104,
    isGroup: false,
    name: 'Sneha Iyer',
    avatar: 'SI',
    memberIds: [0, 4],
    isOnline: false,
    messages: [
      ChatMessage(
          id: 1,
          senderId: 0,
          text: 'Sneha, follow up with XYZ Corp today?',
          time: _dt(-2, 15, 0),
          isRead: true),
      ChatMessage(
          id: 2,
          senderId: 4,
          text: "Sure, I'll call them after lunch.",
          time: _dt(-2, 15, 5),
          isRead: true),
      ChatMessage(
          id: 3,
          senderId: 4,
          text: 'They confirmed the meeting for next Monday.',
          time: _dt(-1, 17, 0),
          isRead: true),
    ],
  ),
  ChatConversation(
    id: 105,
    isGroup: false,
    name: 'Vikram Das',
    avatar: 'VD',
    memberIds: [0, 5],
    isOnline: true,
    messages: [
      ChatMessage(
          id: 1,
          senderId: 5,
          text: 'Support ticket #4521 has been escalated.',
          time: _dt(0, 10, 0),
          isRead: false),
    ],
  ),
];

// ─── Helpers ──────────────────────────────────────────────────────────────────
DateTime _dt(int dayOffset, int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + dayOffset, hour, minute);
}

ChatUser userById(int id) => kDummyUsers.firstWhere(
      (u) => u.id == id,
      orElse: () => const ChatUser(
          id: -1, name: 'Unknown', role: '', avatar: '??', isOnline: false),
    );

String formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else if (diff.inDays == 1) {
    return 'Yesterday';
  } else if (diff.inDays < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  } else {
    return '${dt.day}/${dt.month}';
  }
}
