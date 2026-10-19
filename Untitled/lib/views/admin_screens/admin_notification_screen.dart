import 'package:ecommerce_app/admin/admin_model/admin_notifcation_model.dart';
import 'package:ecommerce_app/viewmodel/admin_notification_viewmodel.dart';
import 'package:ecommerce_app/views/admin_screens/admin_employee_screen.dart';
import 'package:ecommerce_app/views/admin_screens/admin_order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admin_returns_screen.dart';
import 'admin_support_ticket_detail.dart';

const Color _accent = Color(0xFF6366F1);
const Color _textDark = Color(0xFF0F172A);
const Color _textGrey = Color(0xFF64748B);
const Color _bg = Color(0xFFF5F6FA);

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNotificationViewModel>().fetchNotifications();
    });
  }

  Future<void> _markAllRead(AdminNotificationViewModel viewModel) async {
    final success = await viewModel.markAllAsRead();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(success ? 'All caught up!' : 'Could not mark all as read', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  void _handleTap(AdminNotificationViewModel viewModel, AdminNotificationModel n) {
    viewModel.markAsRead(n.id);
    final id = n.linkedId;
    switch (n.notificationType) {
      case 'order':
        if (id != null) Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderDetailScreen(orderId: id)));
        break;
      case 'return':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReturnsScreen()));
        break;
      case 'support':
        if (id != null) Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSupportTicketDetailScreen(ticketId: id)));
        break;
      case 'employee':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEmployeesScreen()));
        break;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'order':
        return _accent;
      case 'return':
        return const Color(0xFFF59E0B);
      case 'support':
        return const Color(0xFF06B6D4);
      case 'employee':
        return const Color(0xFF8B5CF6);
      default:
        return _textGrey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'return':
        return Icons.assignment_return_rounded;
      case 'support':
        return Icons.support_agent_rounded;
      case 'employee':
        return Icons.badge_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminNotificationViewModel>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _textDark,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (viewModel.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: viewModel.isMarkingAllRead ? null : () => _markAllRead(viewModel),
              child: viewModel.isMarkingAllRead
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _accent))
                  : const Text('Mark all read', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
        ],
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(AdminNotificationViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (viewModel.error != null && viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewModel.error!, style: const TextStyle(color: _textGrey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => viewModel.fetchNotifications(),
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: _accent.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded, size: 40, color: _accent),
            ),
            const SizedBox(height: 16),
            const Text("You're all caught up", style: TextStyle(color: _textGrey, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      onRefresh: () => viewModel.fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: viewModel.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _tile(viewModel, viewModel.notifications[index]),
      ),
    );
  }

  Widget _tile(AdminNotificationViewModel viewModel, AdminNotificationModel n) {
    final color = _typeColor(n.notificationType);
    final bool marking = viewModel.isMarkingRead(n.id);
    return Material(
      color: n.isRead ? Colors.white : _accent.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: marking ? null : () => _handleTap(viewModel, n),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: n.isRead ? const Color(0xFFE2E8F0) : _accent.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(_typeIcon(n.notificationType), color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800, color: _textDark)),
                        ),
                        if (!n.isRead) ...[
                          const SizedBox(width: 6),
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: _textGrey, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(n.createdAtFmt, style: const TextStyle(fontSize: 10, color: _textGrey)),
                  ],
                ),
              ),
              if (marking)
                const Padding(padding: EdgeInsets.only(left: 8), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))),
            ],
          ),
        ),
      ),
    );
  }
}