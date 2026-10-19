// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/lead_model.dart';
// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
// import 'package:pokakbilling/notification/notification_service.dart';

// class AddFollowUp extends StatefulWidget {
//   final int? leadId;
//   final String? prefillTitle;

//   const AddFollowUp({super.key, this.leadId, this.prefillTitle});

//   @override
//   State<AddFollowUp> createState() => _AddFollowUpState();
// }

// class _AddFollowUpState extends State<AddFollowUp>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _animCtrl;
//   late final Animation<double> _fadeAnim;
//   late final Animation<Offset> _slideAnim;

//   LeadModel? _selectedLead;

//   final TextEditingController _titleCtrl = TextEditingController();
//   final TextEditingController _descCtrl = TextEditingController();
//   final TextEditingController _locationCtrl = TextEditingController();

//   String _activityType = 'FOLLOW_UP';
//   String _status = 'PENDING';
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   bool _submitting = false;

//   // ── Manual field errors (only set on button click) ────────────────────────
//   String? _errLead;
//   String? _errTitle;
//   String? _errDate;
//   String? _errTime;

//   static const _activityTypes = [
//     _DropOption('FOLLOW_UP', 'Follow-up', Icons.repeat_rounded),
//     _DropOption('CALL', 'Phone Call', Icons.call_rounded),
//     _DropOption('MEETING', 'Meeting', Icons.event_rounded),
//     _DropOption('EMAIL', 'Email', Icons.email_rounded),
//     _DropOption('WHATSAPP', 'WhatsApp', Icons.message_rounded),
//   ];

//   static const _statusTypes = [
//     _DropOption('PENDING', 'Pending', Icons.hourglass_empty_rounded),
//     _DropOption('COMPLETED', 'Completed', Icons.check_circle_rounded),
//     _DropOption('CANCELLED', 'Cancelled', Icons.cancel_rounded),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 550));
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
//     _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
//     _animCtrl.forward();

//     if (widget.prefillTitle != null) {
//       _titleCtrl.text = widget.prefillTitle!;
//     }
//   }

//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     _locationCtrl.dispose();
//     super.dispose();
//   }

//   int _getLeadId(LeadModel lead) {
//     if (lead.id > 0) return lead.id;
//     return int.tryParse(lead.leadId) ?? 0;
//   }

//   String _formatDate(DateTime d) =>
//       '${d.day.toString().padLeft(2, '0')} ${_monthAbbr(d.month)} ${d.year}';

//   String _formatTime(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

//   String _monthAbbr(int m) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     return months[m - 1];
//   }

//   String get _activityLabel =>
//       _activityTypes.firstWhere((t) => t.value == _activityType).label;

//   String get _statusLabel =>
//       _statusTypes.firstWhere((t) => t.value == _status).label;

//   // ── Lead selector sheet ───────────────────────────────────────────────────
//   Future<void> _openSelectLeadSheet() async {
//     final vm = Provider.of<LeadViewmodel>(context, listen: false);

//     final lead = await showModalBottomSheet<LeadModel>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: AppColors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: DraggableScrollableSheet(
//             expand: false,
//             initialChildSize: 0.70,
//             minChildSize: 0.40,
//             maxChildSize: 0.95,
//             builder: (_, controller) {
//               return Column(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 4,
//                     margin: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: AppColors.c1.withOpacity(0.20),
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 32,
//                           height: 32,
//                           decoration: BoxDecoration(
//                             color: AppColors.cxl,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: AppColors.cborder),
//                           ),
//                           child: Icon(Icons.person_search_rounded,
//                               color: AppColors.c1, size: 16),
//                         ),
//                         const SizedBox(width: 10),
//                         const Text(
//                           'Select Lead',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: AppColors.cdark,
//                           ),
//                         ),
//                         const Spacer(),
//                         IconButton(
//                           onPressed: () => Navigator.of(ctx).pop(),
//                           icon: Icon(Icons.close_rounded,
//                               color: AppColors.ctext.withOpacity(0.55)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(height: 1, color: AppColors.cborder),
//                   const SizedBox(height: 6),
//                   Expanded(
//                     child: ListView.separated(
//                       controller: controller,
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                       itemCount: vm.leadList.length,
//                       separatorBuilder: (_, __) =>
//                           const Divider(height: 1, color: AppColors.cborder),
//                       itemBuilder: (_, i) {
//                         final l = vm.leadList[i];
//                         final isSelected = _selectedLead?.id == l.id;
//                         return ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 4, vertical: 4),
//                           leading: Container(
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? AppColors.c1.withOpacity(0.15)
//                                   : AppColors.cxl,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 l.name.isNotEmpty
//                                     ? l.name[0].toUpperCase()
//                                     : 'L',
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w800,
//                                   color: isSelected
//                                       ? AppColors.c1
//                                       : AppColors.cdark,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           title: Text(
//                             l.name,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color:
//                                   isSelected ? AppColors.c1 : AppColors.cdark,
//                             ),
//                           ),
//                           subtitle: Text(
//                             l.email.isNotEmpty ? l.email : l.phone,
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: AppColors.ctext.withOpacity(0.55),
//                             ),
//                           ),
//                           trailing: isSelected
//                               ? Container(
//                                   width: 24,
//                                   height: 24,
//                                   decoration: BoxDecoration(
//                                     color: AppColors.c1.withOpacity(0.12),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(Icons.check_rounded,
//                                       color: AppColors.c1, size: 14),
//                                 )
//                               : null,
//                           onTap: () => Navigator.of(ctx).pop(l),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );

