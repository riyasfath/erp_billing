// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pokakbilling/models/academy_models/form_submission_model.dart';
// import 'package:pokakbilling/views/academy/academy_theme.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/services/academy/form_submission_service.dart';
// import 'package:pokakbilling/viewmodels/academy/form_submission_viewmodel.dart';

// Future<void> showEditSubmissionSheet(
//     BuildContext context, FormSubmissionModel s) {
//   return showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (_) => EditSubmissionSheet(submission: s),
//   );
// }

// class EditSubmissionSheet extends StatefulWidget {
//   final FormSubmissionModel submission;
//   const EditSubmissionSheet({super.key, required this.submission});

//   @override
//   State<EditSubmissionSheet> createState() => _EditSubmissionSheetState();
// }

// class _EditSubmissionSheetState extends State<EditSubmissionSheet> {
//   int _step = 0;
//   static const _titles = [
//     'Personal Details',
//     'Academic & Course',
//     'Address & Socials',
//     'Documents',
//   ];
//   static const _docTypes = [
//     'Aadhaar',
//     'Photo',
//     'Resume',
//     'Mark Sheet',
//     'ID Proof'
//   ];

//   late final TextEditingController _first, _last, _email, _phone, _phone2,
//       _dob, _eduCourse, _duration, _address, _district, _state, _pin,
//       _linkedin, _github, _portfolio;

//   String? _gender, _qualification, _course, _mode, _counsellor, _source;
//   String? _errFirst, _errLast, _errEmail, _errPhone, _errDob, _errAddress;
//   late List<_DocDraft> _docs;

//   @override
//   void initState() {
//     super.initState();
//     final s = widget.submission;
//     _first = TextEditingController(text: s.firstName);
//     _last = TextEditingController(text: s.lastName);
//     _email = TextEditingController(text: s.email);
//     _phone = TextEditingController(text: s.phone);
//     _phone2 = TextEditingController(text: s.secondaryPhone);
//     _dob = TextEditingController(text: s.dateOfBirth);
//     _eduCourse = TextEditingController(text: s.educationalCourseName);
//     _duration = TextEditingController(
//         text: s.durationMonths > 0 ? '${s.durationMonths}' : '');
//     _address = TextEditingController(text: s.address);
//     _district = TextEditingController(text: s.district);
//     _state = TextEditingController(text: s.state);
//     _pin = TextEditingController(text: s.pincode);
//     _linkedin = TextEditingController(text: s.linkedin);
//     _github = TextEditingController(text: s.github);
//     _portfolio = TextEditingController(text: s.portfolio);

//     _gender = s.gender.isEmpty ? null : s.gender;
//     _qualification = s.qualification.isEmpty ? null : s.qualification;
//     _course = s.courseName.isEmpty ? null : s.courseName;
//     _mode = s.courseMode.isEmpty ? 'online' : s.courseMode;
//     _counsellor = s.counsellor.isEmpty ? null : s.counsellor;
//     _source = s.source.isEmpty ? null : s.source;
//     _docs = s.documents
//         .map((d) => _DocDraft(type: d.documentType, fileName: d.fileName))
//         .toList();
//   }

