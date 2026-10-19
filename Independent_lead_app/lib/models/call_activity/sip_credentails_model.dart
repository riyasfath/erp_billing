/// Credentials your backend hands the app so it can register with your
/// SIP server / telephony provider's SIP trunk. Fetch this once (e.g. on
/// login or right before the first call) — unlike Twilio's short-lived
/// access tokens, these are typically static per agent extension, so you
/// can cache them and only re-fetch if registration ever fails.
class SipCredentialsModel {
  final String wsUrl; // e.g. wss://yourpbx.example.com:8089/ws
  final String sipUri; // e.g. sip:1001@yourpbx.example.com
  final String authUser; // e.g. 1001
  final String password;
  final String displayName;

  SipCredentialsModel({
    required this.wsUrl,
    required this.sipUri,
    required this.authUser,
    required this.password,
    required this.displayName,
  });

  factory SipCredentialsModel.fromJson(Map<String, dynamic> json) {
    return SipCredentialsModel(
      wsUrl: json['ws_url'] as String,
      sipUri: json['sip_uri'] as String,
      authUser: json['auth_user'] as String,
      password: json['password'] as String,
      displayName: json['display_name'] as String? ?? 'Agent',
    );
  }
}
