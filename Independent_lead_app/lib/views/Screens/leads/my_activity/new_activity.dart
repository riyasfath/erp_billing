// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/core/themes/app_assets.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/lead_model.dart';
// import 'package:pokakbilling/notification/notification_service.dart';
// import 'package:pokakbilling/viewmodels/activity/all_activityviewmodel.dart';
// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// // ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
// const String _kWhatsAppSvg = '''
// <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
//   <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
//   <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
// </svg>
// ''';

// class NewActivityScreen extends StatefulWidget {
//   const NewActivityScreen({super.key});
//   @override
//   State<NewActivityScreen> createState() => _NewActivityScreenState();
// }

// class _NewActivityScreenState extends State<NewActivityScreen>
//     with SingleTickerProviderStateMixin {
//   String selectedActivity = 'Meeting';

//   final List<String> _activityTypes = [
//     'Meeting',
//     'Email',
//     'Call',
//     'WhatsApp',
//     'Follow-up',
//     'Reminder',
//   ];

//   // ── Selected lead ──────────────────────────────────────────────────────
//   int? _selectedLeadId;
//   String _selectedLeadName = '';
//   String _selectedLeadCompany = '';
//   String _selectedLeadStatus = '';
//   String _selectedLeadPhone = '';
//   String _selectedLeadEmail = '';

//   // ── Date / Time ────────────────────────────────────────────────────────
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;

//   // ── Controllers ────────────────────────────────────────────────────────
//   final _meetingTitleCtrl = TextEditingController();
//   final _meetingDescCtrl = TextEditingController();
//   final _meetingSubtypeCtrl = TextEditingController();
//   final _meetingLocationCtrl = TextEditingController();
//   final _emailSubjectCtrl = TextEditingController();
//   final _emailMessageCtrl = TextEditingController();
//   final _waMessageCtrl = TextEditingController();
//   final _followTitleCtrl = TextEditingController();
//   final _followDescCtrl = TextEditingController();
//   final _reminderTitleCtrl = TextEditingController();
//   final _reminderDescCtrl = TextEditingController();
//   final _reminderSubtypeCtrl = TextEditingController();
//   final _leadSearchCtrl = TextEditingController();
//   String _leadSearch = '';

//   // ── Manual field errors ────────────────────────────────────────────────
//   String? _errLead;
//   String? _errMeetingTitle;
//   String? _errLocation;
//   String? _errEmailSubject;
//   String? _errFollowTitle;
//   String? _errReminderTitle;

//   late final AnimationController _animCtrl;
//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset> _slideAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 550));
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
//     _animCtrl.forward();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<LeadViewmodel>(context, listen: false).getAllLeads();
//     });
//   }

//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _meetingTitleCtrl.dispose();
//     _meetingDescCtrl.dispose();
//     _meetingSubtypeCtrl.dispose();
//     _meetingLocationCtrl.dispose();
//     _emailSubjectCtrl.dispose();
//     _emailMessageCtrl.dispose();
//     _waMessageCtrl.dispose();
//     _followTitleCtrl.dispose();
//     _followDescCtrl.dispose();
//     _reminderTitleCtrl.dispose();
//     _reminderDescCtrl.dispose();
//     _reminderSubtypeCtrl.dispose();
//     _leadSearchCtrl.dispose();
//     super.dispose();
//   }

//   // ── URL / location validation ──────────────────────────────────────────
//   bool _isValidLocationInput(String input) {
//     if (input.isEmpty) return true;
//     final looksLikeUrl =
//         input.contains('://') || input.toLowerCase().startsWith('www.');
//     if (!looksLikeUrl) return true;
//     final normalised =
//         input.toLowerCase().startsWith('www.') ? 'https://$input' : input;
//     final uri = Uri.tryParse(normalised);
//     if (uri == null || !uri.hasAuthority) return false;
//     const allowedSchemes = {
//       'https',
//       'http',
//       'meet',
//       'zoom',
//       'msteams',
//       'webex'
//     };
//     if (!allowedSchemes.contains(uri.scheme)) return false;
//     if (uri.host.isEmpty || !uri.host.contains('.')) return false;
//     return true;
//   }

//   // ── Launchers ──────────────────────────────────────────────────────────
//   Future<void> _openDialer(String phone) async {
//     final uri = Uri(scheme: 'tel', path: phone);
//     if (await canLaunchUrl(uri)) await launchUrl(uri);
//   }

//   Future<void> _openEmail(
//       {required String to, String subject = '', String body = ''}) async {
//     final uri = Uri(
//       scheme: 'mailto',
//       path: to,
//       queryParameters: {
//         if (subject.isNotEmpty) 'subject': subject,
//         if (body.isNotEmpty) 'body': body,
//       },
//     );
//     if (await canLaunchUrl(uri)) await launchUrl(uri);
//   }

//   Future<void> _openWhatsApp(
//       {required String phone, String message = ''}) async {
//     final cleaned = phone.replaceAll(RegExp(r'\D'), '');
//     final encoded = Uri.encodeComponent(message);
//     final url =
//         'https://wa.me/$cleaned${message.isNotEmpty ? '?text=$encoded' : ''}';
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }

//   // ── General helpers ────────────────────────────────────────────────────
//   void _snack(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: isError ? AppColors.red : AppColors.green,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     ));
//   }

//   Future<void> _notify(String type, String detail) async {
//     await NotificationService.instance
//         .showActivityScheduledNotification(activityType: type, detail: detail);
//   }

//   String get _isoDateTime {
//     final date = _selectedDate ?? DateTime.now();
//     final time = _selectedTime ?? TimeOfDay.now();
//     return DateTime(date.year, date.month, date.day, time.hour, time.minute)
//         .toUtc()
//         .toIso8601String();
//   }

//   String get _dateLabel => _selectedDate == null
//       ? 'Select Date'
//       : '${_selectedDate!.day.toString().padLeft(2, '0')}-'
//           '${_selectedDate!.month.toString().padLeft(2, '0')}-'
//           '${_selectedDate!.year}';

//   String get _timeLabel =>
//       _selectedTime == null ? 'Select Time' : _selectedTime!.format(context);

//   Future<void> _pickDate() async {
//     final p = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (ctx, child) => Theme(
//           data: ThemeData.light().copyWith(
//               colorScheme: const ColorScheme.light(
//                   primary: AppColors.c1,
//                   onPrimary: AppColors.white,
//                   surface: AppColors.white)),
//           child: child!),
//     );
//     if (p != null) setState(() => _selectedDate = p);
//   }

//   Future<void> _pickTime() async {
//     final p = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//       builder: (ctx, child) => Theme(
//           data: ThemeData.light().copyWith(
//               colorScheme: const ColorScheme.light(
//                   primary: AppColors.c1,
//                   onPrimary: AppColors.white,
//                   surface: AppColors.white)),
//           child: child!),
//     );
//     if (p != null) setState(() => _selectedTime = p);
//   }

//   // ══════════════════════════════════════════════════════════════════════
//   // SUBMIT HANDLERS
//   // ══════════════════════════════════════════════════════════════════════

//   Future<void> _submitMeeting() async {
//     final leadErr =
//         _selectedLeadId == null ? 'Please choose a lead first' : null;
//     final titleErr = _meetingTitleCtrl.text.trim().isEmpty
//         ? 'Meeting title is required'
//         : null;
//     final locationErr = !_isValidLocationInput(_meetingLocationCtrl.text.trim())
//         ? 'Enter a valid URL (e.g. https://meet.google.com/abc-xyz)'
//         : null;

//     setState(() {
//       _errLead = leadErr;
//       _errMeetingTitle = titleErr;
//       _errLocation = locationErr;
//     });

//     if (leadErr != null || titleErr != null || locationErr != null) return;

//     final vm = Provider.of<AllActivityViewModel>(context, listen: false);
//     final ok = await vm.scheduleMeeting(
//       leadId: _selectedLeadId!,
//       title: _meetingTitleCtrl.text.trim(),
//       description: _meetingDescCtrl.text.trim(),
//       subtype: _meetingSubtypeCtrl.text.trim(),
//       location: _meetingLocationCtrl.text.trim(),
//       dueDate: _isoDateTime,
//     );
//     if (ok) {
//       await _notify('Meeting',
//           'Meeting "${_meetingTitleCtrl.text.trim()}" has been scheduled');
//       _snack('📅 Meeting scheduled!');
//       if (mounted) Navigator.pop(context);
//     } else {
//       _snack(vm.submitError ?? 'Failed to schedule meeting', isError: true);
//     }
//   }

//   Future<void> _submitEmail() async {
//     final leadErr =
//         _selectedLeadId == null ? 'Please choose a lead first' : null;
//     final emailErr = _selectedLeadEmail.isEmpty
//         ? 'No email found for the selected lead'
//         : null;
//     final subjectErr = _emailSubjectCtrl.text.trim().isEmpty
//         ? 'Email subject is required'
//         : null;

//     setState(() {
//       _errLead = leadErr;
//       _errEmailSubject = subjectErr;
//     });

//     if (leadErr != null || emailErr != null || subjectErr != null) {
//       if (emailErr != null) _snack(emailErr, isError: true);
//       return;
//     }

