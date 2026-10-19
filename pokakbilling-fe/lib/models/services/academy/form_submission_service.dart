// // import 'package:pokakbilling/core/api/api_constants.dart';
// // import 'package:pokakbilling/core/api/dio_client.dart';

// import 'package:pokakbilling/models/academy_models/form_submission_model.dart';

// String _daysAgo(int n) {
//   final d = DateTime.now().subtract(Duration(days: n));
//   return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
// }

// class FormSubmissionService {
//   // ── Dropdown sample data (replace with course / counsellor / center APIs) ──
//   static const List<String> counsellors = [
//     'Abhal Benny',
//     'Alan mathew',
//     'Shaheem Mahmood',
//     'John Peter',
//     'anaswara dev',
//     'sales A',
//   ];
//   static const List<String> courses = [
//     'javaa',
//     'digital marketing',
//     'MEAN Stack test',
//     'data analytics',
//     'Game Development',
//     'python full stack',
//     'testing',
//     'btech',
//     'BSC CS',
//   ];
//   static const List<String> centers = [
//     'Kochi (Head office)',
//     'Calicut',
//     'Trivandrum',
//   ];
//   static const List<String> sources = [
//     'Social Media',
//     'Website',
//     'Referral',
//     'Walk-in',
//     'Call',
//   ];

//   // ── In-memory "database" ───────────────────────────────────────────────────
//   static final List<FormSubmissionModel> _db = [
//     FormSubmissionModel(
//       id: 45, formType: kFormInternship, firstName: 'Jomol', lastName: 'K',
//       email: 'abcd@gmail.com', phone: '9089464625', dateOfBirth: '2000-06-09',
//       gender: 'Female', qualification: 'UG', courseName: 'javaa',
//       durationMonths: 6, courseMode: 'online', counsellor: 'Abhal Benny',
//       address: 'drtyhbnjkl, lmkkj', district: 'Kollam', state: 'Kerala',
//       pincode: '629168', source: 'Social Media',
//       linkedin: 'https://www.linkedin.com/in/jomol',
//       github: 'https://github.com/john-doe', portfolio: 'https://johndoe.dev',
//       status: 'pending', appliedDate: _daysAgo(2),
//     ),
//     FormSubmissionModel(
//       id: 44, formType: kFormInternship, firstName: 'Fidha', lastName: 'Sudheer',
//       email: 'fidhaah123@gmail.com', phone: '9876543210', gender: 'Female',
//       qualification: 'UG', courseName: 'digital marketing', durationMonths: 3,
//       counsellor: 'Abhal Benny', district: 'Kozhikode', state: 'Kerala',
//       pincode: '673001', source: 'Website', status: 'pending',
//       appliedDate: _daysAgo(4),
//     ),
//     FormSubmissionModel(
//       id: 43, formType: kFormInternship, firstName: 'Muhammed', lastName: 'ak',
//       email: 'aksiyad6369@gmail.com', phone: '+919645261264', gender: 'Male',
//       qualification: 'PLUS_TWO', courseName: 'testing', durationMonths: 2,
//       courseMode: 'offline', counsellor: 'Alan mathew', district: 'Malappuram',
//       state: 'Kerala', pincode: '676505', source: 'Referral',
//       status: 'received', appliedDate: _daysAgo(5),
//     ),
//     FormSubmissionModel(
//       id: 42, formType: kFormInternship, firstName: 'Fidha', lastName: 'Sudheer',
//       email: 'fidhasudheerconnect@gmail.com', phone: '4321567890',
//       gender: 'Female', qualification: 'UG', courseName: 'MEAN Stack test',
//       durationMonths: 6, counsellor: 'Shaheem Mahmood', district: 'Kannur',
//       state: 'Kerala', pincode: '670001', source: 'Social Media',
//       status: 'pending', appliedDate: _daysAgo(9),
//     ),
//     FormSubmissionModel(
//       id: 41, formType: kFormInternship, firstName: 'aisrya', lastName: 'III',
//       email: 'aiswaryasurendran97@gmail.com', phone: '+919645261264',
//       gender: 'Female', qualification: 'SSLC', courseName: 'data analytics',
//       durationMonths: 4, courseMode: 'recorded', counsellor: 'anaswara dev',
//       district: 'Thrissur', state: 'Kerala', pincode: '680001',
//       source: 'Call', status: 'converted', appliedDate: _daysAgo(14),
//     ),
//     FormSubmissionModel(
//       id: 40, formType: kFormInternship, firstName: 'Jinta', lastName: 'Joji',
//       email: 'jinta@gmail.com', phone: '2345642123', gender: 'Female',
//       qualification: 'PG', courseName: 'testing', durationMonths: 3,
//       counsellor: 'anaswara dev', district: 'Ernakulam', state: 'Kerala',
//       pincode: '682001', source: 'Website', status: 'pending',
//       appliedDate: _daysAgo(21),
//     ),
//     FormSubmissionModel(
//       id: 39, formType: kFormInternship, firstName: 'Amal', lastName: 'siju',
//       email: 'ABCDABCD@gmail.com', phone: '9678456423', gender: 'Male',
//       qualification: 'PLUS_TWO', courseName: 'Game Development',
//       durationMonths: 6, counsellor: 'John Peter', district: 'Kottayam',
//       state: 'Kerala', pincode: '686001', source: 'Social Media',
//       status: 'converted', appliedDate: _daysAgo(33),
//     ),
//     FormSubmissionModel(
//       id: 11, formType: kFormFreeCourse, firstName: 'test', lastName: 'Pr',
//       email: 'revathypr75@gmail.com', phone: '+919188030718', gender: 'Male',
//       qualification: 'PLUS_TWO', educationalCourseName: 'btech',
//       courseName: 'btech', durationMonths: 5, courseMode: 'offline',
//       district: 'Palakkad', state: 'Kerala', pincode: '678001',
//       source: 'Website', status: 'pending', appliedDate: _daysAgo(3),
//     ),
//     FormSubmissionModel(
//       id: 10, formType: kFormFreeCourse, firstName: 'mufi', lastName: 'mufi',
//       email: 'mufi@gmail.com', phone: '+919645261264', gender: 'Male',
//       qualification: 'PLUS_TWO', educationalCourseName: 'BSC CS',
//       courseName: 'BSC CS', durationMonths: 3, district: 'Kozhikode',
//       state: 'Kerala', pincode: '673001', source: 'Referral',
//       status: 'received', appliedDate: _daysAgo(6),
//     ),
//   ];

