enum UserRole { admin, user }

class AppUser {
  final String name;
  final UserRole role;
  const AppUser(this.name, this.role);
}