//     final vm = Provider.of<AllActivityViewModel>(context, listen: false);
//     final ok = await vm.logEmail(
//       leadId: _selectedLeadId!,
//       email: _selectedLeadEmail,
//       subject: _emailSubjectCtrl.text.trim(),
//       message: _emailMessageCtrl.text.trim(),
//     );
//     if (ok) {
//       await _notify('Email', 'Email to $_selectedLeadEmail logged');
//       _snack('✉️ Email logged!');
//       await _openEmail(
//         to: _selectedLeadEmail,
//         subject: _emailSubjectCtrl.text.trim(),
//         body: _emailMessageCtrl.text.trim(),
//       );
//       if (mounted) Navigator.pop(context);
//     } else {
//       _snack(vm.submitError ?? 'Failed to log email', isError: true);
//     }
//   }

//   Future<void> _submitCall() async {
//     final leadErr =
//         _selectedLeadId == null ? 'Please choose a lead first' : null;
//     final phoneErr = _selectedLeadPhone.isEmpty
//         ? 'No phone number found for the selected lead'
//         : null;

//     setState(() => _errLead = leadErr);

//     if (leadErr != null || phoneErr != null) {
//       if (phoneErr != null) _snack(phoneErr, isError: true);
//       return;
//     }

//     final vm = Provider.of<AllActivityViewModel>(context, listen: false);
//     final ok = await vm.logCall(
//       leadId: _selectedLeadId!,
//       phoneNumber: _selectedLeadPhone,
//     );
//     if (ok) {
//       await _notify('Call', 'Call to $_selectedLeadPhone logged');
//       _snack('📞 Call logged!');
//       await _openDialer(_selectedLeadPhone);
//       if (mounted) Navigator.pop(context);
//     } else {
//       _snack(vm.submitError ?? 'Failed to log call', isError: true);
//     }
//   }

//   Future<void> _submitWhatsApp() async {
//     final leadErr =
//         _selectedLeadId == null ? 'Please choose a lead first' : null;
//     final phoneErr = _selectedLeadPhone.isEmpty
//         ? 'No phone number found for the selected lead'
//         : null;

//     setState(() => _errLead = leadErr);

//     if (leadErr != null || phoneErr != null) {
//       if (phoneErr != null) _snack(phoneErr, isError: true);
//       return;
//     }

//     final vm = Provider.of<AllActivityViewModel>(context, listen: false);
//     final ok = await vm.logWhatsApp(
//       leadId: _selectedLeadId!,
//       phoneNumber: _selectedLeadPhone,
//       message: _waMessageCtrl.text.trim(),
//     );
//     if (ok) {
//       await _notify('WhatsApp', 'WhatsApp to $_selectedLeadPhone logged');
//       _snack('WhatsApp logged!');
//       await _openWhatsApp(
//         phone: _selectedLeadPhone,
//         message: _waMessageCtrl.text.trim(),
//       );
//       if (mounted) Navigator.pop(context);
//     } else {
//       _snack(vm.submitError ?? 'Failed to log WhatsApp', isError: true);
//     }
//   }

//   Future<void> _submitFollowUp() async {
//     final leadErr =
//         _selectedLeadId == null ? 'Please choose a lead first' : null;
//     final titleErr = _followTitleCtrl.text.trim().isEmpty
//         ? 'Follow-up title is required'
//         : null;

//     setState(() {
//       _errLead = leadErr;
//       _errFollowTitle = titleErr;
//     });

//     if (leadErr != null || titleErr != null) return;

//     final vm = Provider.of<AllActivityViewModel>(context, listen: false);
//     final ok = await vm.scheduleFollowUp(
//       leadId: _selectedLeadId!,
//       title: _followTitleCtrl.text.trim(),
//       description: _followDescCtrl.text.trim(),
//       dueDate: _isoDateTime,
//     );
//     if (ok) {
//       await _notify('Follow-up',
//           'Follow-up "${_followTitleCtrl.text.trim()}" has been scheduled');
//       _snack('🔁 Follow-up scheduled!');
//       if (mounted) Navigator.pop(context);
//     } else {
//       _snack(vm.submitError ?? 'Failed to schedule follow-up', isError: true);
//     }
//   }

//   Future<void> _submitReminder() async {
//     final leadErr =
//         _selectedLeadId == null ? 'Please choose a lead first' : null;
//     final titleErr = _reminderTitleCtrl.text.trim().isEmpty
//         ? 'Reminder title is required'
//         : null;

//     setState(() {
//       _errLead = leadErr;
//       _errReminderTitle = titleErr;
//     });

//     if (leadErr != null || titleErr != null) return;

//     final vm = Provider.of<AllActivityViewModel>(context, listen: false);
//     final ok = await vm.setReminder(
//       leadId: _selectedLeadId!,
//       title: _reminderTitleCtrl.text.trim(),
//       description: _reminderDescCtrl.text.trim(),
//       subtype: _reminderSubtypeCtrl.text.trim(),
//       dueDate: _isoDateTime,
//     );
//     if (ok) {
//       await _notify('Reminder',
//           'Reminder "${_reminderTitleCtrl.text.trim()}" has been set');
//       _snack('🔔 Reminder set!');
//       if (mounted) Navigator.pop(context);
//     } else {
//       _snack(vm.submitError ?? 'Failed to set reminder', isError: true);
//     }
//   }

//   // ══════════════════════════════════════════════════════════════════════
//   // LEAD SHEET
//   // ══════════════════════════════════════════════════════════════════════
//   void _openLeadSheet() {
//     _leadSearch = '';
//     _leadSearchCtrl.clear();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (sheetCtx) => StatefulBuilder(builder: (ctx, setSheet) {
//         return Consumer<LeadViewmodel>(builder: (_, lvm, __) {
//           final q = _leadSearch.toLowerCase();
//           final leads = q.isEmpty
//               ? lvm.leadList
//               : lvm.leadList.where((l) {
//                   return (l.name ?? '').toLowerCase().contains(q) ||
//                       (l.company ?? '').toLowerCase().contains(q) ||
//                       (l.phone ?? '').toLowerCase().contains(q);
//                 }).toList();

//           return Container(
//             height: MediaQuery.of(context).size.height * .75,
//             decoration: const BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: Column(children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(top: 12, bottom: 16),
//                 decoration: BoxDecoration(
//                     color: AppColors.c1,
//                     borderRadius: BorderRadius.circular(2)),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                         color: AppColors.c1.withOpacity(.18),
//                         shape: BoxShape.circle),
//                     child: const Icon(Icons.person_search_rounded,
//                         color: AppColors.c1, size: 18),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text('Choose a Lead',
//                         style: TextStyle(
//                             color: AppColors.cdark,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w800)),
//                   ),
//                   if (lvm.getLeadLoader)
//                     const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                             color: AppColors.c1, strokeWidth: 2)),
//                 ]),
//               ),
//               const SizedBox(height: 14),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   height: 42,
//                   padding: const EdgeInsets.symmetric(horizontal: 14),
//                   decoration: BoxDecoration(
//                     color: AppColors.cxl,
//                     borderRadius: BorderRadius.circular(22),
//                     border: Border.all(color: AppColors.c1.withOpacity(.25)),
//                   ),
//                   child: Row(children: [
//                     Icon(Icons.search_rounded,
//                         size: 16, color: AppColors.ctext.withOpacity(.5)),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         controller: _leadSearchCtrl,
//                         textAlignVertical: TextAlignVertical.center,
//                         style: const TextStyle(
//                             color: AppColors.cdark, fontSize: 13),
//                         decoration: InputDecoration(
//                           hintText: 'Search by name, company…',
//                           hintStyle: TextStyle(
//                               color: AppColors.ctext.withOpacity(.45),
//                               fontSize: 13),
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                         onChanged: (v) => setSheet(() => _leadSearch = v),
//                       ),
//                     ),
//                   ]),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Divider(color: AppColors.cborder, height: 1),
//               Expanded(
//                 child: leads.isEmpty
//                     ? Center(
//                         child:
//                             Column(mainAxisSize: MainAxisSize.min, children: [
//                         Icon(Icons.inbox_rounded,
//                             size: 44, color: AppColors.ctext.withOpacity(.25)),
//                         const SizedBox(height: 10),
//                         Text(
//                             lvm.getLeadLoader
//                                 ? 'Loading leads…'
//                                 : 'No leads found',
//                             style: TextStyle(
//                                 color: AppColors.ctext.withOpacity(.45),
//                                 fontSize: 13)),
//                       ]))
//                     : ListView.separated(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 10),
//                         itemCount: leads.length,
//                         separatorBuilder: (_, __) =>
//                             const Divider(color: AppColors.cborder, height: 1),
//                         itemBuilder: (_, i) => _leadTile(leads[i], sheetCtx),
//                       ),
//               ),
//               const SizedBox(height: 12),
//             ]),
//           );
//         });
//       }),
//     );
//   }

//   Widget _leadTile(LeadModel lead, BuildContext sheetCtx) {
//     final initials =
//         (lead.name?.isNotEmpty == true) ? lead.name![0].toUpperCase() : 'L';
//     final isSelected = _selectedLeadId == lead.id;