//     if (lead != null) {
//       setState(() {
//         _selectedLead = lead;
//         if (_errLead != null) _errLead = null;
//       });
//     }
//   }

//   // ── Date / Time pickers ───────────────────────────────────────────────────
//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: ColorScheme.light(
//             primary: AppColors.c1,
//             onPrimary: AppColors.white,
//             surface: AppColors.white,
//             onSurface: AppColors.cdark,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         if (_errDate != null) _errDate = null;
//       });
//     }
//   }

//   Future<void> _pickTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: ColorScheme.light(
//             primary: AppColors.c1,
//             onPrimary: AppColors.white,
//             surface: AppColors.white,
//             onSurface: AppColors.cdark,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedTime = picked;
//         if (_errTime != null) _errTime = null;
//       });
//     }
//   }

//   // ── Submit — validate everything manually on click only ───────────────────
//   Future<void> _handleSubmit() async {
//     // Compute all errors
//     final leadErr = _selectedLead == null ? 'Please select a lead' : null;
//     final titleErr =
//         _titleCtrl.text.trim().isEmpty ? 'Follow-up title is required' : null;
//     final dateErr = _selectedDate == null ? 'Please choose a date' : null;
//     final timeErr = _selectedTime == null ? 'Please choose a time' : null;

//     // Set all errors in one setState
//     setState(() {
//       _errLead = leadErr;
//       _errTitle = titleErr;
//       _errDate = dateErr;
//       _errTime = timeErr;
//     });

//     // Stop if any error exists
//     if (leadErr != null ||
//         titleErr != null ||
//         dateErr != null ||
//         timeErr != null) return;

//     // Validate lead id
//     final leadId = _getLeadId(_selectedLead!);
//     if (leadId == 0) {
//       setState(() => _errLead = 'Invalid lead selected');
//       return;
//     }

//     FocusScope.of(context).unfocus();
//     setState(() => _submitting = true);

//     try {
//       final followupVm = Provider.of<FollowupViewmodel>(context, listen: false);

//       final dateStr =
//           '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
//       final timeStr =
//           '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

//       final success = await followupVm.createFollowup(
//         lead: leadId,
//         title: _titleCtrl.text.trim(),
//         description:
//             _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
//         date: dateStr,
//         time: timeStr,
//         status: _status,
//         activityType: _activityType,
//         location: _locationCtrl.text.trim().isNotEmpty
//             ? _locationCtrl.text.trim()
//             : null,
//       );

//       if (!mounted) return;
//       setState(() => _submitting = false);

//       if (success) {
//         final followupDateTime = DateTime(
//           _selectedDate!.year,
//           _selectedDate!.month,
//           _selectedDate!.day,
//           _selectedTime!.hour,
//           _selectedTime!.minute,
//         );

//         await NotificationService.instance.showMeetingCreatedNotification(
//           title: _titleCtrl.text.trim(),
//           meetingType: _activityLabel,
//           dateText: _formatDate(_selectedDate!),
//           timeText: _formatTime(_selectedTime!),
//           leadName: _selectedLead!.name,
//         );

//         await NotificationService.instance.scheduleMeetingReminder(
//           meetingId: followupDateTime.millisecondsSinceEpoch ~/ 1000,
//           title: _titleCtrl.text.trim(),
//           leadName: _selectedLead!.name,
//           meetingType: _activityLabel,
//           meetingDateTime: followupDateTime,
//         );