//   @override
//   void dispose() {
//     for (final c in [
//       _first, _last, _email, _phone, _phone2, _dob, _eduCourse, _duration,
//       _address, _district, _state, _pin, _linkedin, _github, _portfolio
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   bool _validateStep() {
//     setState(() {
//       _errFirst = _errLast = _errEmail = _errPhone = _errDob = _errAddress =
//           null;
//       if (_step == 0) {
//         if (_first.text.trim().isEmpty) _errFirst = 'First name is required';
//         if (_last.text.trim().isEmpty) _errLast = 'Last name is required';
//         if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())) {
//           _errEmail = 'Enter a valid email';
//         }
//         if (_phone.text.trim().length < 10) _errPhone = 'Enter a valid phone';
//         if (_dob.text.trim().isEmpty) _errDob = 'Date of birth is required';
//       }
//       if (_step == 2 && _address.text.trim().isEmpty) {
//         _errAddress = 'Address is required';
//       }
//     });
//     return [_errFirst, _errLast, _errEmail, _errPhone, _errDob, _errAddress]
//         .every((e) => e == null);
//   }

//   Future<void> _pickDob() async {
//     final initial = DateTime.tryParse(_dob.text) ?? DateTime(2000);
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now(),
//       builder: (c, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: const ColorScheme.light(
//               primary: AcademyColors.purple,
//               onPrimary: AppColors.white,
//               surface: AppColors.white,
//               onSurface: AppColors.cdark),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() {
//         _dob.text =
//             '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
//         _errDob = null;
//       });
//     }
//   }

//   Future<void> _submit() async {
//     final vm = Provider.of<FormSubmissionViewmodel>(context, listen: false);
//     final updated = widget.submission.copyWith(
//       firstName: _first.text.trim(),
//       lastName: _last.text.trim(),
//       email: _email.text.trim(),
//       phone: _phone.text.trim(),
//       secondaryPhone: _phone2.text.trim(),
//       dateOfBirth: _dob.text.trim(),
//       gender: _gender ?? '',
//       qualification: _qualification ?? '',
//       educationalCourseName: _eduCourse.text.trim(),
//       courseName: _course ?? '',
//       durationMonths: int.tryParse(_duration.text.trim()) ?? 0,
//       courseMode: _mode ?? 'online',
//       counsellor: _counsellor ?? '',
//       address: _address.text.trim(),
//       district: _district.text.trim(),
//       state: _state.text.trim(),
//       pincode: _pin.text.trim(),
//       source: _source ?? '',
//       linkedin: _linkedin.text.trim(),
//       github: _github.text.trim(),
//       portfolio: _portfolio.text.trim(),
//       documents: _docs
//           .where((d) => d.type != null && d.fileName.isNotEmpty)
//           .toList()
//           .asMap()
//           .entries
//           .map((e) => SubmissionDocumentModel(
//               id: e.key + 1,
//               documentType: e.value.type!,
//               fileName: e.value.fileName))
//           .toList(),
//     );
//     final ok = await vm.updateSubmission(updated, context);
//     if (ok && mounted) Navigator.pop(context);
//   }

//   void _next() {
//     if (!_validateStep()) return;
//     if (_step < 3) {
//       setState(() => _step++);
//     } else {
//       _submit();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final vm = Provider.of<FormSubmissionViewmodel>(context);
//     final bottom = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       constraints:
//           BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//       ),
//       padding: EdgeInsets.only(bottom: bottom),
//       child: Column(mainAxisSize: MainAxisSize.min, children: [
//         // Header
//         Container(
//           padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
//           decoration: const BoxDecoration(
//             gradient: AcademyColors.headerGradient,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
//           ),
//           child: Row(children: [
//             Expanded(
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('EDIT MODE · ${widget.submission.code}',
//                         style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 10,
//                             letterSpacing: 0.8,
//                             fontWeight: FontWeight.w700)),
//                     const SizedBox(height: 3),
//                     Text('Edit Application: ${_titles[_step]}',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800)),
//                   ]),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                   color: Colors.white.withValues(alpha: 0.18),
//                   borderRadius: BorderRadius.circular(20)),
//               child: Text('Step ${_step + 1} of 4',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10.5,
//                       fontWeight: FontWeight.w700)),
//             ),
//             IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close_rounded, color: Colors.white)),
//           ]),
//         ),
//         // Stepper
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
//           child: Row(
//             children: List.generate(4, (i) {
//               final done = i < _step;
//               final cur = i == _step;
//               return Expanded(
//                 child: Row(children: [
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: done
//                           ? AcademyColors.green
//                           : cur
//                               ? AcademyColors.purple
//                               : AppColors.cxl,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                           color: done || cur
//                               ? Colors.transparent
//                               : AppColors.cborder),
//                     ),
//                     child: Center(
//                       child: done
//                           ? const Icon(Icons.check_rounded,
//                               size: 14, color: Colors.white)
//                           : Text('${i + 1}',
//                               style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w800,
//                                   color:
//                                       cur ? Colors.white : AppColors.ctext)),
//                     ),
//                   ),
//                   if (i < 3)
//                     Expanded(
//                       child: Container(
//                           height: 2,
//                           margin: const EdgeInsets.symmetric(horizontal: 4),
//                           color: done
//                               ? AcademyColors.green
//                               : AppColors.cborder),
//                     ),
//                 ]),
//               );
//             }),
//           ),
//         ),
//         Flexible(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
//             child: _stepBody(),
//           ),
//         ),
//         // Footer
//         Padding(
//           padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
//           child: Row(children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _step == 0
//                     ? Navigator.pop(context)
//                     : setState(() => _step--),
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(48),
//                   side: const BorderSide(color: AppColors.cborder, width: 1.5),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24)),
//                 ),
//                 child: Text(_step == 0 ? 'Cancel' : 'Back',
//                     style: const TextStyle(
//                         color: AppColors.ctext, fontWeight: FontWeight.w700)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: vm.actionLoader ? null : _next,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(48),
//                   backgroundColor: AcademyColors.purple,
//                   disabledBackgroundColor:
//                       AcademyColors.purple.withValues(alpha: 0.5),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24)),
//                 ),
//                 child: vm.actionLoader
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2))
//                     : Text(_step == 3 ? 'Update Application' : 'Next Step',
//                         style: const TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.w800)),
//               ),
//             ),
//           ]),
//         ),
//       ]),
//     );
//   }