//     Color statusColor;
//     switch ((lead.status ?? '').toUpperCase()) {
//       case 'CONVERTED':
//         statusColor = AppColors.green;
//         break;
//       case 'LOST':
//         statusColor = AppColors.red;
//         break;
//       case 'NEW':
//         statusColor = AppColors.c1;
//         break;
//       default:
//         statusColor = const Color(0xFFF59E0B);
//     }

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedLeadId = lead.id;
//           _selectedLeadName = lead.name ?? '';
//           _selectedLeadCompany = lead.company ?? '';
//           _selectedLeadStatus = lead.status ?? '';
//           _selectedLeadPhone = lead.phone ?? '';
//           _selectedLeadEmail = lead.email ?? '';
//           if (_errLead != null) _errLead = null;
//         });
//         Navigator.pop(sheetCtx);
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.c1.withOpacity(.10) : AppColors.cxl,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//               color: isSelected
//                   ? AppColors.c1.withOpacity(.40)
//                   : AppColors.cborder,
//               width: 1.2),
//         ),
//         child: Row(children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppColors.c1.withOpacity(.20),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//                 child: Text(initials,
//                     style: const TextStyle(
//                         color: AppColors.cdark,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 16))),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(lead.name ?? 'Unknown',
//                   style: const TextStyle(
//                       color: AppColors.cdark,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 13),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis),
//               if ((lead.company ?? '').isNotEmpty) ...[
//                 const SizedBox(height: 2),
//                 Text(lead.company!,
//                     style: TextStyle(
//                         color: AppColors.ctext.withOpacity(.55), fontSize: 11),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis),
//               ],
//               if ((lead.phone ?? '').isNotEmpty) ...[
//                 const SizedBox(height: 3),
//                 Row(children: [
//                   Icon(Icons.call_rounded,
//                       size: 10, color: AppColors.orange.withOpacity(.7)),
//                   const SizedBox(width: 3),
//                   Text(lead.phone!,
//                       style: TextStyle(
//                           color: AppColors.ctext.withOpacity(.50),
//                           fontSize: 10)),
//                 ]),
//               ],
//               if ((lead.email ?? '').isNotEmpty) ...[
//                 const SizedBox(height: 1),
//                 Row(children: [
//                   Icon(Icons.email_rounded,
//                       size: 10, color: AppColors.blue.withOpacity(.7)),
//                   const SizedBox(width: 3),
//                   Expanded(
//                     child: Text(lead.email!,
//                         style: TextStyle(
//                             color: AppColors.ctext.withOpacity(.50),
//                             fontSize: 10),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis),
//                   ),
//                 ]),
//               ],
//             ]),
//           ),
//           if ((lead.status ?? '').isNotEmpty)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                   color: statusColor.withOpacity(.12),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                       color: statusColor.withOpacity(.35), width: .8)),
//               child: Text(lead.status!,
//                   style: TextStyle(
//                       color: statusColor,
//                       fontSize: 9,
//                       fontWeight: FontWeight.w700)),
//             ),
//           const SizedBox(width: 8),
//           if (isSelected)
//             Icon(Icons.check_circle_rounded, color: AppColors.c1, size: 18),
//         ]),
//       ),
//     );
//   }