//   static Future<void> _latency() =>
//       Future.delayed(const Duration(milliseconds: 450));

//   // API: GET ApiConstants.formSubmissions  (return list of FormSubmissionModel.fromJson)
//   static Future<List<FormSubmissionModel>> fetchSubmissions() async {
//     await _latency();
//     return List<FormSubmissionModel>.from(_db);
//   }

//   // API: GET ApiConstants.formSubmissionById(id)
//   static Future<FormSubmissionModel?> fetchById(int id) async {
//     await _latency();
//     for (final s in _db) {
//       if (s.id == id) return s;
//     }
//     return null;
//   }

//   // API: PUT/PATCH ApiConstants.formSubmissionById(id), data: updated.toJson()
//   // Returns null on success, error message otherwise (same style as LeadServices).
//   static Future<String?> updateSubmission(FormSubmissionModel updated) async {
//     await _latency();
//     final i = _db.indexWhere((s) => s.id == updated.id);
//     if (i == -1) return 'Application not found.';
//     _db[i] = updated;
//     return null;
//   }

//   // API: DELETE ApiConstants.formSubmissionById(id)
//   static Future<String?> deleteSubmission(int id) async {
//     await _latency();
//     _db.removeWhere((s) => s.id == id);
//     return null;
//   }

//   // API: POST ApiConstants.convertToStudent(id), data: {...}
//   static Future<String?> convertToStudent({
//     required int id,
//     required String email,
//     required String status,
//     required String password,
//     required String center,
//     required String startDate,
//     String? slotAmount,
//   }) async {
//     await _latency();
//     final i = _db.indexWhere((s) => s.id == id);
//     if (i == -1) return 'Application not found.';
//     _db[i] = _db[i].copyWith(status: 'converted');
//     return null;
//   }
// }
// import 'package:pokakbilling/core/api/api_constants.dart';
// import 'package:pokakbilling/core/api/dio_client.dart';

import 'package:pokakbilling/models/academy_models/form_submission_model.dart';

