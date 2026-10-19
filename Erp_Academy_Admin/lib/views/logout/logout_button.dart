import 'package:erp_academy/core/app_colors.dart';
import 'package:erp_academy/viewmodels/auth_viewmodel.dart';
import 'package:erp_academy/viewmodels/nav_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, this.showLabel = false});

  final bool showLabel;

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout',
                  style: TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    context.read<NavViewModel>().setIndex(0); // next login opens on Home tab
    await context.read<AuthViewModel>().logout();
  }

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return ListTile(
        leading: const Icon(Icons.logout, color: AppColors.red),
        title: const Text('Logout', style: TextStyle(color: AppColors.red)),
        onTap: () => _confirm(context),
      );
    }
    return IconButton(
      tooltip: 'Logout',
      icon: const Icon(Icons.logout),
      onPressed: () => _confirm(context),
    );
  }
}