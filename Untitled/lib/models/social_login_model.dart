/// Data sent to /api/accounts/auth/social/.
/// `provider` is 'google' (or 'apple' later per the API's own comment).
class SocialLoginModel {
  final String provider;
  final String token;

  SocialLoginModel({required this.provider, required this.token});

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'token': token,
      };
}