enum UserRole { admin, user }

/// The logged-in user the rest of the app works with.
class AppUser {
  final int id;
  final String email;
  final UserRole role;

  const AppUser({required this.id, required this.email, required this.role});

  /// Display name derived from email until the API provides a real name.
  String get name => email.split('@').first;

  bool get isAdmin => role == UserRole.admin;
}