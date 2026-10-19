import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:ecommerce_app/models/notification_model.dart';
import 'package:ecommerce_app/viewmodel/notification_viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  Future<void> _markAllRead(NotificationViewModel viewModel) async {
    final success = await viewModel.markAllAsRead();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? const Color(0xFF16A34A) : AppColors.badgeRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 1500),
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              success ? 'All caught up!' : 'Could not mark all as read',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(viewModel),
            Expanded(child: _buildBody(viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NotificationViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
          if (viewModel.notifications.any((n) => !n.isRead))
            GestureDetector(
              onTap: viewModel.isMarkingAllRead ? null : () => _markAllRead(viewModel),
              child: viewModel.isMarkingAllRead
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                    )
                  : const Text(
                      'Mark all read',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(NotificationViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null && viewModel.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => viewModel.fetchNotifications(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, size: 44, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 20),
              const Text(
                "You're all caught up",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                "No notifications yet — we'll let you know when\nsomething needs your attention",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: viewModel.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _notificationTile(viewModel, viewModel.notifications[index]),
      ),
    );
  }

  Widget _notificationTile(NotificationViewModel viewModel, NotificationModel notification) {
    final bool marking = viewModel.isMarkingRead(notification.id);
    final _TypeStyle typeStyle = _styleForType(notification.type);

    return GestureDetector(
      onTap: marking ? null : () => viewModel.markAsRead(notification.id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? AppColors.borderGrey : AppColors.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: typeStyle.color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(typeStyle.icon, size: 20, color: typeStyle.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                        ),
                      ],
                    ],
                  ),
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
                    ),
                  ],
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt!),
                      style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  ],
                ],
              ),
            ),
            if (marking)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
      ),
    );
  }

  _TypeStyle _styleForType(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return _TypeStyle(Icons.local_shipping_outlined, AppColors.primaryBlue);
      case 'promo':
      case 'promotion':
      case 'offer':
        return _TypeStyle(Icons.local_offer_outlined, const Color(0xFFF59E0B));
      case 'system':
        return _TypeStyle(Icons.info_outline, AppColors.textGrey);
      default:
        return _TypeStyle(Icons.notifications_none_rounded, AppColors.primaryBlue);
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()} week${diff.inDays >= 14 ? 's' : ''} ago';
    if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours >= 1) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }
}

class _TypeStyle {
  final IconData icon;
  final Color color;
  _TypeStyle(this.icon, this.color);
}