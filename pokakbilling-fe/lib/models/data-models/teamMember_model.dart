class TeamMemberModel {
  int tmId;
  String roleDisplay;
  String name;
  String emailId;
  String phone;
  String role;
  String date;

  TeamMemberModel({
    required this.tmId,
    required this.roleDisplay,
    required this.name,
    required this.emailId,
    required this.phone,
    required this.role,
    required this.date,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
        tmId: json['id'] ?? 0,
        roleDisplay: json['role_display'] ?? '',
        name: json['name'] ?? '',
        emailId: json['email'] ?? '',
        phone: json['phone_number'] ?? '',
        role: json['role'] ?? '',
        date: json['created_at'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': tmId,
      'role_display': roleDisplay,
      'name': name,
      'email': emailId,
      'phone_number': phone,
      'role': role,
      'created_at': date,
    };
  }
}
