// ─── chat_widgets.dart ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';

// ─── Shared Avatar widget ─────────────────────────────────────────────────────
class ChatAvatar extends StatelessWidget {
  final String initials;
  final String? imageUrl;
  final bool isOnline;
  final bool isGroup;
  final double size;

  const ChatAvatar({
    super.key,
    required this.initials,
    this.imageUrl,
    this.isOnline = false,
    this.isGroup = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: isGroup
                ? const LinearGradient(
                    colors: [AppColors.c1, AppColors.c2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : const LinearGradient(
                    colors: [AppColors.c1, AppColors.c3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cborder, width: 1.5),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback())
                : _fallback(),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navy, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback() => Center(
        child: isGroup
            ? const Icon(Icons.group_rounded, color: AppColors.white, size: 20)
            : Text(initials,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white)),
      );
}

// ─── Time formatter ───────────────────────────────────────────────────────────
String chatFormatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day)
      .difference(DateTime(dt.year, dt.month, dt.day))
      .inDays;
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  if (diff == 0) return '$h:$m';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
  return '${dt.day}/${dt.month}';
}