//   // ══════════════════════════════════════════════════════════════════════
//   // BUILD
//   // ══════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final top = MediaQuery.of(context).padding.top;
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: SizedBox(
//         width: double.infinity,
//         height: double.infinity,
//         child: Column(children: [
//           _buildHeader(context, sw, top),
//           Expanded(
//             child: FadeTransition(
//               opacity: _fadeAnim,
//               child: SlideTransition(
//                 position: _slideAnim,
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildTypeSection(),
//                         const SizedBox(height: 14),
//                         _buildLeadSection(),
//                         const SizedBox(height: 14),
//                         _buildDynamicForm(),
//                       ]),
//                 ),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // HEADER
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _buildHeader(BuildContext context, double sw, double top) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//           top: top + 12, bottom: 28, left: sw * .03, right: sw * .04),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border:
//             Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
//       ),
//       child: Row(children: [
//         GestureDetector(
//           onTap: () => pushNavigation(context, const BottomBar(index: 0)),
//           child: Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: AppColors.cxl,
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.cborder),
//             ),
//             child: Image.asset(AppAssets.homeIcon,
//                 width: 16, height: 16, color: AppColors.c1),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text('New Organizer Task',
//               style: TextStyle(
//                   color: AppColors.cdark,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800)),
//           const Text('Schedule & log tasks',
//               style: TextStyle(color: AppColors.ctext, fontSize: 12)),
//         ]),
//       ]),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // SECTION CARD
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _buildSection({
//     required IconData icon,
//     required String title,
//     required List<Widget> children,
//     Widget? trailing,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.cborder),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.c1.withOpacity(0.06),
//             blurRadius: 14,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: AppColors.cxl,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: AppColors.cborder),
//             ),
//             child: Icon(icon, color: AppColors.c1, size: 16),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(title,
//                 style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.cdark)),
//           ),
//           if (trailing != null) trailing,
//         ]),
//         const Divider(height: 20, thickness: 1, color: AppColors.cborder),
//         ...children,
//       ]),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // TEXT FIELD  — hint text turns red when there is an error and field is empty
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _field(
//     TextEditingController controller,
//     String label,
//     IconData icon, {
//     bool isRequired = false,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     String? error,
//     void Function(String)? onChanged,
//     String? hint,
//   }) {
//     final hasError = error != null && error.isNotEmpty;
//     // Show red hint only when there is an error AND the field is still empty
//     final showRedHint = hasError && controller.text.trim().isEmpty;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             maxLines: maxLines,
//             cursorColor: AppColors.c1,
//             onChanged: onChanged,
//             style: const TextStyle(fontSize: 14, color: AppColors.cdark),
//             decoration: InputDecoration(
//               labelText: label,
//               labelStyle: TextStyle(
//                 fontSize: 13,
//                 color: showRedHint
//                     ? AppColors.red
//                     : AppColors.ctext.withOpacity(0.75),
//               ),
//               hintText: hint,
//               hintStyle: TextStyle(
//                 fontSize: 12,
//                 color: showRedHint
//                     ? AppColors.red
//                     : AppColors.ctext.withOpacity(0.45),
//               ),
//               prefixIcon: Icon(icon,
//                   size: 18, color: hasError ? AppColors.red : AppColors.c1),
//               suffixIcon: isRequired
//                   ? Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: Icon(Icons.circle, size: 6, color: AppColors.red),
//                     )
//                   : null,
//               suffixIconConstraints:
//                   const BoxConstraints(minWidth: 32, minHeight: 32),
//               filled: true,
//               fillColor:
//                   hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: hasError
//                         ? AppColors.red.withOpacity(0.60)
//                         : AppColors.cborder),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: hasError
//                         ? AppColors.red.withOpacity(0.60)
//                         : AppColors.cborder),
//               ),
//               disabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: AppColors.cborder),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                     color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
//               ),
//             ),
//           ),
//           if (hasError)
//             Padding(
//               padding: const EdgeInsets.only(top: 5, left: 4),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline_rounded,
//                       size: 13, color: AppColors.red),
//                   const SizedBox(width: 4),
//                   Flexible(
//                     child: Text(error,
//                         style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.red,
//                             height: 1.4)),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // READ-ONLY CONTACT INFO TILE
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _contactInfoTile({
//     required bool isWhatsApp,
//     required IconData? icon,
//     required Color color,
//     required String value,
//     required String emptyLabel,
//   }) {
//     final hasValue = value.isNotEmpty;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Container(
//         height: 50,
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           color: AppColors.cxl,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//               color:
//                   hasValue ? AppColors.c1.withOpacity(.35) : AppColors.cborder),
//         ),
//         child: Row(children: [
//           if (isWhatsApp)
//             SvgPicture.string(
//               _kWhatsAppSvg,
//               width: 18,
//               height: 18,
//               colorFilter: ColorFilter.mode(
//                   hasValue ? AppColors.c1 : AppColors.ctext.withOpacity(.30),
//                   BlendMode.srcIn),
//             )
//           else
//             Icon(icon,
//                 size: 18,
//                 color: hasValue ? color : AppColors.ctext.withOpacity(.30)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               hasValue ? value : emptyLabel,
//               style: TextStyle(
//                   fontSize: 14,
//                   color: hasValue
//                       ? AppColors.cdark
//                       : AppColors.ctext.withOpacity(0.55),
//                   fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (!hasValue)
//             Text('Select lead first',
//                 style: TextStyle(
//                     color: AppColors.ctext.withOpacity(.40), fontSize: 11)),
//         ]),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // DATE / TIME ROW
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _dateTimeRow() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(children: [
//         Expanded(
//             child: GestureDetector(
//                 onTap: _pickDate,
//                 child: _pickerTile(
//                     icon: Icons.calendar_today_rounded, label: _dateLabel))),
//         const SizedBox(width: 10),
//         Expanded(
//             child: GestureDetector(
//                 onTap: _pickTime,
//                 child: _pickerTile(
//                     icon: Icons.access_time_rounded, label: _timeLabel))),
//       ]),
//     );
//   }

//   Widget _pickerTile({required IconData icon, required String label}) {
//     final isEmpty = label.startsWith('Select');
//     return Container(
//       height: 50,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: AppColors.cxl,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.cborder),
//       ),
//       child: Row(children: [
//         Icon(icon, size: 18, color: AppColors.c1),
//         const SizedBox(width: 10),
//         Expanded(
//             child: Text(label,
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: isEmpty
//                         ? AppColors.ctext.withOpacity(0.75)
//                         : AppColors.cdark),
//                 overflow: TextOverflow.ellipsis)),
//       ]),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // SAVE / SUBMIT BUTTON
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _saveBar({
//     required String label,
//     required IconData icon,
//     String? svgIcon,
//     required VoidCallback onTap,
//   }) {
//     return Consumer<AllActivityViewModel>(
//       builder: (_, vm, __) => SizedBox(
//         width: double.infinity,
//         height: 50,
//         child: DecoratedBox(
//           decoration: BoxDecoration(
//             color: AppColors.c1,
//             borderRadius: BorderRadius.circular(25),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.c1.withOpacity(0.30),
//                 blurRadius: 14,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: ElevatedButton(
//             onPressed: vm.isSubmitting ? null : onTap,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.transparent,
//               shadowColor: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25)),
//             ),
//             child: vm.isSubmitting
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                         color: AppColors.white, strokeWidth: 2),
//                   )
//                 : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       if (svgIcon != null)
//                         SvgPicture.string(svgIcon,
//                             width: 18,
//                             height: 18,
//                             colorFilter: const ColorFilter.mode(
//                                 AppColors.white, BlendMode.srcIn))
//                       else
//                         Icon(icon, color: AppColors.white, size: 18),
//                       const SizedBox(width: 8),
//                       Text(label,
//                           style: const TextStyle(
//                               color: AppColors.white,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               letterSpacing: 0.8)),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // TYPE SELECTOR SECTION
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _buildTypeSection() {
//     return _buildSection(
//       icon: Icons.category_outlined,
//       title: 'Task Type',
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: _activityTypes.map((type) {
//               final active = selectedActivity == type;
//               final isWA = type == 'WhatsApp';
//               return GestureDetector(
//                 onTap: () => setState(() {
//                   selectedActivity = type;
//                   _selectedDate = null;
//                   _selectedTime = null;
//                   _errMeetingTitle = null;
//                   _errLocation = null;
//                   _errEmailSubject = null;
//                   _errFollowTitle = null;
//                   _errReminderTitle = null;
//                 }),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: const EdgeInsets.only(right: 8),
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color:
//                         active ? AppColors.c1 : AppColors.c1.withOpacity(.08),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: active
//                             ? AppColors.c1
//                             : AppColors.c1.withOpacity(.22)),
//                   ),
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     if (isWA) ...[
//                       SvgPicture.string(
//                         _kWhatsAppSvg,
//                         width: 12,
//                         height: 12,
//                         colorFilter: ColorFilter.mode(
//                             active ? AppColors.white : AppColors.c1,
//                             BlendMode.srcIn),
//                       ),
//                       const SizedBox(width: 5),
//                     ],
//                     Text(type,
//                         style: TextStyle(
//                             color: active ? AppColors.white : AppColors.c1,
//                             fontWeight:
//                                 active ? FontWeight.w700 : FontWeight.w500,
//                             fontSize: 12)),
//                   ]),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // LEAD SELECTOR SECTION
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _buildLeadSection() {
//     final hasLeadError = _errLead != null && _errLead!.isNotEmpty;

//     return _buildSection(
//       icon: Icons.person_search_rounded,
//       title: 'Lead',
//       trailing: Padding(
//         padding: const EdgeInsets.only(right: 2),
//         child: Icon(Icons.circle, size: 6, color: AppColors.red),
//       ),
//       children: [
//         _selectedLeadId != null
//             ? _selectedLeadCard()
//             : _leadEmptyPicker(hasLeadError),
//         if (hasLeadError)
//           Padding(
//             padding: const EdgeInsets.only(top: 2, left: 4),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline_rounded,
//                     size: 13, color: AppColors.red),
//                 const SizedBox(width: 4),
//                 Flexible(
//                   child: Text(_errLead!,
//                       style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.red,
//                           height: 1.4)),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _selectedLeadCard() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.c1.withOpacity(.06),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.c1.withOpacity(.25), width: 1.2),
//       ),
//       child: Row(children: [
//         Container(
//           width: 42,
//           height: 42,
//           decoration: BoxDecoration(
//             color: AppColors.c1.withOpacity(.20),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//               child: Text(
//                   _selectedLeadName.isNotEmpty
//                       ? _selectedLeadName[0].toUpperCase()
//                       : 'L',
//                   style: const TextStyle(
//                       color: AppColors.cdark,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 16))),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child:
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(_selectedLeadName,
//                 style: const TextStyle(
//                     color: AppColors.cdark,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis),
//             if (_selectedLeadCompany.isNotEmpty)
//               Text(_selectedLeadCompany,
//                   style: TextStyle(
//                       color: AppColors.ctext.withOpacity(.55), fontSize: 11)),
//             if (_selectedLeadPhone.isNotEmpty) ...[
//               const SizedBox(height: 3),
//               Row(children: [
//                 Icon(Icons.call_rounded,
//                     size: 11, color: AppColors.orange.withOpacity(.8)),
//                 const SizedBox(width: 4),
//                 Text(_selectedLeadPhone,
//                     style: TextStyle(
//                         color: AppColors.ctext.withOpacity(.65), fontSize: 11)),
//               ]),
//             ],
//             if (_selectedLeadEmail.isNotEmpty) ...[
//               const SizedBox(height: 2),
//               Row(children: [
//                 Icon(Icons.email_rounded,
//                     size: 11, color: AppColors.blue.withOpacity(.8)),
//                 const SizedBox(width: 4),
//                 Expanded(
//                     child: Text(_selectedLeadEmail,
//                         style: TextStyle(
//                             color: AppColors.ctext.withOpacity(.65),
//                             fontSize: 11),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis)),
//               ]),
//             ],
//           ]),
//         ),
//         if (_selectedLeadStatus.isNotEmpty)
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//                 color: AppColors.c1.withOpacity(.15),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                     color: AppColors.c1.withOpacity(.35), width: .8)),
//             child: Text(_selectedLeadStatus,
//                 style: const TextStyle(
//                     color: AppColors.c1,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w700)),
//           ),
//         const SizedBox(width: 8),
//         GestureDetector(
//           onTap: _openLeadSheet,
//           child: Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//                 color: AppColors.c1.withOpacity(.12), shape: BoxShape.circle),
//             child:
//                 const Icon(Icons.edit_rounded, color: AppColors.c1, size: 14),
//           ),
//         ),
//         const SizedBox(width: 6),
//         GestureDetector(
//           onTap: () => setState(() {
//             _selectedLeadId = null;
//             _selectedLeadName = '';
//             _selectedLeadCompany = '';
//             _selectedLeadStatus = '';
//             _selectedLeadPhone = '';
//             _selectedLeadEmail = '';
//           }),
//           child: Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//                 color: AppColors.red.withOpacity(.12), shape: BoxShape.circle),
//             child:
//                 const Icon(Icons.close_rounded, color: AppColors.red, size: 14),
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _leadEmptyPicker(bool hasError) {
//     return GestureDetector(
//       onTap: _openLeadSheet,
//       child: DottedBorder(
//         borderType: BorderType.RRect,
//         radius: const Radius.circular(10),
//         dashPattern: const [6, 4],
//         color: hasError
//             ? AppColors.red.withOpacity(.60)
//             : AppColors.c1.withOpacity(.45),
//         strokeWidth: 1.5,
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//               color: hasError
//                   ? AppColors.red.withOpacity(.04)
//                   : AppColors.c1.withOpacity(.03),
//               borderRadius: BorderRadius.circular(10)),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Icon(Icons.person_add_alt_1_rounded,
//                 color: hasError ? AppColors.red : AppColors.c1, size: 18),
//             const SizedBox(width: 8),
//             Text('Choose a Lead',
//                 style: TextStyle(
//                     // ← hint text also red on error, matching the dotted border
//                     color: hasError ? AppColors.red : AppColors.cdark,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13)),
//           ]),
//         ),
//       ),
//     );
//   }

//   // ══════════════════════════════════════════════════════════════════════
//   // DYNAMIC FORM ROUTER
//   // ══════════════════════════════════════════════════════════════════════
//   Widget _buildDynamicForm() {
//     switch (selectedActivity) {
//       case 'Meeting':
//         return _meetingForm();
//       case 'Email':
//         return _emailForm();
//       case 'Call':
//         return _callForm();
//       case 'WhatsApp':
//         return _whatsappForm();
//       case 'Follow-up':
//         return _followUpForm();
//       case 'Reminder':
//         return _reminderForm();
//       default:
//         return const SizedBox();
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // MEETING FORM
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _meetingForm() {
//     return _buildSection(
//       icon: Icons.videocam_outlined,
//       title: 'Schedule Meeting',
//       children: [
//         _field(
//           _meetingTitleCtrl,
//           'Meeting Title',
//           Icons.title_rounded,
//           isRequired: true,
//           hint: 'Enter meeting title',
//           error: _errMeetingTitle,
//           onChanged: (_) {
//             if (_errMeetingTitle != null)
//               setState(() => _errMeetingTitle = null);
//           },
//         ),
//         _field(_meetingDescCtrl, 'Description', Icons.notes_rounded,
//             maxLines: 3),
//         _field(_meetingSubtypeCtrl, 'Meet type (e.g. Video Call)',
//             Icons.category_outlined),
//         _field(
//           _meetingLocationCtrl,
//           'Address or video call link',
//           Icons.link_rounded,
//           hint: 'Enter address or link',
//           error: _errLocation,
//           onChanged: (_) {
//             if (_errLocation != null) setState(() => _errLocation = null);
//           },
//         ),
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Text('DATE & TIME',
//               style: TextStyle(
//                   color: AppColors.ctext,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: .6)),
//         ),
//         _dateTimeRow(),
//         const SizedBox(height: 4),
//         _saveBar(
//           label: 'Schedule Meeting',
//           icon: Icons.videocam_rounded,
//           onTap: _submitMeeting,
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // EMAIL FORM
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _emailForm() {
//     return _buildSection(
//       icon: Icons.email_outlined,
//       title: 'Log Email',
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Text('TO',
//               style: TextStyle(
//                   color: AppColors.ctext,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: .6)),
//         ),
//         _contactInfoTile(
//           isWhatsApp: false,
//           icon: Icons.email_rounded,
//           color: AppColors.blue,
//           value: _selectedLeadEmail,
//           emptyLabel: 'Lead email will appear here',
//         ),
//         _field(
//           _emailSubjectCtrl,
//           'Subject',
//           Icons.subject_rounded,
//           isRequired: true,
//           hint: 'Enter email subject',
//           error: _errEmailSubject,
//           onChanged: (_) {
//             if (_errEmailSubject != null)
//               setState(() => _errEmailSubject = null);
//           },
//         ),
//         _field(_emailMessageCtrl, 'Message', Icons.message_outlined,
//             maxLines: 4),
//         const SizedBox(height: 4),
//         _saveBar(
//           label: 'Log & Open Gmail',
//           icon: Icons.email_rounded,
//           onTap: _submitEmail,
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // CALL FORM
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _callForm() {
//     return _buildSection(
//       icon: Icons.call_outlined,
//       title: 'Log Call',
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Text('CALLING',
//               style: TextStyle(
//                   color: AppColors.ctext,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: .6)),
//         ),
//         _contactInfoTile(
//           isWhatsApp: false,
//           icon: Icons.call_rounded,
//           color: AppColors.orange,
//           value: _selectedLeadPhone,
//           emptyLabel: 'Lead phone will appear here',
//         ),
//         const SizedBox(height: 4),
//         _saveBar(
//           label: 'Log & Call Now',
//           icon: Icons.call_rounded,
//           onTap: _submitCall,
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // WHATSAPP FORM
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _whatsappForm() {
//     return _buildSection(
//       icon: Icons.chat_outlined,
//       title: 'Log WhatsApp',
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Text('SENDING TO',
//               style: TextStyle(
//                   color: AppColors.ctext,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: .6)),
//         ),
//         _contactInfoTile(
//           isWhatsApp: true,
//           icon: null,
//           color: AppColors.c1,
//           value: _selectedLeadPhone,
//           emptyLabel: 'Lead phone will appear here',
//         ),
//         _field(_waMessageCtrl, 'Message (optional)', Icons.message_outlined,
//             maxLines: 3),
//         const SizedBox(height: 4),
//         _saveBar(
//           label: 'Log & Open WhatsApp',
//           icon: Icons.chat_rounded,
//           svgIcon: _kWhatsAppSvg,
//           onTap: _submitWhatsApp,
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // FOLLOW-UP FORM
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _followUpForm() {
//     return _buildSection(
//       icon: Icons.replay_rounded,
//       title: 'Schedule Follow-up',
//       children: [
//         _field(
//           _followTitleCtrl,
//           'Follow-up Title',
//           Icons.title_rounded,
//           isRequired: true,
//           hint: 'Enter follow-up title',
//           error: _errFollowTitle,
//           onChanged: (_) {
//             if (_errFollowTitle != null) setState(() => _errFollowTitle = null);
//           },
//         ),
//         _field(_followDescCtrl, 'Description (optional)', Icons.notes_rounded,
//             maxLines: 3),
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Text('DATE & TIME',
//               style: TextStyle(
//                   color: AppColors.ctext,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: .6)),
//         ),
//         _dateTimeRow(),
//         const SizedBox(height: 4),
//         _saveBar(
//           label: 'Schedule Follow-up',
//           icon: Icons.replay_rounded,
//           onTap: _submitFollowUp,
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────
//   // REMINDER FORM
//   // ─────────────────────────────────────────────────────────────────────
//   Widget _reminderForm() {
//     return _buildSection(
//       icon: Icons.notifications_outlined,
//       title: 'Set Reminder',
//       children: [
//         _field(
//           _reminderTitleCtrl,
//           'What to be reminded?',
//           Icons.notifications_rounded,
//           isRequired: true,
//           hint: 'Enter reminder title',
//           error: _errReminderTitle,
//           onChanged: (_) {
//             if (_errReminderTitle != null)
//               setState(() => _errReminderTitle = null);
//           },
//         ),
//         _field(_reminderDescCtrl, 'Additional details', Icons.notes_rounded,
//             maxLines: 3),
//         _field(_reminderSubtypeCtrl, 'Action (e.g. Phone Call, Email)',
//             Icons.category_outlined),
//         const Padding(
//           padding: EdgeInsets.only(bottom: 8),
//           child: Text('DATE & TIME',
//               style: TextStyle(
//                   color: AppColors.ctext,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: .6)),
//         ),
//         _dateTimeRow(),
//         const SizedBox(height: 4),
//         _saveBar(
//           label: 'Set Reminder',
//           icon: Icons.notifications_rounded,
//           onTap: _submitReminder,
//         ),
//       ],
//     );
//   }
// }
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_assets.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/notification/notification_service.dart';
import 'package:pokakbilling/viewmodels/activity/all_activityviewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/views/bottom_bar/bottomNavigationBar/bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

class NewActivityScreen extends StatefulWidget {
  const NewActivityScreen({super.key});
  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen>
    with SingleTickerProviderStateMixin {
  String selectedActivity = 'Meeting';

  final List<String> _activityTypes = [
    'Meeting',
    'Email',
    'Call',
    'WhatsApp',
    'Follow-up',
    'Reminder',
  ];

  // ── Selected lead ──────────────────────────────────────────────────────
  int? _selectedLeadId;
  String _selectedLeadName = '';
  String _selectedLeadCompany = '';
  String _selectedLeadStatus = '';
  String _selectedLeadPhone = '';
  String _selectedLeadEmail = '';

  // ── Date / Time ────────────────────────────────────────────────────────
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // ── Controllers ────────────────────────────────────────────────────────
  final _meetingTitleCtrl = TextEditingController();
  final _meetingDescCtrl = TextEditingController();
  final _meetingSubtypeCtrl = TextEditingController();
  final _meetingLocationCtrl = TextEditingController();
  final _emailSubjectCtrl = TextEditingController();
  final _emailMessageCtrl = TextEditingController();
  final _waMessageCtrl = TextEditingController();
  final _followTitleCtrl = TextEditingController();
  final _followDescCtrl = TextEditingController();
  final _reminderTitleCtrl = TextEditingController();
  final _reminderDescCtrl = TextEditingController();
  final _reminderSubtypeCtrl = TextEditingController();
  final _leadSearchCtrl = TextEditingController();
  String _leadSearch = '';

  // ── Manual field errors ────────────────────────────────────────────────
  String? _errLead;
  String? _errMeetingTitle;
  String? _errLocation;
  String? _errEmailSubject;
  String? _errFollowTitle;
  String? _errReminderTitle;

  // ✅ NEW: local "submitting" flag for the Call button, since the call
  // schedule-task now goes through LeadViewmodel (not AllActivityViewModel),
  // so it isn't covered by AllActivityViewModel.isSubmitting.
  bool _isSchedulingCall = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadViewmodel>(context, listen: false).getAllLeads();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _meetingTitleCtrl.dispose();
    _meetingDescCtrl.dispose();
    _meetingSubtypeCtrl.dispose();
    _meetingLocationCtrl.dispose();
    _emailSubjectCtrl.dispose();
    _emailMessageCtrl.dispose();
    _waMessageCtrl.dispose();
    _followTitleCtrl.dispose();
    _followDescCtrl.dispose();
    _reminderTitleCtrl.dispose();
    _reminderDescCtrl.dispose();
    _reminderSubtypeCtrl.dispose();
    _leadSearchCtrl.dispose();
    super.dispose();
  }

  // ── URL / location validation ──────────────────────────────────────────
  bool _isValidLocationInput(String input) {
    if (input.isEmpty) return true;
    final looksLikeUrl =
        input.contains('://') || input.toLowerCase().startsWith('www.');
    if (!looksLikeUrl) return true;
    final normalised =
        input.toLowerCase().startsWith('www.') ? 'https://$input' : input;
    final uri = Uri.tryParse(normalised);
    if (uri == null || !uri.hasAuthority) return false;
    const allowedSchemes = {
      'https',
      'http',
      'meet',
      'zoom',
      'msteams',
      'webex'
    };
    if (!allowedSchemes.contains(uri.scheme)) return false;
    if (uri.host.isEmpty || !uri.host.contains('.')) return false;
    return true;
  }

  // ── Launchers ──────────────────────────────────────────────────────────
  // NOTE: _openDialer is intentionally no longer used by the Call form —
  // the Call button now only schedules a call task via the API (see
  // _submitCall below). Kept here in case other flows still need it.
  Future<void> _openDialer(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openEmail(
      {required String to, String subject = '', String body = ''}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      },
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(
      {required String phone, String message = ''}) async {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    final encoded = Uri.encodeComponent(message);
    final url =
        'https://wa.me/$cleaned${message.isNotEmpty ? '?text=$encoded' : ''}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // ── General helpers ────────────────────────────────────────────────────
  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.red : AppColors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _notify(String type, String detail) async {
    await NotificationService.instance
        .showActivityScheduledNotification(activityType: type, detail: detail);
  }

  String get _isoDateTime {
    final date = _selectedDate ?? DateTime.now();
    final time = _selectedTime ?? TimeOfDay.now();
    return DateTime(date.year, date.month, date.day, time.hour, time.minute)
        .toUtc()
        .toIso8601String();
  }

  String get _dateLabel => _selectedDate == null
      ? 'Select Date'
      : '${_selectedDate!.day.toString().padLeft(2, '0')}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.year}';

  String get _timeLabel =>
      _selectedTime == null ? 'Select Time' : _selectedTime!.format(context);

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                  primary: AppColors.c1,
                  onPrimary: AppColors.white,
                  surface: AppColors.white)),
          child: child!),
    );
    if (p != null) setState(() => _selectedDate = p);
  }

  Future<void> _pickTime() async {
    final p = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                  primary: AppColors.c1,
                  onPrimary: AppColors.white,
                  surface: AppColors.white)),
          child: child!),
    );
    if (p != null) setState(() => _selectedTime = p);
  }

  // ══════════════════════════════════════════════════════════════════════
  // SUBMIT HANDLERS
  // ══════════════════════════════════════════════════════════════════════

  Future<void> _submitMeeting() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final titleErr = _meetingTitleCtrl.text.trim().isEmpty
        ? 'Meeting title is required'
        : null;
    final locationErr = !_isValidLocationInput(_meetingLocationCtrl.text.trim())
        ? 'Enter a valid URL (e.g. https://meet.google.com/abc-xyz)'
        : null;

    setState(() {
      _errLead = leadErr;
      _errMeetingTitle = titleErr;
      _errLocation = locationErr;
    });

    if (leadErr != null || titleErr != null || locationErr != null) return;

    final vm = Provider.of<AllActivityViewModel>(context, listen: false);
    final ok = await vm.scheduleMeeting(
      leadId: _selectedLeadId!,
      title: _meetingTitleCtrl.text.trim(),
      description: _meetingDescCtrl.text.trim(),
      subtype: _meetingSubtypeCtrl.text.trim(),
      location: _meetingLocationCtrl.text.trim(),
      dueDate: _isoDateTime,
    );
    if (ok) {
      await _notify('Meeting',
          'Meeting "${_meetingTitleCtrl.text.trim()}" has been scheduled');
      _snack('📅 Meeting scheduled!');
      if (mounted) Navigator.pop(context);
    } else {
      _snack(vm.submitError ?? 'Failed to schedule meeting', isError: true);
    }
  }

  Future<void> _submitEmail() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final emailErr = _selectedLeadEmail.isEmpty
        ? 'No email found for the selected lead'
        : null;
    final subjectErr = _emailSubjectCtrl.text.trim().isEmpty
        ? 'Email subject is required'
        : null;

    setState(() {
      _errLead = leadErr;
      _errEmailSubject = subjectErr;
    });

    if (leadErr != null || emailErr != null || subjectErr != null) {
      if (emailErr != null) _snack(emailErr, isError: true);
      return;
    }

    final vm = Provider.of<AllActivityViewModel>(context, listen: false);
    final ok = await vm.logEmail(
      leadId: _selectedLeadId!,
      email: _selectedLeadEmail,
      subject: _emailSubjectCtrl.text.trim(),
      message: _emailMessageCtrl.text.trim(),
    );
    if (ok) {
      await _notify('Email', 'Email to $_selectedLeadEmail logged');
      _snack('✉️ Email logged!');
      await _openEmail(
        to: _selectedLeadEmail,
        subject: _emailSubjectCtrl.text.trim(),
        body: _emailMessageCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } else {
      _snack(vm.submitError ?? 'Failed to log email', isError: true);
    }
  }

  // ✅ CHANGED: Call now just schedules a call task via
  // LeadViewmodel.scheduleCall (POST /call-activities/schedule-task/ with
  // {lead_id}) — it no longer calls AllActivityViewModel.logCall and no
  // longer opens the phone dialer. Success/error toast is shown by
  // LeadViewmodel.scheduleCall itself ("Call Scheduled" / server error).
  Future<void> _submitCall() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;

    setState(() => _errLead = leadErr);

    if (leadErr != null) return;

    setState(() => _isSchedulingCall = true);

    final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
    final ok = await leadVm.scheduleCall(_selectedLeadId!, context);

    if (!mounted) return;
    setState(() => _isSchedulingCall = false);

    if (ok) {
      await _notify('Call',
          'Call scheduled for $_selectedLeadName ($_selectedLeadPhone)');
      if (mounted) Navigator.pop(context);
    }
    // On failure, LeadViewmodel.scheduleCall already surfaced the error
    // via showOverlayError, so nothing else to do here.
  }

  Future<void> _submitWhatsApp() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final phoneErr = _selectedLeadPhone.isEmpty
        ? 'No phone number found for the selected lead'
        : null;

    setState(() => _errLead = leadErr);

    if (leadErr != null || phoneErr != null) {
      if (phoneErr != null) _snack(phoneErr, isError: true);
      return;
    }

    final vm = Provider.of<AllActivityViewModel>(context, listen: false);
    final ok = await vm.logWhatsApp(
      leadId: _selectedLeadId!,
      phoneNumber: _selectedLeadPhone,
      message: _waMessageCtrl.text.trim(),
    );
    if (ok) {
      await _notify('WhatsApp', 'WhatsApp to $_selectedLeadPhone logged');
      _snack('WhatsApp logged!');
      await _openWhatsApp(
        phone: _selectedLeadPhone,
        message: _waMessageCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } else {
      _snack(vm.submitError ?? 'Failed to log WhatsApp', isError: true);
    }
  }

  Future<void> _submitFollowUp() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final titleErr = _followTitleCtrl.text.trim().isEmpty
        ? 'Follow-up title is required'
        : null;

    setState(() {
      _errLead = leadErr;
      _errFollowTitle = titleErr;
    });

    if (leadErr != null || titleErr != null) return;

    final vm = Provider.of<AllActivityViewModel>(context, listen: false);
    final ok = await vm.scheduleFollowUp(
      leadId: _selectedLeadId!,
      title: _followTitleCtrl.text.trim(),
      description: _followDescCtrl.text.trim(),
      dueDate: _isoDateTime,
    );
    if (ok) {
      await _notify('Follow-up',
          'Follow-up "${_followTitleCtrl.text.trim()}" has been scheduled');
      _snack('🔁 Follow-up scheduled!');
      if (mounted) Navigator.pop(context);
    } else {
      _snack(vm.submitError ?? 'Failed to schedule follow-up', isError: true);
    }
  }

  Future<void> _submitReminder() async {
    final leadErr =
        _selectedLeadId == null ? 'Please choose a lead first' : null;
    final titleErr = _reminderTitleCtrl.text.trim().isEmpty
        ? 'Reminder title is required'
        : null;

    setState(() {
      _errLead = leadErr;
      _errReminderTitle = titleErr;
    });

    if (leadErr != null || titleErr != null) return;

    final vm = Provider.of<AllActivityViewModel>(context, listen: false);
    final ok = await vm.setReminder(
      leadId: _selectedLeadId!,
      title: _reminderTitleCtrl.text.trim(),
      description: _reminderDescCtrl.text.trim(),
      subtype: _reminderSubtypeCtrl.text.trim(),
      dueDate: _isoDateTime,
    );
    if (ok) {
      await _notify('Reminder',
          'Reminder "${_reminderTitleCtrl.text.trim()}" has been set');
      _snack('🔔 Reminder set!');
      if (mounted) Navigator.pop(context);
    } else {
      _snack(vm.submitError ?? 'Failed to set reminder', isError: true);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // LEAD SHEET
  // ══════════════════════════════════════════════════════════════════════
  void _openLeadSheet() {
    _leadSearch = '';
    _leadSearchCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Consumer<LeadViewmodel>(builder: (_, lvm, __) {
          final q = _leadSearch.toLowerCase();
          final leads = q.isEmpty
              ? lvm.leadList
              : lvm.leadList.where((l) {
                  return (l.name ?? '').toLowerCase().contains(q) ||
                      (l.company ?? '').toLowerCase().contains(q) ||
                      (l.phone ?? '').toLowerCase().contains(q);
                }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * .75,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.c1.withOpacity(.18),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.person_search_rounded,
                        color: AppColors.c1, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Choose a Lead',
                        style: TextStyle(
                            color: AppColors.cdark,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                  if (lvm.getLeadLoader)
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.c1, strokeWidth: 2)),
                ]),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cxl,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.c1.withOpacity(.25)),
                  ),
                  child: Row(children: [
                    Icon(Icons.search_rounded,
                        size: 16, color: AppColors.ctext.withOpacity(.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _leadSearchCtrl,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                            color: AppColors.cdark, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search by name, company…',
                          hintStyle: TextStyle(
                              color: AppColors.ctext.withOpacity(.45),
                              fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) => setSheet(() => _leadSearch = v),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.cborder, height: 1),
              Expanded(
                child: leads.isEmpty
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.inbox_rounded,
                            size: 44, color: AppColors.ctext.withOpacity(.25)),
                        const SizedBox(height: 10),
                        Text(
                            lvm.getLeadLoader
                                ? 'Loading leads…'
                                : 'No leads found',
                            style: TextStyle(
                                color: AppColors.ctext.withOpacity(.45),
                                fontSize: 13)),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        itemCount: leads.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: AppColors.cborder, height: 1),
                        itemBuilder: (_, i) => _leadTile(leads[i], sheetCtx),
                      ),
              ),
              const SizedBox(height: 12),
            ]),
          );
        });
      }),
    );
  }

  Widget _leadTile(LeadModel lead, BuildContext sheetCtx) {
    final initials =
        (lead.name?.isNotEmpty == true) ? lead.name![0].toUpperCase() : 'L';
    final isSelected = _selectedLeadId == lead.id;

    Color statusColor;
    switch ((lead.status ?? '').toUpperCase()) {
      case 'CONVERTED':
        statusColor = AppColors.green;
        break;
      case 'LOST':
        statusColor = AppColors.red;
        break;
      case 'NEW':
        statusColor = AppColors.c1;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLeadId = lead.id;
          _selectedLeadName = lead.name ?? '';
          _selectedLeadCompany = lead.company ?? '';
          _selectedLeadStatus = lead.status ?? '';
          _selectedLeadPhone = lead.phone ?? '';
          _selectedLeadEmail = lead.email ?? '';
          if (_errLead != null) _errLead = null;
        });
        Navigator.pop(sheetCtx);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.c1.withOpacity(.10) : AppColors.cxl,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected
                  ? AppColors.c1.withOpacity(.40)
                  : AppColors.cborder,
              width: 1.2),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(.20),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: AppColors.cdark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lead.name ?? 'Unknown',
                  style: const TextStyle(
                      color: AppColors.cdark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if ((lead.company ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(lead.company!,
                    style: TextStyle(
                        color: AppColors.ctext.withOpacity(.55), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
              if ((lead.phone ?? '').isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.call_rounded,
                      size: 10, color: AppColors.orange.withOpacity(.7)),
                  const SizedBox(width: 3),
                  Text(lead.phone!,
                      style: TextStyle(
                          color: AppColors.ctext.withOpacity(.50),
                          fontSize: 10)),
                ]),
              ],
              if ((lead.email ?? '').isNotEmpty) ...[
                const SizedBox(height: 1),
                Row(children: [
                  Icon(Icons.email_rounded,
                      size: 10, color: AppColors.blue.withOpacity(.7)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(lead.email!,
                        style: TextStyle(
                            color: AppColors.ctext.withOpacity(.50),
                            fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
            ]),
          ),
          if ((lead.status ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: statusColor.withOpacity(.35), width: .8)),
              child: Text(lead.status!,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          const SizedBox(width: 8),
          if (isSelected)
            Icon(Icons.check_circle_rounded, color: AppColors.c1, size: 18),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(children: [
          _buildHeader(context, sw, top),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeSection(),
                        const SizedBox(height: 14),
                        _buildLeadSection(),
                        const SizedBox(height: 14),
                        _buildDynamicForm(),
                      ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double top) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: top + 12, bottom: 28, left: sw * .03, right: sw * .04),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => pushNavigation(context, const BottomBar(index: 0)),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: Image.asset(AppAssets.homeIcon,
                width: 16, height: 16, color: AppColors.c1),
          ),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('New Organizer Task',
              style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const Text('Schedule & log tasks',
              style: TextStyle(color: AppColors.ctext, fontSize: 12)),
        ]),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SECTION CARD
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cborder),
            ),
            child: Icon(icon, color: AppColors.c1, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark)),
          ),
          if (trailing != null) trailing,
        ]),
        const Divider(height: 20, thickness: 1, color: AppColors.cborder),
        ...children,
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TEXT FIELD  — hint text turns red when there is an error and field is empty
  // ─────────────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? error,
    void Function(String)? onChanged,
    String? hint,
  }) {
    final hasError = error != null && error.isNotEmpty;
    // Show red hint only when there is an error AND the field is still empty
    final showRedHint = hasError && controller.text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            cursorColor: AppColors.c1,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.cdark),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 13,
                color: showRedHint
                    ? AppColors.red
                    : AppColors.ctext.withOpacity(0.75),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 12,
                color: showRedHint
                    ? AppColors.red
                    : AppColors.ctext.withOpacity(0.45),
              ),
              prefixIcon: Icon(icon,
                  size: 18, color: hasError ? AppColors.red : AppColors.c1),
              suffixIcon: isRequired
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.circle, size: 6, color: AppColors.red),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
              filled: true,
              fillColor:
                  hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError
                        ? AppColors.red.withOpacity(0.60)
                        : AppColors.cborder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError
                        ? AppColors.red.withOpacity(0.60)
                        : AppColors.cborder),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 13, color: AppColors.red),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(error,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.red,
                            height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // READ-ONLY CONTACT INFO TILE
  // ─────────────────────────────────────────────────────────────────────
  Widget _contactInfoTile({
    required bool isWhatsApp,
    required IconData? icon,
    required Color color,
    required String value,
    required String emptyLabel,
  }) {
    final hasValue = value.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cxl,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color:
                  hasValue ? AppColors.c1.withOpacity(.35) : AppColors.cborder),
        ),
        child: Row(children: [
          if (isWhatsApp)
            SvgPicture.string(
              _kWhatsAppSvg,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                  hasValue ? AppColors.c1 : AppColors.ctext.withOpacity(.30),
                  BlendMode.srcIn),
            )
          else
            Icon(icon,
                size: 18,
                color: hasValue ? color : AppColors.ctext.withOpacity(.30)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasValue ? value : emptyLabel,
              style: TextStyle(
                  fontSize: 14,
                  color: hasValue
                      ? AppColors.cdark
                      : AppColors.ctext.withOpacity(0.55),
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!hasValue)
            Text('Select lead first',
                style: TextStyle(
                    color: AppColors.ctext.withOpacity(.40), fontSize: 11)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // DATE / TIME ROW
  // ─────────────────────────────────────────────────────────────────────
  Widget _dateTimeRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(
            child: GestureDetector(
                onTap: _pickDate,
                child: _pickerTile(
                    icon: Icons.calendar_today_rounded, label: _dateLabel))),
        const SizedBox(width: 10),
        Expanded(
            child: GestureDetector(
                onTap: _pickTime,
                child: _pickerTile(
                    icon: Icons.access_time_rounded, label: _timeLabel))),
      ]),
    );
  }

  Widget _pickerTile({required IconData icon, required String label}) {
    final isEmpty = label.startsWith('Select');
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cxl,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cborder),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.c1),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    color: isEmpty
                        ? AppColors.ctext.withOpacity(0.75)
                        : AppColors.cdark),
                overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SAVE / SUBMIT BUTTON  (activities that go through AllActivityViewModel)
  // ─────────────────────────────────────────────────────────────────────
  Widget _saveBar({
    required String label,
    required IconData icon,
    String? svgIcon,
    required VoidCallback onTap,
  }) {
    return Consumer<AllActivityViewModel>(
      builder: (_, vm, __) => SizedBox(
        width: double.infinity,
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.c1,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: vm.isSubmitting ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
            ),
            child: vm.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (svgIcon != null)
                        SvgPicture.string(svgIcon,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn))
                      else
                        Icon(icon, color: AppColors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(label,
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // ✅ NEW: SAVE / SUBMIT BUTTON for Call — driven by LeadViewmodel's own
  // scheduleCallLoading flag instead of AllActivityViewModel.isSubmitting,
  // since scheduling a call no longer goes through AllActivityViewModel.
  // ─────────────────────────────────────────────────────────────────────
  Widget _callSaveBar({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Consumer<LeadViewmodel>(
      builder: (_, vm, __) {
        final busy = vm.scheduleCallLoading || _isSchedulingCall;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.c1.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: busy ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: AppColors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(label,
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8)),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TYPE SELECTOR SECTION
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildTypeSection() {
    return _buildSection(
      icon: Icons.category_outlined,
      title: 'Task Type',
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _activityTypes.map((type) {
              final active = selectedActivity == type;
              final isWA = type == 'WhatsApp';
              return GestureDetector(
                onTap: () => setState(() {
                  selectedActivity = type;
                  _selectedDate = null;
                  _selectedTime = null;
                  _errMeetingTitle = null;
                  _errLocation = null;
                  _errEmailSubject = null;
                  _errFollowTitle = null;
                  _errReminderTitle = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        active ? AppColors.c1 : AppColors.c1.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: active
                            ? AppColors.c1
                            : AppColors.c1.withOpacity(.22)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isWA) ...[
                      SvgPicture.string(
                        _kWhatsAppSvg,
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                            active ? AppColors.white : AppColors.c1,
                            BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(type,
                        style: TextStyle(
                            color: active ? AppColors.white : AppColors.c1,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12)),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // LEAD SELECTOR SECTION
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildLeadSection() {
    final hasLeadError = _errLead != null && _errLead!.isNotEmpty;

    return _buildSection(
      icon: Icons.person_search_rounded,
      title: 'Lead',
      trailing: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Icon(Icons.circle, size: 6, color: AppColors.red),
      ),
      children: [
        _selectedLeadId != null
            ? _selectedLeadCard()
            : _leadEmptyPicker(hasLeadError),
        if (hasLeadError)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 13, color: AppColors.red),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(_errLead!,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.red,
                          height: 1.4)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _selectedLeadCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.c1.withOpacity(.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.c1.withOpacity(.25), width: 1.2),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.c1.withOpacity(.20),
            shape: BoxShape.circle,
          ),
          child: Center(
              child: Text(
                  _selectedLeadName.isNotEmpty
                      ? _selectedLeadName[0].toUpperCase()
                      : 'L',
                  style: const TextStyle(
                      color: AppColors.cdark,
                      fontWeight: FontWeight.w800,
                      fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedLeadName,
                style: const TextStyle(
                    color: AppColors.cdark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            if (_selectedLeadCompany.isNotEmpty)
              Text(_selectedLeadCompany,
                  style: TextStyle(
                      color: AppColors.ctext.withOpacity(.55), fontSize: 11)),
            if (_selectedLeadPhone.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(children: [
                Icon(Icons.call_rounded,
                    size: 11, color: AppColors.orange.withOpacity(.8)),
                const SizedBox(width: 4),
                Text(_selectedLeadPhone,
                    style: TextStyle(
                        color: AppColors.ctext.withOpacity(.65), fontSize: 11)),
              ]),
            ],
            if (_selectedLeadEmail.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.email_rounded,
                    size: 11, color: AppColors.blue.withOpacity(.8)),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(_selectedLeadEmail,
                        style: TextStyle(
                            color: AppColors.ctext.withOpacity(.65),
                            fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ],
          ]),
        ),
        if (_selectedLeadStatus.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.c1.withOpacity(.35), width: .8)),
            child: Text(_selectedLeadStatus,
                style: const TextStyle(
                    color: AppColors.c1,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _openLeadSheet,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(.12), shape: BoxShape.circle),
            child:
                const Icon(Icons.edit_rounded, color: AppColors.c1, size: 14),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => setState(() {
            _selectedLeadId = null;
            _selectedLeadName = '';
            _selectedLeadCompany = '';
            _selectedLeadStatus = '';
            _selectedLeadPhone = '';
            _selectedLeadEmail = '';
          }),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: AppColors.red.withOpacity(.12), shape: BoxShape.circle),
            child:
                const Icon(Icons.close_rounded, color: AppColors.red, size: 14),
          ),
        ),
      ]),
    );
  }

  Widget _leadEmptyPicker(bool hasError) {
    return GestureDetector(
      onTap: _openLeadSheet,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [6, 4],
        color: hasError
            ? AppColors.red.withOpacity(.60)
            : AppColors.c1.withOpacity(.45),
        strokeWidth: 1.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: hasError
                  ? AppColors.red.withOpacity(.04)
                  : AppColors.c1.withOpacity(.03),
              borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.person_add_alt_1_rounded,
                color: hasError ? AppColors.red : AppColors.c1, size: 18),
            const SizedBox(width: 8),
            Text('Choose a Lead',
                style: TextStyle(
                    // ← hint text also red on error, matching the dotted border
                    color: hasError ? AppColors.red : AppColors.cdark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // DYNAMIC FORM ROUTER
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildDynamicForm() {
    switch (selectedActivity) {
      case 'Meeting':
        return _meetingForm();
      case 'Email':
        return _emailForm();
      case 'Call':
        return _callForm();
      case 'WhatsApp':
        return _whatsappForm();
      case 'Follow-up':
        return _followUpForm();
      case 'Reminder':
        return _reminderForm();
      default:
        return const SizedBox();
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // MEETING FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _meetingForm() {
    return _buildSection(
      icon: Icons.videocam_outlined,
      title: 'Schedule Meeting',
      children: [
        _field(
          _meetingTitleCtrl,
          'Meeting Title',
          Icons.title_rounded,
          isRequired: true,
          hint: 'Enter meeting title',
          error: _errMeetingTitle,
          onChanged: (_) {
            if (_errMeetingTitle != null)
              setState(() => _errMeetingTitle = null);
          },
        ),
        _field(_meetingDescCtrl, 'Description', Icons.notes_rounded,
            maxLines: 3),
        _field(_meetingSubtypeCtrl, 'Meet type (e.g. Video Call)',
            Icons.category_outlined),
        _field(
          _meetingLocationCtrl,
          'Address or video call link',
          Icons.link_rounded,
          hint: 'Enter address or link',
          error: _errLocation,
          onChanged: (_) {
            if (_errLocation != null) setState(() => _errLocation = null);
          },
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('DATE & TIME',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6)),
        ),
        _dateTimeRow(),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Schedule Meeting',
          icon: Icons.videocam_rounded,
          onTap: _submitMeeting,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // EMAIL FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _emailForm() {
    return _buildSection(
      icon: Icons.email_outlined,
      title: 'Log Email',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('TO',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6)),
        ),
        _contactInfoTile(
          isWhatsApp: false,
          icon: Icons.email_rounded,
          color: AppColors.blue,
          value: _selectedLeadEmail,
          emptyLabel: 'Lead email will appear here',
        ),
        _field(
          _emailSubjectCtrl,
          'Subject',
          Icons.subject_rounded,
          isRequired: true,
          hint: 'Enter email subject',
          error: _errEmailSubject,
          onChanged: (_) {
            if (_errEmailSubject != null)
              setState(() => _errEmailSubject = null);
          },
        ),
        _field(_emailMessageCtrl, 'Message', Icons.message_outlined,
            maxLines: 4),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Log & Open Gmail',
          icon: Icons.email_rounded,
          onTap: _submitEmail,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // CALL FORM
  // ✅ CHANGED: no longer shows/opens the dialer. Just shows the lead's
  // phone (read-only, for reference) and a button that hits the
  // schedule-task API via LeadViewmodel.scheduleCall.
  // ─────────────────────────────────────────────────────────────────────
  Widget _callForm() {
    return _buildSection(
      icon: Icons.call_outlined,
      title: 'Schedule Call',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('CALLING',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6)),
        ),
        _contactInfoTile(
          isWhatsApp: false,
          icon: Icons.call_rounded,
          color: AppColors.orange,
          value: _selectedLeadPhone,
          emptyLabel: 'Lead phone will appear here',
        ),
        const SizedBox(height: 4),
        _callSaveBar(
          label: 'Schedule Call',
          icon: Icons.call_rounded,
          onTap: _submitCall,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // WHATSAPP FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _whatsappForm() {
    return _buildSection(
      icon: Icons.chat_outlined,
      title: 'Log WhatsApp',
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('SENDING TO',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6)),
        ),
        _contactInfoTile(
          isWhatsApp: true,
          icon: null,
          color: AppColors.c1,
          value: _selectedLeadPhone,
          emptyLabel: 'Lead phone will appear here',
        ),
        _field(_waMessageCtrl, 'Message (optional)', Icons.message_outlined,
            maxLines: 3),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Log & Open WhatsApp',
          icon: Icons.chat_rounded,
          svgIcon: _kWhatsAppSvg,
          onTap: _submitWhatsApp,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // FOLLOW-UP FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _followUpForm() {
    return _buildSection(
      icon: Icons.replay_rounded,
      title: 'Schedule Follow-up',
      children: [
        _field(
          _followTitleCtrl,
          'Follow-up Title',
          Icons.title_rounded,
          isRequired: true,
          hint: 'Enter follow-up title',
          error: _errFollowTitle,
          onChanged: (_) {
            if (_errFollowTitle != null) setState(() => _errFollowTitle = null);
          },
        ),
        _field(_followDescCtrl, 'Description (optional)', Icons.notes_rounded,
            maxLines: 3),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('DATE & TIME',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6)),
        ),
        _dateTimeRow(),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Schedule Follow-up',
          icon: Icons.replay_rounded,
          onTap: _submitFollowUp,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // REMINDER FORM
  // ─────────────────────────────────────────────────────────────────────
  Widget _reminderForm() {
    return _buildSection(
      icon: Icons.notifications_outlined,
      title: 'Set Reminder',
      children: [
        _field(
          _reminderTitleCtrl,
          'What to be reminded?',
          Icons.notifications_rounded,
          isRequired: true,
          hint: 'Enter reminder title',
          error: _errReminderTitle,
          onChanged: (_) {
            if (_errReminderTitle != null)
              setState(() => _errReminderTitle = null);
          },
        ),
        _field(_reminderDescCtrl, 'Additional details', Icons.notes_rounded,
            maxLines: 3),
        _field(_reminderSubtypeCtrl, 'Action (e.g. Phone Call, Email)',
            Icons.category_outlined),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('DATE & TIME',
              style: TextStyle(
                  color: AppColors.ctext,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .6)),
        ),
        _dateTimeRow(),
        const SizedBox(height: 4),
        _saveBar(
          label: 'Set Reminder',
          icon: Icons.notifications_rounded,
          onTap: _submitReminder,
        ),
      ],
    );
  }
}