String _daysAgo(int n) {
  final d = DateTime.now().subtract(Duration(days: n));
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class FormSubmissionService {
  // Sample data. Replace with the real API later.
  static final List<FormSubmissionModel> _db = [
    FormSubmissionModel(
      id: 45, formType: kFormInternship, firstName: 'Jomol', lastName: 'K',
      email: 'abcd@gmail.com', phone: '9089464625', dateOfBirth: '2000-06-09',
      gender: 'Female', qualification: 'UG', courseName: 'javaa',
      durationMonths: 6, courseMode: 'online', counsellor: 'Abhal Benny',
      address: 'drtyhbnjkl, lmkkj', district: 'Kollam', state: 'Kerala',
      pincode: '629168', source: 'Social Media',
      status: 'pending', appliedDate: _daysAgo(2),
    ),
    FormSubmissionModel(
      id: 44, formType: kFormInternship, firstName: 'Fidha', lastName: 'Sudheer',
      email: 'fidhaah123@gmail.com', phone: '9876543210', gender: 'Female',
      qualification: 'UG', courseName: 'digital marketing', durationMonths: 3,
      counsellor: 'Abhal Benny', district: 'Kozhikode', state: 'Kerala',
      pincode: '673001', source: 'Website', status: 'pending',
      appliedDate: _daysAgo(4),
    ),
    FormSubmissionModel(
      id: 43, formType: kFormInternship, firstName: 'Muhammed', lastName: 'ak',
      email: 'aksiyad6369@gmail.com', phone: '+919645261264', gender: 'Male',
      qualification: 'PLUS_TWO', courseName: 'testing', durationMonths: 2,
      courseMode: 'offline', counsellor: 'Alan mathew', district: 'Malappuram',
      state: 'Kerala', pincode: '676505', source: 'Referral',
      status: 'received', appliedDate: _daysAgo(5),
    ),
    FormSubmissionModel(
      id: 42, formType: kFormInternship, firstName: 'Fidha', lastName: 'Sudheer',
      email: 'fidhasudheerconnect@gmail.com', phone: '4321567890',
      gender: 'Female', qualification: 'UG', courseName: 'MEAN Stack test',
      durationMonths: 6, counsellor: 'Shaheem Mahmood', district: 'Kannur',
      state: 'Kerala', pincode: '670001', source: 'Social Media',
      status: 'pending', appliedDate: _daysAgo(9),
    ),
    FormSubmissionModel(
      id: 41, formType: kFormInternship, firstName: 'aisrya', lastName: 'III',
      email: 'aiswaryasurendran97@gmail.com', phone: '+919645261264',
      gender: 'Female', qualification: 'SSLC', courseName: 'data analytics',
      durationMonths: 4, courseMode: 'recorded', counsellor: 'anaswara dev',
      district: 'Thrissur', state: 'Kerala', pincode: '680001',
      source: 'Call', status: 'converted', appliedDate: _daysAgo(14),
    ),
    FormSubmissionModel(
      id: 40, formType: kFormInternship, firstName: 'Jinta', lastName: 'Joji',
      email: 'jinta@gmail.com', phone: '2345642123', gender: 'Female',
      qualification: 'PG', courseName: 'testing', durationMonths: 3,
      counsellor: 'anaswara dev', district: 'Ernakulam', state: 'Kerala',
      pincode: '682001', source: 'Website', status: 'pending',
      appliedDate: _daysAgo(21),
    ),
    FormSubmissionModel(
      id: 39, formType: kFormInternship, firstName: 'Amal', lastName: 'siju',
      email: 'ABCDABCD@gmail.com', phone: '9678456423', gender: 'Male',
      qualification: 'PLUS_TWO', courseName: 'Game Development',
      durationMonths: 6, counsellor: 'John Peter', district: 'Kottayam',
      state: 'Kerala', pincode: '686001', source: 'Social Media',
      status: 'converted', appliedDate: _daysAgo(33),
    ),
    FormSubmissionModel(
      id: 11, formType: kFormFreeCourse, firstName: 'test', lastName: 'Pr',
      email: 'revathypr75@gmail.com', phone: '+919188030718', gender: 'Male',
      qualification: 'PLUS_TWO', educationalCourseName: 'btech',
      courseName: 'btech', durationMonths: 5, courseMode: 'offline',
      district: 'Palakkad', state: 'Kerala', pincode: '678001',
      source: 'Website', status: 'pending', appliedDate: _daysAgo(3),
    ),
    FormSubmissionModel(
      id: 10, formType: kFormFreeCourse, firstName: 'mufi', lastName: 'mufi',
      email: 'mufi@gmail.com', phone: '+919645261264', gender: 'Male',
      qualification: 'PLUS_TWO', educationalCourseName: 'BSC CS',
      courseName: 'BSC CS', durationMonths: 3, district: 'Kozhikode',
      state: 'Kerala', pincode: '673001', source: 'Referral',
      status: 'received', appliedDate: _daysAgo(6),
    ),
  ];

  static Future<void> _latency() =>
      Future.delayed(const Duration(milliseconds: 450));

  // API: GET ApiConstants.formSubmissions -> FormSubmissionModel.fromJson
  static Future<List<FormSubmissionModel>> fetchSubmissions() async {
    await _latency();
    return List<FormSubmissionModel>.from(_db);
  }

  // API: GET ApiConstants.formSubmissionById(id)
  static Future<FormSubmissionModel?> fetchById(int id) async {
    await _latency();
    for (final s in _db) {
      if (s.id == id) return s;
    }
    return null;
  }
}