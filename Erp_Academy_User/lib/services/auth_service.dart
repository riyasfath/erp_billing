import '../models/app_user.dart';

class AuthService {
  /// Hardcoded. Later: call login API here.
  Future<AppUser?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (username.trim().isEmpty || password.isEmpty) return null;

    if (username.trim() == 'Admin@learn.edu') {
      return const AppUser('Administrator', UserRole.admin);
    }
    return const AppUser('Rahul', UserRole.user);
  }
}