//         if (!mounted) return;
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _submitting = false);
//       }
//     }
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final topPad = MediaQuery.of(context).padding.top;

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: SizedBox(
//         width: double.infinity,
//         height: double.infinity,
//         child: Column(
//           children: [
//             _buildHeader(context, sw, topPad),
//             Expanded(
//               child: FadeTransition(
//                 opacity: _fadeAnim,
//                 child: SlideTransition(
//                   position: _slideAnim,
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//                     child: Column(
//                       children: [
//                         // ── Select Lead section ───────────────────────────
//                         _buildSection(
//                           icon: Icons.person_outline_rounded,
//                           title: 'Select Lead',
//                           children: [_buildLeadSelector()],
//                         ),
//                         const SizedBox(height: 14),
//                         // ── Follow-up Details section ─────────────────────
//                         _buildSection(
//                           icon: Icons.event_note_rounded,
//                           title: 'Follow-up Details',
//                           children: [
//                             _field(
//                               _titleCtrl,
//                               'Follow-up Title',
//                               Icons.title_rounded,
//                               isRequired: true,
//                               error: _errTitle,
//                               onChanged: (_) {
//                                 if (_errTitle != null)
//                                   setState(() => _errTitle = null);
//                               },
//                             ),
//                             _buildActivityTypeDropdown(),
//                             _buildStatusDropdown(),
//                             _field(
//                               _descCtrl,
//                               'Description / Notes',
//                               Icons.notes_rounded,
//                               hint: 'Any additional notes',
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 14),
//                         // ── Schedule section ──────────────────────────────
//                         _buildSection(
//                           icon: Icons.schedule_rounded,
//                           title: 'Schedule',
//                           children: [
//                             _pickerField(
//                               icon: Icons.calendar_today_rounded,
//                               label: 'Date',
//                               value: _selectedDate != null
//                                   ? _formatDate(_selectedDate!)
//                                   : null,
//                               placeholder: 'Pick a date',
//                               onTap: _pickDate,
//                               isSet: _selectedDate != null,
//                               error: _errDate,
//                             ),
//                             _pickerField(
//                               icon: Icons.access_time_rounded,
//                               label: 'Time',
//                               value: _selectedTime != null
//                                   ? _formatTime(_selectedTime!)
//                                   : null,
//                               placeholder: 'Pick a time',
//                               onTap: _pickTime,
//                               isSet: _selectedTime != null,
//                               error: _errTime,
//                             ),
//                             _field(
//                               _locationCtrl,
//                               'Location',
//                               Icons.location_on_outlined,
//                               hint: 'Optional',
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         _buildSaveBar(),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Header — matches CreateNewCustomer exactly ────────────────────────────
//   Widget _buildHeader(BuildContext context, double sw, double topPad) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         top: topPad + 12,
//         bottom: 28,
//         left: sw * 0.03,
//         right: sw * 0.04,
//       ),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom: BorderSide(color: AppColors.cborder, width: 1.5),
//         ),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: AppColors.c3,
//                 size: 15,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Add Follow-up',
//                 style: TextStyle(
//                   color: AppColors.cdark,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               Text(
//                 'Schedule a follow-up activity',
//                 style: TextStyle(
//                   color: AppColors.ctext.withOpacity(0.65),
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Section card — matches CreateNewCustomer exactly ─────────────────────
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: AppColors.cxl,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.cborder),
//                 ),
//                 child: Icon(icon, color: AppColors.c1, size: 16),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.cdark,
//                   ),
//                 ),
//               ),
//               if (trailing != null) trailing,
//             ],
//           ),
//           const Divider(height: 20, thickness: 1, color: AppColors.cborder),
//           ...children,
//         ],
//       ),
//     );
//   }

//   // ── Text field — identical to CreateNewCustomer._field ───────────────────
//   Widget _field(
//     TextEditingController controller,
//     String label,
//     IconData icon, {
//     bool isRequired = false,
//     String? hint,
//     TextInputType? keyboardType,
//     String? error,
//     void Function(String)? onChanged,
//   }) {
//     final hasError = error != null && error.isNotEmpty;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             cursorColor: AppColors.c1,
//             onChanged: onChanged,
//             style: const TextStyle(fontSize: 14, color: AppColors.cdark),
//             decoration: InputDecoration(
//               labelText: label,
//               hintText: hint,
//               hintStyle: TextStyle(
//                 fontSize: 13,
//                 color: AppColors.ctext.withOpacity(0.40),
//               ),
//               labelStyle: TextStyle(
//                 fontSize: 13,
//                 color: AppColors.ctext.withOpacity(0.75),
//               ),
//               prefixIcon: Icon(
//                 icon,
//                 size: 18,
//                 color: hasError ? AppColors.red : AppColors.c1,
//               ),
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
//           if (hasError) _errorRow(error),
//         ],
//       ),
//     );
//   }

//   // ── Shared dropdown decoration — identical to CreateNewCustomer ───────────
//   InputDecoration _dropdownDecoration(
//     String label,
//     IconData icon, {
//     bool isRequired = false,
//     bool hasError = false,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle:
//           TextStyle(fontSize: 13, color: AppColors.ctext.withOpacity(0.75)),
//       prefixIcon:
//           Icon(icon, size: 18, color: hasError ? AppColors.red : AppColors.c1),
//       suffixIcon: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.keyboard_arrow_down_rounded,
//               color: hasError ? AppColors.red : AppColors.c1, size: 20),
//           if (isRequired) ...[
//             const SizedBox(width: 2),
//             const Icon(Icons.circle, size: 6, color: AppColors.red),
//           ],
//           const SizedBox(width: 8),
//         ],
//       ),
//       suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 32),
//       filled: true,
//       fillColor: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//             color:
//                 hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//             color:
//                 hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//             color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
//       ),
//     );
//   }

