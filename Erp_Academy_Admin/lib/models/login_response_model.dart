
import 'package:erp_academy/models/app_user_model.dart';

/// Response of POST /accounts/admin/token/
/// {
///   "refresh": "...", "access": "...",
///   "user_id": 1, "email": "admin@gmail.com", "is_superuser": true
/// }
class LoginResponseModel {
  final String access;
  final String refresh;
  final int userId;
  final String email;
  final bool isSuperuser;

  const LoginResponseModel({
    required this.access,
    required this.refresh,
    required this.userId,
    required this.email,
    required this.isSuperuser,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final access = json['access'];
    final refresh = json['refresh'];
    if (access is! String || access.isEmpty || refresh is! String || refresh.isEmpty) {
      throw const FormatException('Login response is missing tokens');
    }
    return LoginResponseModel(
      access: access,
      refresh: refresh,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse('${json['user_id']}') ?? 0,
      email: (json['email'] ?? '').toString(),
      isSuperuser: json['is_superuser'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'access': access,
        'refresh': refresh,
        'user_id': userId,
        'email': email,
        'is_superuser': isSuperuser,
      };

  AppUser toAppUser() => AppUser(
        id: userId,
        email: email,
        role: isSuperuser ? UserRole.admin : UserRole.user,
      );
}