class ProfileModel {
  int profileId;
  String firstName;
  String lastName;
  String emailId;

  ProfileModel({
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.emailId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      profileId: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailId: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': profileId,
      'first_name': firstName,
      'last_name': lastName,
      'email': emailId,
    };
  }
}