//   // ── Dropdown wrapper with error below — identical to CreateNewCustomer ────
//   Widget _dropdownWithError({
//     required Widget dropdown,
//     String? error,
//   }) {
//     final hasError = error != null && error.isNotEmpty;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           dropdown,
//           if (hasError) _errorRow(error),
//         ],
//       ),
//     );
//   }

//   // ── Shared error row ──────────────────────────────────────────────────────
//   Widget _errorRow(String error) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 5, left: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline_rounded,
//               size: 13, color: AppColors.red),
//           const SizedBox(width: 4),
//           Flexible(
//             child: Text(
//               error,
//               style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.red,
//                   height: 1.4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Lead selector — with error state ─────────────────────────────────────
//   Widget _buildLeadSelector() {
//     final hasError = _errLead != null && _errLead!.isNotEmpty;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: _openSelectLeadSheet,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: hasError
//                     ? AppColors.red.withOpacity(0.04)
//                     : _selectedLead != null
//                         ? AppColors.c1.withOpacity(0.06)
//                         : AppColors.cxl,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: hasError
//                       ? AppColors.red.withOpacity(0.60)
//                       : _selectedLead != null
//                           ? AppColors.c1.withOpacity(0.35)
//                           : AppColors.cborder,
//                 ),
//               ),
//               child: _selectedLead == null
//                   ? Row(
//                       children: [
//                         Icon(
//                           Icons.person_search_rounded,
//                           size: 18,
//                           color: hasError ? AppColors.red : AppColors.c1,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'Choose a lead',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: hasError
//                                     ? AppColors.red
//                                     : AppColors.ctext.withOpacity(0.55)),
//                           ),
//                         ),
//                         // Required dot
//                         Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child:
//                               Icon(Icons.circle, size: 6, color: AppColors.red),
//                         ),
//                         Icon(Icons.keyboard_arrow_down_rounded,
//                             color: hasError ? AppColors.red : AppColors.c1,
//                             size: 20),
//                         const SizedBox(width: 4),
//                       ],
//                     )
//                   : Row(
//                       children: [
//                         Container(
//                           width: 38,
//                           height: 38,
//                           decoration: BoxDecoration(
//                             color: AppColors.c1.withOpacity(0.12),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               _selectedLead!.name.isNotEmpty
//                                   ? _selectedLead!.name[0].toUpperCase()
//                                   : 'L',
//                               style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w800,
//                                   color: AppColors.c1),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _selectedLead!.name,
//                                 style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w700,
//                                     color: AppColors.cdark),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 _selectedLead!.email.isNotEmpty
//                                     ? _selectedLead!.email
//                                     : _selectedLead!.phone,
//                                 style: TextStyle(
//                                     fontSize: 11,
//                                     color: AppColors.ctext.withOpacity(0.55)),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           width: 28,
//                           height: 28,
//                           decoration: BoxDecoration(
//                             color: AppColors.c1.withOpacity(0.10),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(Icons.edit_rounded,
//                               size: 13, color: AppColors.c1),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//           if (hasError) _errorRow(_errLead!),
//         ],
//       ),
//     );
//   }

