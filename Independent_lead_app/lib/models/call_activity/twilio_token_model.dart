class TwilioTokenModel {
  final String token;
  final String identity;

  TwilioTokenModel({required this.token, required this.identity});

  factory TwilioTokenModel.fromJson(Map<String, dynamic> json) {
    return TwilioTokenModel(
      token: json['token']?.toString() ?? '',
      identity: json['identity']?.toString() ?? '',
    );
  }

  bool get isValid => token.isNotEmpty && identity.isNotEmpty;
}
