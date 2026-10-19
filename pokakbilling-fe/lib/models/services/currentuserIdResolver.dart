import 'package:flutter/widgets.dart';
import 'package:pokakbilling/viewmodels/chat_users_viewmodel.dart';
import 'package:pokakbilling/viewmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';

/// Resolves the *chat* staff id for the logged-in email by matching it
/// against /chat/users/. Case-insensitive.
class CurrentUserIdResolver {
  static Future<int> resolve(BuildContext context) async {
    final loginEmail =
        context.read<LoginViewModel>().loggedInEmail?.trim().toLowerCase();

    if (loginEmail == null || loginEmail.isEmpty) {
      return 0;
    }

    final vm = context.read<ChatUsersViewModel>();

    // Try in-memory list first
    try {
      final user = vm.users.firstWhere(
        (u) => u.email.trim().toLowerCase() == loginEmail,
      );
      return user.id;
    } catch (_) {}

    // Fetch filtered from server
    await vm.fetch(search: loginEmail);
    try {
      final user = vm.users.firstWhere(
        (u) => u.email.trim().toLowerCase() == loginEmail,
      );
      return user.id;
    } catch (_) {
      return 0;
    }
  }
}