//   // ── Activity Type dropdown ────────────────────────────────────────────────
//   Widget _buildActivityTypeDropdown() {
//     return _dropdownWithError(
//       dropdown: DropdownButtonFormField<String>(
//         value: _activityType,
//         isExpanded: true,
//         dropdownColor: AppColors.white,
//         icon: const SizedBox.shrink(),
//         style: const TextStyle(
//             fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
//         items: _activityTypes.map((t) {
//           return DropdownMenuItem(
//             value: t.value,
//             child: Row(
//               children: [
//                 Icon(t.icon, size: 16, color: AppColors.c1),
//                 const SizedBox(width: 8),
//                 Text(t.label,
//                     style:
//                         const TextStyle(color: AppColors.cdark, fontSize: 14)),
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: (v) {
//           if (v != null) setState(() => _activityType = v);
//         },
//         decoration: _dropdownDecoration(
//           'Activity Type',
//           Icons.category_outlined,
//         ),
//       ),
//     );
//   }

//   // ── Status dropdown ───────────────────────────────────────────────────────
//   Widget _buildStatusDropdown() {
//     return _dropdownWithError(
//       dropdown: DropdownButtonFormField<String>(
//         value: _status,
//         isExpanded: true,
//         dropdownColor: AppColors.white,
//         icon: const SizedBox.shrink(),
//         style: const TextStyle(
//             fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
//         items: _statusTypes.map((t) {
//           return DropdownMenuItem(
//             value: t.value,
//             child: Row(
//               children: [
//                 Icon(t.icon, size: 16, color: AppColors.c1),
//                 const SizedBox(width: 8),
//                 Text(t.label,
//                     style:
//                         const TextStyle(color: AppColors.cdark, fontSize: 14)),
//               ],
//             ),
//           );
//         }).toList(),
//         onChanged: (v) {
//           if (v != null) setState(() => _status = v);
//         },
//         decoration: _dropdownDecoration(
//           'Status',
//           Icons.flag_outlined,
//         ),
//       ),
//     );
//   }

//   // ── Picker field (date/time) — styled like a text field with error ────────
//   Widget _pickerField({
//     required IconData icon,
//     required String label,
//     required String? value,
//     required String placeholder,
//     required VoidCallback onTap,
//     required bool isSet,
//     String? error,
//     bool isRequired = false,
//   }) {
//     final hasError = error != null && error.isNotEmpty;

//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: onTap,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//               decoration: BoxDecoration(
//                 color: hasError
//                     ? AppColors.red.withOpacity(0.04)
//                     : isSet
//                         ? AppColors.c1.withOpacity(0.06)
//                         : AppColors.cxl,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: hasError
//                       ? AppColors.red.withOpacity(0.60)
//                       : isSet
//                           ? AppColors.c1.withOpacity(0.35)
//                           : AppColors.cborder,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     icon,
//                     size: 18,
//                     color: hasError
//                         ? AppColors.red
//                         : isSet
//                             ? AppColors.c1
//                             : AppColors.ctext.withOpacity(0.50),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           label,
//                           style: TextStyle(
//                               fontSize: 11,
//                               color: hasError
//                                   ? AppColors.red
//                                   : AppColors.ctext.withOpacity(0.55),
//                               fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           value ?? placeholder,
//                           style: TextStyle(
//                               fontSize: 14,
//                               fontWeight:
//                                   isSet ? FontWeight.w600 : FontWeight.w400,
//                               color: isSet
//                                   ? AppColors.cdark
//                                   : AppColors.ctext.withOpacity(0.40)),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Required dot
//                   if (isRequired && !isSet)
//                     Padding(
//                       padding: const EdgeInsets.only(right: 6),
//                       child: Icon(Icons.circle, size: 6, color: AppColors.red),
//                     ),
//                   Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: isSet
//                           ? AppColors.c1.withOpacity(0.12)
//                           : AppColors.cxl,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: AppColors.cborder),
//                     ),
//                     child: Icon(
//                       isSet ? Icons.check_rounded : Icons.chevron_right_rounded,
//                       size: 14,
//                       color: isSet
//                           ? AppColors.c1
//                           : AppColors.ctext.withOpacity(0.40),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (hasError) _errorRow(error),
//         ],
//       ),
//     );
//   }

//   // ── Save button — identical to CreateNewCustomer._buildSaveBar ────────────
//   Widget _buildSaveBar() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           color: AppColors.c1,
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.c1.withOpacity(0.30),
//               blurRadius: 14,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: ElevatedButton(
//           onPressed: _submitting ? null : _handleSubmit,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.transparent,
//             shadowColor: Colors.transparent,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
//           ),
//           child: _submitting
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                       color: AppColors.white, strokeWidth: 2),
//                 )
//               : const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.event_available_rounded,
//                         color: AppColors.white, size: 18),
//                     SizedBox(width: 8),
//                     Text(
//                       'Create Follow-up',
//                       style: TextStyle(
//                         color: AppColors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.8,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

// class _DropOption {
//   final String value;
//   final String label;
//   final IconData icon;
//   const _DropOption(this.value, this.label, this.icon);
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/followup_viewmodel.dart';
import 'package:pokakbilling/notification/notification_service.dart';

class AddFollowUp extends StatefulWidget {
  final int? leadId;
  final String? prefillTitle;

  const AddFollowUp({super.key, this.leadId, this.prefillTitle});

  @override
  State<AddFollowUp> createState() => _AddFollowUpState();
}

