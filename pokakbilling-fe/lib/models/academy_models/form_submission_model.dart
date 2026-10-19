// Field names in fromJson/toJson are my best guess at your API (snake_case).
// When you get the real response, only the keys in this file need to change.

const String kFormInternship = 'internship_form';
const String kFormFreeCourse = 'free_course_form';

const Map<String, String> kQualifications = {
  'SSLC': 'SSLC',
  'PLUS_TWO': 'Plus Two',
  'UG': 'Under Graduate (UG)',
  'PG': 'Post Graduate (PG)',
};

class SubmissionDocumentModel {
  final int id;
  final String documentType;
  final String fileName;
  final String fileUrl;

  const SubmissionDocumentModel({
    required this.id,
    required this.documentType,
    required this.fileName,
    this.fileUrl = '',
  });

  factory SubmissionDocumentModel.fromJson(Map<String, dynamic> json) {
    return SubmissionDocumentModel(
      id: int.tryParse('${json['id']}') ?? 0,
      documentType: json['document_type']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileUrl: json['file']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'document_type': documentType,
        'file_name': fileName,
        'file': fileUrl,
      };
}

class FormSubmissionModel {
  final int id;
  final String formType;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String secondaryPhone;
  final String dateOfBirth;
  final String gender;
  final String qualification;
  final String educationalCourseName;
  final String courseName;
  final int durationMonths;
  final String courseMode;
  final String counsellor;
  final String address;
  final String district;
  final String state;
  final String pincode;
  final String source;
  final String linkedin;
  final String github;
  final String portfolio;
  final String status; // pending | received | converted
  final String appliedDate; // yyyy-MM-dd
  final List<SubmissionDocumentModel> documents;

  const FormSubmissionModel({
    required this.id,
    required this.formType,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.secondaryPhone = '',
    this.dateOfBirth = '',
    this.gender = '',
    this.qualification = '',
    this.educationalCourseName = '',
    this.courseName = '',
    this.durationMonths = 0,
    this.courseMode = 'online',
    this.counsellor = '',
    this.address = '',
    this.district = '',
    this.state = '',
    this.pincode = '',
    this.source = '',
    this.linkedin = '',
    this.github = '',
    this.portfolio = '',
    this.status = 'pending',
    this.appliedDate = '',
    this.documents = const [],
  });

  String get fullName => '$firstName $lastName'.trim();
  String get code => '#APP-$id';
  bool get isConverted => status.toLowerCase() == 'converted';
  bool get isInternship => formType == kFormInternship;
  String get qualificationLabel =>
      kQualifications[qualification] ?? qualification;

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json) {
    final docs = (json['documents'] is List)
        ? (json['documents'] as List)
            .map((e) =>
                SubmissionDocumentModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <SubmissionDocumentModel>[];

    String s(String k) => json[k]?.toString() ?? '';

    return FormSubmissionModel(
      id: int.tryParse('${json['id']}') ?? 0,
      formType: s('form_type').isEmpty ? kFormInternship : s('form_type'),
      firstName: s('first_name'),
      lastName: s('last_name'),
      email: s('email'),
      phone: s('phone'),
      secondaryPhone: s('secondary_phone'),
      dateOfBirth: s('date_of_birth'),
      gender: s('gender'),
      qualification: s('qualification'),
      educationalCourseName: s('educational_course_name'),
      courseName: s('course_name'),
      durationMonths: int.tryParse('${json['duration']}') ?? 0,
      courseMode: s('course_mode').isEmpty ? 'online' : s('course_mode'),
      counsellor: s('counsellor_name'),
      address: s('address'),
      district: s('district'),
      state: s('state'),
      pincode: s('pincode'),
      source: s('source'),
      linkedin: s('linkedin'),
      github: s('github'),
      portfolio: s('portfolio'),
      status: s('status').isEmpty ? 'pending' : s('status'),
      appliedDate: s('applied_date'),
      documents: docs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'form_type': formType,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'secondary_phone': secondaryPhone,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'qualification': qualification,
        'educational_course_name': educationalCourseName,
        'course_name': courseName,
        'duration': durationMonths,
        'course_mode': courseMode,
        'counsellor_name': counsellor,
        'address': address,
        'district': district,
        'state': state,
        'pincode': pincode,
        'source': source,
        'linkedin': linkedin,
        'github': github,
        'portfolio': portfolio,
        'status': status,
        'applied_date': appliedDate,
        'documents': documents.map((d) => d.toJson()).toList(),
      };

  FormSubmissionModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? secondaryPhone,
    String? dateOfBirth,
    String? gender,
    String? qualification,
    String? educationalCourseName,
    String? courseName,
    int? durationMonths,
    String? courseMode,
    String? counsellor,
    String? address,
    String? district,
    String? state,
    String? pincode,
    String? source,
    String? linkedin,
    String? github,
    String? portfolio,
    String? status,
    List<SubmissionDocumentModel>? documents,
  }) {
    return FormSubmissionModel(
      id: id,
      formType: formType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      qualification: qualification ?? this.qualification,
      educationalCourseName:
          educationalCourseName ?? this.educationalCourseName,
      courseName: courseName ?? this.courseName,
      durationMonths: durationMonths ?? this.durationMonths,
      courseMode: courseMode ?? this.courseMode,
      counsellor: counsellor ?? this.counsellor,
      address: address ?? this.address,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      source: source ?? this.source,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      portfolio: portfolio ?? this.portfolio,
      status: status ?? this.status,
      appliedDate: appliedDate,
      documents: documents ?? this.documents,
    );
  }
}