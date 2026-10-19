// lib/models/data-models/internship/student_model.dart

class StudentModel {
  final int id;
  final String studentId;
  final String fullName;
  final int? center;
  final String centerName;
  final int? course;
  final String courseTitle;
  final String status;
  final String email;
  final String phoneNumber;

  StudentModel({
    required this.id,
    required this.studentId,
    required this.fullName,
    this.center,
    required this.centerName,
    this.course,
    required this.courseTitle,
    required this.status,
    required this.email,
    required this.phoneNumber,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? {};
    final user = profile['user'] as Map<String, dynamic>? ?? {};

    return StudentModel(
      id: (json['id'] is int)
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      studentId: json['student_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      center: json['center'] is int
          ? json['center'] as int
          : int.tryParse('${json['center'] ?? ''}'),
      centerName: json['center_name']?.toString() ?? '',
      course: json['course'] is int
          ? json['course'] as int
          : int.tryParse('${json['course'] ?? ''}'),
      courseTitle: json['course_title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phoneNumber: profile['phone_number']?.toString() ?? '',
    );
  }
}