class _AddFollowUpState extends State<AddFollowUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  LeadModel? _selectedLead;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  String _activityType = 'FOLLOW_UP';
  String _status = 'PENDING';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  // ── Manual field errors (only set on button click) ────────────────────────
  String? _errLead;
  String? _errTitle;
  String? _errDate;
  String? _errTime;

  static const _activityTypes = [
    _DropOption('FOLLOW_UP', 'Follow-up', Icons.repeat_rounded),
    _DropOption('CALL', 'Phone Call', Icons.call_rounded),
    _DropOption('MEETING', 'Meeting', Icons.event_rounded),
    _DropOption('EMAIL', 'Email', Icons.email_rounded),
    _DropOption('WHATSAPP', 'WhatsApp', Icons.message_rounded),
  ];

  static const _statusTypes = [
    _DropOption('PENDING', 'Pending', Icons.hourglass_empty_rounded),
    _DropOption('COMPLETED', 'Completed', Icons.check_circle_rounded),
    _DropOption('CANCELLED', 'Cancelled', Icons.cancel_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    if (widget.prefillTitle != null) {
      _titleCtrl.text = widget.prefillTitle!;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  int _getLeadId(LeadModel lead) {
    if (lead.id > 0) return lead.id;
    return int.tryParse(lead.leadId) ?? 0;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_monthAbbr(d.month)} ${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _monthAbbr(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m - 1];
  }

  String get _activityLabel =>
      _activityTypes.firstWhere((t) => t.value == _activityType).label;

  String get _statusLabel =>
      _statusTypes.firstWhere((t) => t.value == _status).label;

  // ── Lead selector sheet ───────────────────────────────────────────────────
  Future<void> _openSelectLeadSheet() async {
    final vm = Provider.of<LeadViewmodel>(context, listen: false);

    final lead = await showModalBottomSheet<LeadModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.70,
            minChildSize: 0.40,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.c1.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.cxl,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cborder),
                          ),
                          child: Icon(Icons.person_search_rounded,
                              color: AppColors.c1, size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Select Lead',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cdark,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: Icon(Icons.close_rounded,
                              color: AppColors.ctext.withOpacity(0.55)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.cborder),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: vm.leadList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.cborder),
                      itemBuilder: (_, i) {
                        final l = vm.leadList[i];
                        final isSelected = _selectedLead?.id == l.id;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.c1.withOpacity(0.15)
                                  : AppColors.cxl,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                l.name.isNotEmpty
                                    ? l.name[0].toUpperCase()
                                    : 'L',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? AppColors.c1
                                      : AppColors.cdark,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            l.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? AppColors.c1 : AppColors.cdark,
                            ),
                          ),
                          subtitle: Text(
                            l.email.isNotEmpty ? l.email : l.phone,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.ctext.withOpacity(0.55),
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.c1.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_rounded,
                                      color: AppColors.c1, size: 14),
                                )
                              : null,
                          onTap: () => Navigator.of(ctx).pop(l),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (lead != null) {
      setState(() {
        _selectedLead = lead;
        if (_errLead != null) _errLead = null;
      });
    }
  }

  // ── Date / Time pickers ───────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.c1,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.cdark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        if (_errDate != null) _errDate = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.c1,
            onPrimary: AppColors.white,
            surface: AppColors.white,
            onSurface: AppColors.cdark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (_errTime != null) _errTime = null;
      });
    }
  }

  // ── Submit — validate everything manually on click only ───────────────────
  Future<void> _handleSubmit() async {
    // Compute all errors
    final leadErr = _selectedLead == null ? 'Please select a lead' : null;
    final titleErr =
        _titleCtrl.text.trim().isEmpty ? 'Follow-up title is required' : null;
    final dateErr = _selectedDate == null ? 'Please choose a date' : null;
    final timeErr = _selectedTime == null ? 'Please choose a time' : null;

    // Set all errors in one setState
    setState(() {
      _errLead = leadErr;
      _errTitle = titleErr;
      _errDate = dateErr;
      _errTime = timeErr;
    });

    // Stop if any error exists
    if (leadErr != null ||
        titleErr != null ||
        dateErr != null ||
        timeErr != null) return;

    // Validate lead id
    final leadId = _getLeadId(_selectedLead!);
    if (leadId == 0) {
      setState(() => _errLead = 'Invalid lead selected');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      final followupVm = Provider.of<FollowupViewmodel>(context, listen: false);

      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

      final success = await followupVm.createFollowup(
        lead: leadId,
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        date: dateStr,
        time: timeStr,
        status: _status,
        activityType: _activityType,
        location: _locationCtrl.text.trim().isNotEmpty
            ? _locationCtrl.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (success) {
        final followupDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        await NotificationService.instance.showMeetingCreatedNotification(
          title: _titleCtrl.text.trim(),
          meetingType: _activityLabel,
          dateText: _formatDate(_selectedDate!),
          timeText: _formatTime(_selectedTime!),
          leadName: _selectedLead!.name,
        );

        await NotificationService.instance.scheduleMeetingReminder(
          meetingId: followupDateTime.millisecondsSinceEpoch ~/ 1000,
          title: _titleCtrl.text.trim(),
          leadName: _selectedLead!.name,
          meetingType: _activityLabel,
          meetingDateTime: followupDateTime,
        );

        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            _buildHeader(context, sw, topPad),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: [
                        // ── Select Lead section ───────────────────────────
                        _buildSection(
                          icon: Icons.person_outline_rounded,
                          title: 'Select Lead',
                          children: [_buildLeadSelector()],
                        ),
                        const SizedBox(height: 14),
                        // ── Follow-up Details section ─────────────────────
                        _buildSection(
                          icon: Icons.event_note_rounded,
                          title: 'Follow-up Details',
                          children: [
                            _field(
                              _titleCtrl,
                              'Follow-up Title',
                              Icons.title_rounded,
                              isRequired: true,
                              error: _errTitle,
                              onChanged: (_) {
                                if (_errTitle != null)
                                  setState(() => _errTitle = null);
                              },
                            ),
                            _buildActivityTypeDropdown(),
                            _buildStatusDropdown(),
                            _field(
                              _descCtrl,
                              'Description / Notes',
                              Icons.notes_rounded,
                              hint: 'Any additional notes',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // ── Schedule section ──────────────────────────────
                        _buildSection(
                          icon: Icons.schedule_rounded,
                          title: 'Schedule',
                          children: [
                            _pickerField(
                              icon: Icons.calendar_today_rounded,
                              label: 'Date',
                              value: _selectedDate != null
                                  ? _formatDate(_selectedDate!)
                                  : null,
                              placeholder: 'Pick a date',
                              onTap: _pickDate,
                              isSet: _selectedDate != null,
                              error: _errDate,
                            ),
                            _pickerField(
                              icon: Icons.access_time_rounded,
                              label: 'Time',
                              value: _selectedTime != null
                                  ? _formatTime(_selectedTime!)
                                  : null,
                              placeholder: 'Pick a time',
                              onTap: _pickTime,
                              isSet: _selectedTime != null,
                              error: _errTime,
                            ),
                            _field(
                              _locationCtrl,
                              'Location',
                              Icons.location_on_outlined,
                              hint: 'Optional',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSaveBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header — matches CreateNewCustomer exactly ────────────────────────────
  Widget _buildHeader(BuildContext context, double sw, double topPad) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 28,
        left: sw * 0.03,
        right: sw * 0.04,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.c3,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Follow-up',
                style: TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Schedule a follow-up activity',
                style: TextStyle(
                  color: AppColors.ctext.withOpacity(0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section card — matches CreateNewCustomer exactly ─────────────────────
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ── Text field — label/hint now turn pure red on error, matching the Lead
  // selector's "Choose a lead" behavior ───────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isRequired = false,
    String? hint,
    TextInputType? keyboardType,
    String? error,
    void Function(String)? onChanged,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: AppColors.c1,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 14,
              color: hasError ? AppColors.red : AppColors.cdark,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: hasError
                    ? AppColors.red.withOpacity(0.70)
                    : AppColors.ctext.withOpacity(0.40),
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                color: hasError
                    ? AppColors.red
                    : AppColors.ctext.withOpacity(0.75),
              ),
              floatingLabelStyle: TextStyle(
                fontSize: 13,
                color: hasError ? AppColors.red : AppColors.c1,
              ),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: hasError ? AppColors.red : AppColors.c1,
              ),
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
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  // ── Shared dropdown decoration — label now turns pure red on error too ────
  InputDecoration _dropdownDecoration(
    String label,
    IconData icon, {
    bool isRequired = false,
    bool hasError = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: hasError ? AppColors.red : AppColors.ctext.withOpacity(0.75),
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 13,
        color: hasError ? AppColors.red : AppColors.c1,
      ),
      prefixIcon:
          Icon(icon, size: 18, color: hasError ? AppColors.red : AppColors.c1),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_arrow_down_rounded,
              color: hasError ? AppColors.red : AppColors.c1, size: 20),
          if (isRequired) ...[
            const SizedBox(width: 2),
            const Icon(Icons.circle, size: 6, color: AppColors.red),
          ],
          const SizedBox(width: 8),
        ],
      ),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 32),
      filled: true,
      fillColor: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color:
                hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: hasError ? AppColors.red : AppColors.c1, width: 1.5),
      ),
    );
  }

  // ── Dropdown wrapper with error below — identical to CreateNewCustomer ────
  Widget _dropdownWithError({
    required Widget dropdown,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dropdown,
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  // ── Shared error row ──────────────────────────────────────────────────────
  Widget _errorRow(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 13, color: AppColors.red),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              error,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.red,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Lead selector — with error state ─────────────────────────────────────
  Widget _buildLeadSelector() {
    final hasError = _errLead != null && _errLead!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _openSelectLeadSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasError
                    ? AppColors.red.withOpacity(0.04)
                    : _selectedLead != null
                        ? AppColors.c1.withOpacity(0.06)
                        : AppColors.cxl,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : _selectedLead != null
                          ? AppColors.c1.withOpacity(0.35)
                          : AppColors.cborder,
                ),
              ),
              child: _selectedLead == null
                  ? Row(
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 18,
                          color: hasError ? AppColors.red : AppColors.c1,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Choose a lead',
                            style: TextStyle(
                                fontSize: 13,
                                color: hasError
                                    ? AppColors.red
                                    : AppColors.ctext.withOpacity(0.55)),
                          ),
                        ),
                        // Required dot
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child:
                              Icon(Icons.circle, size: 6, color: AppColors.red),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: hasError ? AppColors.red : AppColors.c1,
                            size: 20),
                        const SizedBox(width: 4),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.c1.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _selectedLead!.name.isNotEmpty
                                  ? _selectedLead!.name[0].toUpperCase()
                                  : 'L',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.c1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedLead!.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.cdark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _selectedLead!.email.isNotEmpty
                                    ? _selectedLead!.email
                                    : _selectedLead!.phone,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.ctext.withOpacity(0.55)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.c1.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_rounded,
                              size: 13, color: AppColors.c1),
                        ),
                      ],
                    ),
            ),
          ),
          if (hasError) _errorRow(_errLead!),
        ],
      ),
    );
  }

  // ── Activity Type dropdown ────────────────────────────────────────────────
  Widget _buildActivityTypeDropdown() {
    return _dropdownWithError(
      dropdown: DropdownButtonFormField<String>(
        value: _activityType,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        items: _activityTypes.map((t) {
          return DropdownMenuItem(
            value: t.value,
            child: Row(
              children: [
                Icon(t.icon, size: 16, color: AppColors.c1),
                const SizedBox(width: 8),
                Text(t.label,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 14)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _activityType = v);
        },
        decoration: _dropdownDecoration(
          'Activity Type',
          Icons.category_outlined,
        ),
      ),
    );
  }

  // ── Status dropdown ───────────────────────────────────────────────────────
  Widget _buildStatusDropdown() {
    return _dropdownWithError(
      dropdown: DropdownButtonFormField<String>(
        value: _status,
        isExpanded: true,
        dropdownColor: AppColors.white,
        icon: const SizedBox.shrink(),
        style: const TextStyle(
            fontSize: 14, color: AppColors.cdark, fontWeight: FontWeight.w500),
        items: _statusTypes.map((t) {
          return DropdownMenuItem(
            value: t.value,
            child: Row(
              children: [
                Icon(t.icon, size: 16, color: AppColors.c1),
                const SizedBox(width: 8),
                Text(t.label,
                    style:
                        const TextStyle(color: AppColors.cdark, fontSize: 14)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) setState(() => _status = v);
        },
        decoration: _dropdownDecoration(
          'Status',
          Icons.flag_outlined,
        ),
      ),
    );
  }

  // ── Picker field (date/time) — value text now also turns pure red on error,
  // matching the Lead selector's "Choose a lead" behavior ───────────────────
  Widget _pickerField({
    required IconData icon,
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
    required bool isSet,
    String? error,
    bool isRequired = false,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: hasError
                    ? AppColors.red.withOpacity(0.04)
                    : isSet
                        ? AppColors.c1.withOpacity(0.06)
                        : AppColors.cxl,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : isSet
                          ? AppColors.c1.withOpacity(0.35)
                          : AppColors.cborder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: hasError
                        ? AppColors.red
                        : isSet
                            ? AppColors.c1
                            : AppColors.ctext.withOpacity(0.50),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                              fontSize: 11,
                              color: hasError
                                  ? AppColors.red
                                  : AppColors.ctext.withOpacity(0.55),
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value ?? placeholder,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSet ? FontWeight.w600 : FontWeight.w400,
                              color: hasError
                                  ? AppColors.red
                                  : isSet
                                      ? AppColors.cdark
                                      : AppColors.ctext.withOpacity(0.40)),
                        ),
                      ],
                    ),
                  ),
                  // Required dot
                  if (isRequired && !isSet)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.circle, size: 6, color: AppColors.red),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hasError
                          ? AppColors.red.withOpacity(0.10)
                          : isSet
                              ? AppColors.c1.withOpacity(0.12)
                              : AppColors.cxl,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: hasError
                              ? AppColors.red.withOpacity(0.40)
                              : AppColors.cborder),
                    ),
                    child: Icon(
                      isSet ? Icons.check_rounded : Icons.chevron_right_rounded,
                      size: 14,
                      color: hasError
                          ? AppColors.red
                          : isSet
                              ? AppColors.c1
                              : AppColors.ctext.withOpacity(0.40),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError) _errorRow(error),
        ],
      ),
    );
  }

  // ── Save button — identical to CreateNewCustomer._buildSaveBar ────────────
  Widget _buildSaveBar() {
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
          onPressed: _submitting ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available_rounded,
                        color: AppColors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Create Follow-up',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DropOption {
  final String value;
  final String label;
  final IconData icon;
  const _DropOption(this.value, this.label, this.icon);
}
