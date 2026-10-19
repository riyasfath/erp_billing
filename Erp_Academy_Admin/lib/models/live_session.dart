class LiveSession {
  final String tag, title, module, facultyName, facultyRole, startedAgo;
  final int viewers;
  final bool isLive;
  const LiveSession({
    required this.tag,
    required this.title,
    required this.module,
    required this.facultyName,
    required this.facultyRole,
    required this.startedAgo,
    required this.viewers,
    required this.isLive,
  });
}