//   Widget _stepBody() {
//     switch (_step) {
//       case 0:
//         return Column(children: [
//           AcademyTextField(
//               controller: _first,
//               label: 'First Name',
//               icon: Icons.person_outline_rounded,
//               isRequired: true,
//               error: _errFirst),
//           AcademyTextField(
//               controller: _last,
//               label: 'Last Name',
//               icon: Icons.person_outline_rounded,
//               isRequired: true,
//               error: _errLast),
//           AcademyTextField(
//               controller: _email,
//               label: 'Email Address',
//               icon: Icons.email_outlined,
//               isRequired: true,
//               keyboardType: TextInputType.emailAddress,
//               error: _errEmail),
//           AcademyTextField(
//               controller: _dob,
//               label: 'Date of Birth',
//               icon: Icons.cake_outlined,
//               isRequired: true,
//               readOnly: true,
//               onTap: _pickDob,
//               error: _errDob),
//           AcademyTextField(
//               controller: _phone,
//               label: 'Primary Phone',
//               icon: Icons.phone_outlined,
//               isRequired: true,
//               keyboardType: TextInputType.phone,
//               error: _errPhone),
//           AcademyTextField(
//               controller: _phone2,
//               label: 'Secondary Phone',
//               icon: Icons.phone_forwarded_outlined,
//               hint: 'Optional',
//               keyboardType: TextInputType.phone),
//           AcademyDropdown(
//             label: 'Gender',
//             icon: Icons.wc_rounded,
//             isRequired: true,
//             value: _gender,
//             items: const {'Male': 'Male', 'Female': 'Female', 'Other': 'Other'},
//             onChanged: (v) => setState(() => _gender = v),
//           ),
//         ]);
//       case 1:
//         return Column(children: [
//           AcademyDropdown(
//             label: 'Highest Qualification',
//             icon: Icons.school_outlined,
//             isRequired: true,
//             value: _qualification,
//             items: kQualifications,
//             onChanged: (v) => setState(() => _qualification = v),
//           ),
//           AcademyTextField(
//               controller: _eduCourse,
//               label: 'Educational Course Name',
//               icon: Icons.history_edu_rounded,
//               hint: 'e.g. BCA, B.Tech'),
//           AcademyDropdown(
//             label: widget.submission.isInternship
//                 ? 'Internship Applied For'
//                 : 'Course Applied For',
//             icon: Icons.work_outline_rounded,
//             isRequired: true,
//             value: _course,
//             items: {for (final c in FormSubmissionService.courses) c: c},
//             onChanged: (v) => setState(() => _course = v),
//           ),
//           AcademyTextField(
//               controller: _duration,
//               label: 'Preferred Duration (months)',
//               icon: Icons.calendar_month_rounded,
//               isRequired: true,
//               keyboardType: TextInputType.number,
//               inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 8, left: 2),
//               child: Text('Course Mode',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.ctext.withValues(alpha: 0.8))),
//             ),
//           ),
//           Row(
//             children: ['online', 'offline', 'recorded'].map((m) {
//               final sel = _mode == m;
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => setState(() => _mode = m),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: EdgeInsets.only(right: m == 'recorded' ? 0 : 8),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       gradient: sel ? AcademyColors.headerGradient : null,
//                       color: sel ? null : AppColors.cxl,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                           color: sel ? Colors.transparent : AppColors.cborder),
//                     ),
//                     child: Center(
//                       child: Text('${m[0].toUpperCase()}${m.substring(1)}',
//                           style: TextStyle(
//                               fontSize: 12.5,
//                               fontWeight: FontWeight.w700,
//                               color: sel ? Colors.white : AppColors.ctext)),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 14),
//           AcademyDropdown(
//             label: 'Counselor',
//             icon: Icons.support_agent_rounded,
//             isRequired: true,
//             value: _counsellor,
//             items: {for (final c in FormSubmissionService.counsellors) c: c},
//             onChanged: (v) => setState(() => _counsellor = v),
//           ),
//         ]);
//       case 2:
//         return Column(children: [
//           AcademyTextField(
//               controller: _address,
//               label: 'Full Address',
//               icon: Icons.location_on_outlined,
//               isRequired: true,
//               maxLines: 3,
//               error: _errAddress),
//           AcademyTextField(
//               controller: _district,
//               label: 'District',
//               icon: Icons.place_outlined),
//           AcademyTextField(
//               controller: _state,
//               label: 'State',
//               icon: Icons.map_outlined),
//           AcademyTextField(
//               controller: _pin,
//               label: 'Pincode',
//               icon: Icons.pin_drop_outlined,
//               keyboardType: TextInputType.number,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(6)
//               ]),
//           AcademyDropdown(
//             label: 'How did you find us?',
//             icon: Icons.campaign_outlined,
//             isRequired: true,
//             value: _source,
//             items: {for (final c in FormSubmissionService.sources) c: c},
//             onChanged: (v) => setState(() => _source = v),
//           ),
//           AcademyTextField(
//               controller: _linkedin,
//               label: 'LinkedIn',
//               icon: Icons.business_center_outlined,
//               keyboardType: TextInputType.url),
//           AcademyTextField(
//               controller: _github,
//               label: 'GitHub',
//               icon: Icons.code_rounded,
//               keyboardType: TextInputType.url),
//           AcademyTextField(
//               controller: _portfolio,
//               label: 'Portfolio',
//               icon: Icons.language_rounded,
//               keyboardType: TextInputType.url),
//         ]);
//       default:
//         return Column(children: [
//           Row(children: [
//             const Expanded(
//               child: Text('Attached Document Proofs',
//                   style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.cdark)),
//             ),
//             GestureDetector(
//               onTap: () => setState(() => _docs.add(_DocDraft())),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: AcademyColors.purple.withValues(alpha: 0.10),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                   Icon(Icons.add_rounded,
//                       size: 15, color: AcademyColors.purple),
//                   SizedBox(width: 4),
//                   Text('Add Document',
//                       style: TextStyle(
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w800,
//                           color: AcademyColors.purple)),
//                 ]),
//               ),
//             ),
//           ]),
//           const SizedBox(height: 12),
//           if (_docs.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               child: Text('No documents attached',
//                   style: TextStyle(
//                       color: AppColors.ctext.withValues(alpha: 0.7),
//                       fontSize: 12.5)),
//             ),
//           ...List.generate(_docs.length, (i) {
//             final d = _docs[i];
//             return Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: Column(children: [
//                 AcademyDropdown(
//                   label: 'Document Type',
//                   icon: Icons.description_outlined,
//                   value: d.type,
//                   items: {for (final t in _docTypes) t: t},
//                   onChanged: (v) => setState(() => d.type = v),
//                 ),
//                 Row(children: [
//                   Expanded(
//                     child: GestureDetector(
//                       // TODO: replace with file_picker. Currently it
//                       // simulates choosing a file so the flow can be tested.
//                       onTap: () => setState(
//                           () => d.fileName = 'document_${i + 1}.pdf'),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 13),
//                         decoration: BoxDecoration(
//                           color: AppColors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: AppColors.cborder),
//                         ),
//                         child: Row(children: [
//                           Expanded(
//                             child: Text(
//                                 d.fileName.isEmpty
//                                     ? 'Choose file (PDF/Image)…'
//                                     : d.fileName,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                     fontSize: 12.5,
//                                     color: d.fileName.isEmpty
//                                         ? AppColors.ctext
//                                             .withValues(alpha: 0.6)
//                                         : AppColors.cdark)),
//                           ),
//                           const Icon(Icons.upload_file_rounded,
//                               size: 18, color: AcademyColors.purple),
//                         ]),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: () => setState(() => _docs.removeAt(i)),
//                     child: Container(
//                       width: 40,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: AppColors.red.withValues(alpha: 0.08),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(Icons.delete_outline_rounded,
//                           size: 19, color: AppColors.red),
//                     ),
//                   ),
//                 ]),
//               ]),
//             );
//           }),
//         ]);
//     }
//   }
// }

// class _DocDraft {
//   String? type;
//   String fileName;
//   _DocDraft({this.type, this.fileName = ''});
// }