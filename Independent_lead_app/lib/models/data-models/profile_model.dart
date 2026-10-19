class ProfileModel {
  int profileId;
  String firstName;
  String lastName;
  String emailId;
  String phoneNumber;
  String gender;
  String dob;
  String address;
  String profilePicture;

  ProfileModel({
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.emailId,
    required this.phoneNumber,
    required this.gender,
    required this.dob,
    required this.address,
    required this.profilePicture,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // nested profile object
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return ProfileModel(
      profileId: profile['id'] ?? json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailId: json['email'] ?? '',
      phoneNumber: profile['phone_number'] ?? '',
      gender: profile['gender'] ?? '',
      dob: profile['dob'] ?? '',
      address: profile['address'] ?? '',
      profilePicture: profile['profile_picture'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': profileId,
      'first_name': firstName,
      'last_name': lastName,
      'email': emailId,
      'profile': {
        'id': profileId,
        'phone_number': phoneNumber,
        'gender': gender,
        'dob': dob,
        'address': address,
        'profile_picture': profilePicture,
      },
    };
  }
}
