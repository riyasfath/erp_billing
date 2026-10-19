// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/lead_model.dart';
// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// // ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
// const String _kWhatsAppSvg = '''
// <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
//   <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
//   <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
// </svg>
// ''';

// // ─── Safe helpers ─────────────────────────────────────────────────────────────
// int _leadKey(LeadModel l) {
//   final id = l.id;
//   if (id != null) return id;
//   return l.hashCode;
// }

// String _safePhone(LeadModel l) => l.phone ?? '';
// String _safeEmail(LeadModel l) => l.email ?? '';
// String _safeStatus(LeadModel l) => l.status ?? '';

// // ─── Validators ───────────────────────────────────────────────────────────────

// /// Returns null if valid, error message if invalid.
// /// Phone: exactly 10 digits, must start with 6/7/8/9.
// String? _validatePhone(String value) {
//   final v = value.trim();
//   if (v.isEmpty) return 'Phone number is required';
//   if (!RegExp(r'^\d+$').hasMatch(v)) return 'Only digits are allowed';
//   if (v.length < 10) return 'Phone number must be 10 digits';
//   if (v.length > 10) return 'Phone number must not exceed 10 digits';
//   if (!RegExp(r'^[6-9]').hasMatch(v))
//     return 'Phone number must start with 6, 7, 8 or 9';
//   return null;
// }

// /// Returns null if valid, error message if invalid.
// /// Email: valid format + must end with .com
// String? _validateEmail(String value) {
//   final v = value.trim();
//   if (v.isEmpty) return 'Email address is required';
//   if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(v))
//     return 'Enter a valid email address';
//   if (!v.toLowerCase().endsWith('.com')) return 'Email must end with .com';
//   return null;
// }

// // ─── CommunicationScreen ──────────────────────────────────────────────────────
// class CommunicationScreen extends StatefulWidget {
//   const CommunicationScreen({super.key});

//   @override
//   State<CommunicationScreen> createState() => _CommunicationScreenState();
// }

// class _CommunicationScreenState extends State<CommunicationScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _headerCtrl;
//   late final AnimationController _bodyCtrl;
//   late final Animation<double> _headerFade;
//   late final Animation<Offset> _headerSlide;
//   late final Animation<double> _bodyFade;
//   late final Animation<Offset> _bodySlide;

//   String _searchTerm = '';
//   int? _selectedId;
//   final TextEditingController _searchCtrl = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     _headerCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 650));
//     _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
//     _headerSlide = Tween<Offset>(
//             begin: const Offset(0, -0.06), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

//     _bodyCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 650));
//     _bodyFade = CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut);
//     _bodySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut));

//     _headerCtrl.forward();
//     Future.delayed(
//         const Duration(milliseconds: 200), () => _bodyCtrl.forward());

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final vm = Provider.of<LeadViewmodel>(context, listen: false);
//       vm.getAllLeads();
//       vm.getAssignedLeads();
//     });
//   }

//   @override
//   void dispose() {
//     _headerCtrl.dispose();
//     _bodyCtrl.dispose();
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   // ── Filtering ─────────────────────────────────────────────────────────────
//   List<LeadModel> _filter(List<LeadModel> list) {
//     return list.where((lead) {
//       if (_searchTerm.isNotEmpty) {
//         final q = _searchTerm.toLowerCase();
//         final nameMatch = lead.name.toLowerCase().contains(q);
//         final companyMatch = lead.company.toLowerCase().contains(q);
//         final phoneMatch = _safePhone(lead).contains(q);
//         if (!nameMatch && !companyMatch && !phoneMatch) return false;
//       }
//       return true;
//     }).toList();
//   }

//   // ── URL launchers ─────────────────────────────────────────────────────────
//   Future<void> _launchWhatsApp(String phone) async {
//     final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
//     if (cleaned.isEmpty) {
//       _snack('No phone number found');
//       return;
//     }
//     final uri = Uri.parse('https://wa.me/$cleaned');
//     try {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (_) {
//       _snack('Could not open WhatsApp');
//     }
//   }

//   Future<void> _launchCall(String phone) async {
//     final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
//     if (cleaned.isEmpty) {
//       _snack('No phone number found');
//       return;
//     }
//     final uri = Uri(scheme: 'tel', path: cleaned);
//     try {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (_) {
//       _snack('Could not open dialler');
//     }
//   }

//   Future<void> _launchEmail(String email) async {
//     if (email.trim().isEmpty) {
//       _snack('No email address found');
//       return;
//     }
//     final uri = Uri(scheme: 'mailto', path: email.trim());
//     bool launched = false;
//     try {
//       launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (_) {}
//     if (launched) return;
//     try {
//       launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
//     } catch (_) {}
//     if (!launched) _snack('Could not open email app');
//   }

//   void _snack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   // ── NEW contact bottom sheet ──────────────────────────────────────────────
//   void _showNewContactSheet(BuildContext context) {
//     final phoneCtrl = TextEditingController();
//     final emailCtrl = TextEditingController();

//     // Per-field error strings — null means no error shown yet
//     String? phoneError;
//     String? emailError;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (sheetCtx) {
//         return Padding(
//           padding: EdgeInsets.only(
//               bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
//           child: Container(
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               border: Border.all(color: AppColors.cborder),
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                 child: StatefulBuilder(
//                   builder: (ctx, setS) {
//                     // ── Inline validators that update state ───────────────
//                     void validatePhone() {
//                       setS(() {
//                         phoneError = _validatePhone(phoneCtrl.text);
//                       });
//                     }

//                     void validateEmail() {
//                       setS(() {
//                         emailError = _validateEmail(emailCtrl.text);
//                       });
//                     }

//                     // ── Action handlers — validate first, then launch ─────
//                     void handleWhatsApp() {
//                       validatePhone();
//                       if (_validatePhone(phoneCtrl.text) != null) return;
//                       Navigator.pop(sheetCtx);
//                       _launchWhatsApp(phoneCtrl.text.trim());
//                     }

//                     void handleCall() {
//                       validatePhone();
//                       if (_validatePhone(phoneCtrl.text) != null) return;
//                       Navigator.pop(sheetCtx);
//                       _launchCall(phoneCtrl.text.trim());
//                     }

//                     void handleEmail() {
//                       validateEmail();
//                       if (_validateEmail(emailCtrl.text) != null) return;
//                       Navigator.pop(sheetCtx);
//                       _launchEmail(emailCtrl.text.trim());
//                     }

//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // drag handle
//                         Center(
//                           child: Container(
//                             width: 40,
//                             height: 4,
//                             margin: const EdgeInsets.symmetric(vertical: 12),
//                             decoration: BoxDecoration(
//                               color: AppColors.c1,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           ),
//                         ),

//                         // title row
//                         Row(children: [
//                           Container(
//                             width: 34,
//                             height: 34,
//                             decoration: BoxDecoration(
//                               color: AppColors.c1.withOpacity(0.20),
//                               borderRadius: BorderRadius.circular(9),
//                             ),
//                             child: const Icon(Icons.person_add_rounded,
//                                 color: AppColors.c1, size: 17),
//                           ),
//                           const SizedBox(width: 10),
//                           const Text('New Contact',
//                               style: TextStyle(
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.ctext,
//                               )),
//                           const Spacer(),
//                           GestureDetector(
//                             onTap: () => Navigator.pop(sheetCtx),
//                             child: const Icon(Icons.close_rounded,
//                                 color: AppColors.c1, size: 20),
//                           ),
//                         ]),

//                         const Divider(
//                           height: 20,
//                           color: AppColors.cborder,
//                           thickness: 1,
//                         ),

//                         // ── Phone field ───────────────────────────────────
//                         const _SheetLabel(label: 'Phone Number'),
//                         const SizedBox(height: 6),
//                         _SheetTextField(
//                           controller: phoneCtrl,
//                           hint: 'e.g. 98765 43210',
//                           icon: Icons.phone_rounded,
//                           keyboardType: TextInputType.phone,
//                           hasError: phoneError != null,
//                           // digits only, max 10
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(10),
//                           ],
//                           onChanged: (_) {
//                             // clear error as user types
//                             if (phoneError != null) {
//                               setS(() => phoneError = null);
//                             }
//                           },
//                         ),
//                         // phone error message
//                         if (phoneError != null) ...[
//                           const SizedBox(height: 5),
//                           _ErrorMessage(message: phoneError!),
//                         ],

//                         const SizedBox(height: 14),

//                         // ── Email field ───────────────────────────────────
//                         const _SheetLabel(label: 'Email Address'),
//                         const SizedBox(height: 6),
//                         _SheetTextField(
//                           controller: emailCtrl,
//                           hint: 'e.g. name@example.com',
//                           icon: Icons.email_rounded,
//                           keyboardType: TextInputType.emailAddress,
//                           hasError: emailError != null,
//                           onChanged: (_) {
//                             // clear error as user types
//                             if (emailError != null) {
//                               setS(() => emailError = null);
//                             }
//                           },
//                         ),
//                         // email error message
//                         if (emailError != null) ...[
//                           const SizedBox(height: 5),
//                           _ErrorMessage(message: emailError!),
//                         ],

//                         const SizedBox(height: 22),

//                         // ── Action buttons ────────────────────────────────
//                         Row(children: [
//                           // WhatsApp — needs phone
//                           Expanded(
//                             child: _SheetActionBtn(
//                               svgIcon: _kWhatsAppSvg,
//                               label: 'WhatsApp',
//                               // always tappable — validation runs on tap
//                               enabled: true,
//                               onTap: handleWhatsApp,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Call — needs phone
//                           Expanded(
//                             child: _SheetActionBtn(
//                               icon: Icons.call_rounded,
//                               label: 'Call',
//                               enabled: true,
//                               onTap: handleCall,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           // Email — needs email
//                           Expanded(
//                             child: _SheetActionBtn(
//                               icon: Icons.email_rounded,
//                               label: 'Email',
//                               enabled: true,
//                               onTap: handleEmail,
//                             ),
//                           ),
//                         ]),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ── BUILD ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LeadViewmodel>(
//       builder: (context, vm, _) {
//         final allMap = <int, LeadModel>{};
//         for (final l in vm.assignedLeadList) {
//           allMap[_leadKey(l)] = l;
//         }
//         for (final l in vm.leadList) {
//           allMap[_leadKey(l)] = l;
//         }
//         final baseList = allMap.values.toList();
//         final filtered = _filter(baseList);
//         final sw = MediaQuery.of(context).size.width;
//         final topPad = MediaQuery.of(context).padding.top;

//         return Scaffold(
//           backgroundColor: AppColors.white,
//           body: SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: Column(
//               children: [
//                 // Header
//                 FadeTransition(
//                   opacity: _headerFade,
//                   child: SlideTransition(
//                     position: _headerSlide,
//                     child: _buildHeader(context, topPad, sw, filtered.length),
//                   ),
//                 ),

//                 // Body
//                 Expanded(
//                   child: FadeTransition(
//                     opacity: _bodyFade,
//                     child: SlideTransition(
//                       position: _bodySlide,
//                       child: Container(
//                         decoration: const BoxDecoration(
//                           color: AppColors.white,
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(28),
//                             topRight: Radius.circular(28),
//                           ),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(28),
//                             topRight: Radius.circular(28),
//                           ),
//                           child: Column(
//                             children: [
//                               // drag handle
//                               Container(
//                                 width: 40,
//                                 height: 4,
//                                 margin:
//                                     const EdgeInsets.only(top: 12, bottom: 4),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.c1.withOpacity(0.40),
//                                   borderRadius: BorderRadius.circular(2),
//                                 ),
//                               ),
//                               // list
//                               Expanded(
//                                 child: vm.getLeadLoader
//                                     ? const Center(
//                                         child: CircularProgressIndicator(
//                                             color: AppColors.c1,
//                                             strokeWidth: 2.5),
//                                       )
//                                     : filtered.isEmpty
//                                         ? _buildEmptyState()
//                                         : ListView.builder(
//                                             padding: const EdgeInsets.fromLTRB(
//                                                 14, 6, 14, 24),
//                                             physics:
//                                                 const BouncingScrollPhysics(),
//                                             itemCount: filtered.length,
//                                             itemBuilder: (ctx, i) {
//                                               final lead = filtered[i];
//                                               final leadKey = _leadKey(lead);
//                                               return _CommunicationCard(
//                                                 lead: lead,
//                                                 isExpanded:
//                                                     _selectedId == leadKey,
//                                                 delay: Duration(
//                                                     milliseconds: 40 + i * 45),
//                                                 onTap: () => setState(() {
//                                                   _selectedId =
//                                                       _selectedId == leadKey
//                                                           ? null
//                                                           : leadKey;
//                                                 }),
//                                                 onWhatsApp: () =>
//                                                     _launchWhatsApp(
//                                                         _safePhone(lead)),
//                                                 onCall: () => _launchCall(
//                                                     _safePhone(lead)),
//                                                 onEmail: () => _launchEmail(
//                                                     _safeEmail(lead)),
//                                               );
//                                             },
//                                           ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ── Header ────────────────────────────────────────────────────────────────
//   Widget _buildHeader(
//     BuildContext context,
//     double topPad,
//     double sw,
//     int count,
//   ) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         top: topPad + 14,
//         bottom: 28,
//         left: sw * 0.05,
//         right: sw * 0.05,
//       ),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom: BorderSide(color: AppColors.cborder, width: 1.5),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [
//             GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                   color: AppColors.cxl,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: AppColors.cborder),
//                 ),
//                 child: const Icon(Icons.arrow_back_ios_new_rounded,
//                     color: AppColors.c3, size: 16),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Communication',
//                       style: TextStyle(
//                         color: AppColors.cdark,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                       )),
//                   const SizedBox(height: 2),
//                   Text('$count lead${count != 1 ? 's' : ''} available',
//                       style: const TextStyle(
//                           color: AppColors.ctext, fontSize: 12)),
//                 ],
//               ),
//             ),

//             // NEW button
//             GestureDetector(
//               onTap: () => _showNewContactSheet(context),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//                 decoration: BoxDecoration(
//                   color: AppColors.c1,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.c1.withOpacity(0.25),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: const Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.add_rounded, color: AppColors.white, size: 15),
//                     SizedBox(width: 4),
//                     Text('New',
//                         style: TextStyle(
//                             color: AppColors.white,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w700)),
//                   ],
//                 ),
//               ),
//             ),
//           ]),

//           const SizedBox(height: 16),

//           // Search bar
//           Container(
//             height: 44,
//             decoration: BoxDecoration(
//               color: AppColors.cxl,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppColors.cborder),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             child: Row(children: [
//               const Icon(Icons.search_rounded,
//                   color: AppColors.ctext, size: 18),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextField(
//                   controller: _searchCtrl,
//                   onChanged: (v) => setState(() => _searchTerm = v),
//                   style: const TextStyle(fontSize: 13, color: AppColors.cdark),
//                   decoration: const InputDecoration(
//                     hintText: 'Search by name, company or phone…',
//                     hintStyle: TextStyle(color: AppColors.ctext, fontSize: 13),
//                     border: InputBorder.none,
//                     isCollapsed: true,
//                     contentPadding: EdgeInsets.symmetric(vertical: 0),
//                   ),
//                 ),
//               ),
//               if (_searchTerm.isNotEmpty)
//                 GestureDetector(
//                   onTap: () {
//                     _searchCtrl.clear();
//                     setState(() => _searchTerm = '');
//                   },
//                   child: Icon(Icons.close_rounded,
//                       size: 16, color: AppColors.ctext),
//                 ),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Empty state ───────────────────────────────────────────────────────────
//   Widget _buildEmptyState() => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 72,
//               height: 72,
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: const Icon(Icons.contacts_rounded,
//                   color: AppColors.c1, size: 32),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'No Leads Found',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.cdark,
//               ),
//             ),
//             const Text('Try adjusting your search',
//                 style: TextStyle(fontSize: 13, color: AppColors.ctext)),
//           ],
//         ),
//       );
// }

// // ─── Error message widget ─────────────────────────────────────────────────────
// class _ErrorMessage extends StatelessWidget {
//   final String message;
//   const _ErrorMessage({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       decoration: BoxDecoration(
//         color: AppColors.red.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.red.withOpacity(0.25)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.error_outline_rounded, size: 13, color: AppColors.red),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               message,
//               style: const TextStyle(
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.red,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Sheet helpers ────────────────────────────────────────────────────────────

// class _SheetLabel extends StatelessWidget {
//   final String label;
//   const _SheetLabel({required this.label});
//   @override
//   Widget build(BuildContext context) => Text(
//         label,
//         style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: AppColors.ctext,
//             letterSpacing: 0.4),
//       );
// }

// class _SheetTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData icon;
//   final TextInputType keyboardType;
//   final ValueChanged<String> onChanged;
//   final bool hasError;
//   final List<TextInputFormatter>? inputFormatters;

//   const _SheetTextField({
//     required this.controller,
//     required this.hint,
//     required this.icon,
//     required this.keyboardType,
//     required this.onChanged,
//     this.hasError = false,
//     this.inputFormatters,
//   });

//   @override
//   Widget build(BuildContext context) => AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         height: 48,
//         decoration: BoxDecoration(
//           color: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color:
//                 hasError ? AppColors.red.withOpacity(0.55) : AppColors.cborder,
//             width: hasError ? 1.5 : 1.0,
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         child: Row(children: [
//           Icon(icon,
//               color: hasError
//                   ? AppColors.red.withOpacity(0.70)
//                   : AppColors.c1.withOpacity(0.70),
//               size: 17),
//           const SizedBox(width: 10),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               onChanged: onChanged,
//               cursorColor: AppColors.c1,
//               keyboardType: keyboardType,
//               inputFormatters: inputFormatters,
//               style: const TextStyle(fontSize: 13, color: AppColors.cdark),
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle:
//                     const TextStyle(color: AppColors.ctext, fontSize: 13),
//                 border: InputBorder.none,
//                 isCollapsed: true,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 0),
//               ),
//             ),
//           ),
//         ]),
//       );
// }

// // ─── Sheet action button ──────────────────────────────────────────────────────
// class _SheetActionBtn extends StatefulWidget {
//   final IconData? icon;
//   final String? svgIcon;
//   final String label;
//   final bool enabled;
//   final VoidCallback onTap;

//   const _SheetActionBtn({
//     this.icon,
//     this.svgIcon,
//     required this.label,
//     required this.enabled,
//     required this.onTap,
//   }) : assert(
//             icon != null || svgIcon != null, 'Provide either icon or svgIcon');

//   @override
//   State<_SheetActionBtn> createState() => _SheetActionBtnState();
// }

// class _SheetActionBtnState extends State<_SheetActionBtn>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 90),
//         lowerBound: 0,
//         upperBound: 1);
//     _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
//         onTapUp: widget.enabled
//             ? (_) {
//                 _ctrl.reverse();
//                 widget.onTap();
//               }
//             : null,
//         onTapCancel: widget.enabled ? () => _ctrl.reverse() : null,
//         child: ScaleTransition(
//           scale: _scale,
//           child: Opacity(
//             opacity: widget.enabled ? 1.0 : 0.35,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 13),
//               decoration: BoxDecoration(
//                 color: AppColors.c1.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.c1.withOpacity(0.30),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (widget.svgIcon != null)
//                     SvgPicture.string(
//                       widget.svgIcon!,
//                       width: 20,
//                       height: 20,
//                       colorFilter:
//                           ColorFilter.mode(AppColors.c1, BlendMode.srcIn),
//                     )
//                   else
//                     Icon(widget.icon, color: AppColors.c1, size: 20),
//                   const SizedBox(height: 4),
//                   Text(widget.label,
//                       style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.c1)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
// }

// // ─── Communication card ───────────────────────────────────────────────────────
// class _CommunicationCard extends StatefulWidget {
//   final LeadModel lead;
//   final bool isExpanded;
//   final Duration delay;
//   final VoidCallback onTap;
//   final VoidCallback onWhatsApp;
//   final VoidCallback onCall;
//   final VoidCallback onEmail;

//   const _CommunicationCard({
//     required this.lead,
//     required this.isExpanded,
//     required this.delay,
//     required this.onTap,
//     required this.onWhatsApp,
//     required this.onCall,
//     required this.onEmail,
//   });

//   @override
//   State<_CommunicationCard> createState() => _CommunicationCardState();
// }

// class _CommunicationCardState extends State<_CommunicationCard>
//     with TickerProviderStateMixin {
//   late final AnimationController _entrCtrl;
//   late final Animation<double> _entrFade;
//   late final Animation<Offset> _entrSlide;

//   late final AnimationController _expandCtrl;
//   late final Animation<double> _expandFade;

//   late final AnimationController _pressCtrl;
//   late final Animation<double> _pressScale;

//   @override
//   void initState() {
//     super.initState();

//     _entrCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 420));
//     _entrFade = CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOut);
//     _entrSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOut));

//     _expandCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 260));
//     _expandFade = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOut);

//     _pressCtrl = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 90),
//         lowerBound: 0,
//         upperBound: 1);
//     _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(_pressCtrl);

//     Future.delayed(widget.delay, () {
//       if (mounted) _entrCtrl.forward();
//     });

//     if (widget.isExpanded) _expandCtrl.value = 1.0;
//   }

//   @override
//   void didUpdateWidget(_CommunicationCard old) {
//     super.didUpdateWidget(old);
//     if (widget.isExpanded != old.isExpanded) {
//       widget.isExpanded ? _expandCtrl.forward() : _expandCtrl.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     _entrCtrl.dispose();
//     _expandCtrl.dispose();
//     _pressCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final lead = widget.lead;
//     final isConverted = _safeStatus(lead).toUpperCase() == 'CONVERTED';
//     final initials = lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?';
//     final phone = _safePhone(lead);
//     final email = _safeEmail(lead);
//     final hasPhone = phone.isNotEmpty;
//     final hasEmail = email.isNotEmpty;

//     return FadeTransition(
//       opacity: _entrFade,
//       child: SlideTransition(
//         position: _entrSlide,
//         child: GestureDetector(
//           onTapDown: (_) => _pressCtrl.forward(),
//           onTapUp: (_) {
//             _pressCtrl.reverse();
//             widget.onTap();
//           },
//           onTapCancel: () => _pressCtrl.reverse(),
//           child: ScaleTransition(
//             scale: _pressScale,
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: widget.isExpanded
//                       ? AppColors.c1.withOpacity(0.50)
//                       : AppColors.c1.withOpacity(0.15),
//                   width: widget.isExpanded ? 1.5 : 1.0,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.isExpanded
//                         ? AppColors.c1.withOpacity(0.18)
//                         : AppColors.c1.withOpacity(0.30),
//                     blurRadius: widget.isExpanded ? 18 : 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // top accent bar
//                   Container(
//                     height: 3,
//                     decoration: BoxDecoration(
//                       color: AppColors.c1,
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         topRight: Radius.circular(16),
//                       ),
//                     ),
//                   ),

//                   // lead info row
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
//                     child: Row(children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: AppColors.c1.withOpacity(0.20),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(initials,
//                               style: TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w800,
//                                   color: isConverted
//                                       ? AppColors.c1
//                                       : AppColors.ctext)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(lead.name,
//                                 style: const TextStyle(
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.w700,
//                                     color: AppColors.ctext),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis),
//                             if (lead.company.isNotEmpty)
//                               Text(lead.company,
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: AppColors.ctext.withOpacity(0.50)),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis),
//                             if (hasPhone)
//                               Row(children: [
//                                 Icon(Icons.phone_outlined,
//                                     size: 10,
//                                     color: AppColors.c1.withOpacity(0.70)),
//                                 const SizedBox(width: 3),
//                                 Text(phone,
//                                     style: TextStyle(
//                                         fontSize: 10,
//                                         color:
//                                             AppColors.ctext.withOpacity(0.45))),
//                               ]),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           _statusBadge(lead.statusDisplay, isConverted),
//                           const SizedBox(height: 6),
//                           AnimatedRotation(
//                             turns: widget.isExpanded ? 0.5 : 0,
//                             duration: const Duration(milliseconds: 260),
//                             child: Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               size: 18,
//                               color: widget.isExpanded
//                                   ? AppColors.c1
//                                   : AppColors.ctext.withOpacity(0.40),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ]),
//                   ),

//                   // expandable section
//                   SizeTransition(
//                     sizeFactor: _expandCtrl,
//                     axisAlignment: -1,
//                     child: FadeTransition(
//                       opacity: _expandFade,
//                       child: Column(children: [
//                         Divider(
//                             height: 1, color: AppColors.c1.withOpacity(0.20)),
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _ContactDetail(
//                                 icon: Icons.phone_rounded,
//                                 value: hasPhone ? phone : 'No phone number',
//                                 isAvailable: hasPhone,
//                               ),
//                               const SizedBox(height: 6),
//                               _ContactDetail(
//                                 icon: Icons.email_rounded,
//                                 value: hasEmail ? email : 'No email address',
//                                 isAvailable: hasEmail,
//                               ),
//                               const SizedBox(height: 14),
//                               Row(children: [
//                                 Expanded(
//                                   child: _ActionButton(
//                                     svgIcon: _kWhatsAppSvg,
//                                     label: 'WhatsApp',
//                                     enabled: hasPhone,
//                                     onTap: widget.onWhatsApp,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: _ActionButton(
//                                     icon: Icons.call_rounded,
//                                     label: 'Call',
//                                     enabled: hasPhone,
//                                     onTap: widget.onCall,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: _ActionButton(
//                                     icon: Icons.email_rounded,
//                                     label: 'Email',
//                                     enabled: hasEmail,
//                                     onTap: widget.onEmail,
//                                   ),
//                                 ),
//                               ]),
//                             ],
//                           ),
//                         ),
//                       ]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _statusBadge(String status, bool isConverted) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: isConverted
//               ? AppColors.c1.withOpacity(0.20)
//               : AppColors.c1.withOpacity(0.25),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isConverted
//                 ? AppColors.c1.withOpacity(0.50)
//                 : AppColors.c1.withOpacity(0.35),
//           ),
//         ),
//         child: Text(status,
//             style: TextStyle(
//                 fontSize: 9,
//                 fontWeight: FontWeight.w700,
//                 color: isConverted ? AppColors.c1 : AppColors.ctext)),
//       );
// }

// // ─── Contact detail row ───────────────────────────────────────────────────────
// class _ContactDetail extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final bool isAvailable;

//   const _ContactDetail({
//     required this.icon,
//     required this.value,
//     required this.isAvailable,
//   });

//   @override
//   Widget build(BuildContext context) => Row(children: [
//         Container(
//           width: 28,
//           height: 28,
//           decoration: BoxDecoration(
//             color: isAvailable
//                 ? AppColors.c1.withOpacity(0.18)
//                 : AppColors.c1.withOpacity(0.07),
//             borderRadius: BorderRadius.circular(7),
//           ),
//           child: Icon(icon,
//               size: 13,
//               color: isAvailable
//                   ? AppColors.c1
//                   : AppColors.ctext.withOpacity(0.30)),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(value,
//               style: TextStyle(
//                   fontSize: 11,
//                   color: isAvailable
//                       ? AppColors.ctext.withOpacity(0.85)
//                       : AppColors.ctext.withOpacity(0.30),
//                   fontWeight: isAvailable ? FontWeight.w500 : FontWeight.w400),
//               overflow: TextOverflow.ellipsis),
//         ),
//       ]);
// }

// // ─── Action button ────────────────────────────────────────────────────────────
// class _ActionButton extends StatefulWidget {
//   final IconData? icon;
//   final String? svgIcon;
//   final String label;
//   final bool enabled;
//   final VoidCallback onTap;

//   const _ActionButton({
//     this.icon,
//     this.svgIcon,
//     required this.label,
//     required this.enabled,
//     required this.onTap,
//   }) : assert(
//             icon != null || svgIcon != null, 'Provide either icon or svgIcon');

//   @override
//   State<_ActionButton> createState() => _ActionButtonState();
// }

// class _ActionButtonState extends State<_ActionButton>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 90),
//         lowerBound: 0,
//         upperBound: 1);
//     _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
//         onTapUp: widget.enabled
//             ? (_) {
//                 _ctrl.reverse();
//                 widget.onTap();
//               }
//             : null,
//         onTapCancel: widget.enabled ? () => _ctrl.reverse() : null,
//         child: ScaleTransition(
//           scale: _scale,
//           child: Opacity(
//             opacity: widget.enabled ? 1.0 : 0.35,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 11),
//               decoration: BoxDecoration(
//                 color: AppColors.c1.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.c1.withOpacity(0.30),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (widget.svgIcon != null)
//                     SvgPicture.string(
//                       widget.svgIcon!,
//                       width: 18,
//                       height: 18,
//                       colorFilter:
//                           ColorFilter.mode(AppColors.c1, BlendMode.srcIn),
//                     )
//                   else
//                     Icon(widget.icon, color: AppColors.c1, size: 18),
//                   const SizedBox(height: 4),
//                   Text(widget.label,
//                       style: const TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.c1)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── WhatsApp SVG ─────────────────────────────────────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

// ─── Safe helpers ─────────────────────────────────────────────────────────────
int _leadKey(LeadModel l) => l.id;

String _safePhone(LeadModel l) => l.phone;
String _safeEmail(LeadModel l) => l.email;
String _safeStatus(LeadModel l) => l.status;

// ─── Validators ───────────────────────────────────────────────────────────────

/// Returns null if valid, error message if invalid.
/// Phone: exactly 10 digits, must start with 6/7/8/9.
String? _validatePhone(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Phone number is required';
  if (!RegExp(r'^\d+$').hasMatch(v)) return 'Only digits are allowed';
  if (v.length < 10) return 'Phone number must be 10 digits';
  if (v.length > 10) return 'Phone number must not exceed 10 digits';
  if (!RegExp(r'^[6-9]').hasMatch(v))
    return 'Phone number must start with 6, 7, 8 or 9';
  return null;
}

/// Returns null if valid, error message if invalid.
/// Email: valid format + must end with .com
String? _validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Email address is required';
  if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(v))
    return 'Enter a valid email address';
  if (!v.toLowerCase().endsWith('.com')) return 'Email must end with .com';
  return null;
}

// ─── CommunicationScreen ──────────────────────────────────────────────────────
class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  String _searchTerm = '';
  int? _selectedId;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _bodyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _bodyFade = CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut);
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 200), () => _bodyCtrl.forward());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<LeadViewmodel>(context, listen: false);
      vm.getAllLeads();
      vm.getAssignedLeads();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  List<LeadModel> _filter(List<LeadModel> list) {
    return list.where((lead) {
      if (_searchTerm.isNotEmpty) {
        final q = _searchTerm.toLowerCase();
        final nameMatch = lead.name.toLowerCase().contains(q);
        final companyMatch = lead.company.toLowerCase().contains(q);
        final phoneMatch = _safePhone(lead).contains(q);
        if (!nameMatch && !companyMatch && !phoneMatch) return false;
      }
      return true;
    }).toList();
  }

  // ── URL launchers (still used by WhatsApp / Email, and by the New
  //    Contact sheet, which has no real lead_id to schedule a call for) ────
  Future<void> _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack('No phone number found');
      return;
    }
    final uri = Uri.parse('https://wa.me/$cleaned');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _snack('Could not open WhatsApp');
    }
  }

  Future<void> _launchCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      _snack('No phone number found');
      return;
    }
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _snack('Could not open dialler');
    }
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) {
      _snack('No email address found');
      return;
    }
    final uri = Uri(scheme: 'mailto', path: email.trim());
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (launched) return;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {}
    if (!launched) _snack('Could not open email app');
  }

  // ✅ NEW: Call button on a lead card now hits the schedule-task API
  // instead of opening the phone dialer. Shows "Call Scheduled" on success
  // (via LeadViewmodel.scheduleCall, which uses showSuccessMessage /
  // showOverlayError internally).
  Future<void> _scheduleCall(LeadModel lead) async {
    final vm = Provider.of<LeadViewmodel>(context, listen: false);
    await vm.scheduleCall(lead.id, context);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── NEW contact bottom sheet ──────────────────────────────────────────────
  // NOTE: This sheet is for an ad-hoc phone/email — it isn't tied to an
  // existing lead, so it has no lead_id and therefore cannot call the
  // schedule-task API. Its Call button still opens the dialer.
  void _showNewContactSheet(BuildContext context) {
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    // Per-field error strings — null means no error shown yet
    String? phoneError;
    String? emailError;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.cborder),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: StatefulBuilder(
                  builder: (ctx, setS) {
                    // ── Inline validators that update state ───────────────
                    void validatePhone() {
                      setS(() {
                        phoneError = _validatePhone(phoneCtrl.text);
                      });
                    }

                    void validateEmail() {
                      setS(() {
                        emailError = _validateEmail(emailCtrl.text);
                      });
                    }

                    // ── Action handlers — validate first, then launch ─────
                    void handleWhatsApp() {
                      validatePhone();
                      if (_validatePhone(phoneCtrl.text) != null) return;
                      Navigator.pop(sheetCtx);
                      _launchWhatsApp(phoneCtrl.text.trim());
                    }

                    void handleCall() {
                      validatePhone();
                      if (_validatePhone(phoneCtrl.text) != null) return;
                      Navigator.pop(sheetCtx);
                      _launchCall(phoneCtrl.text.trim());
                    }

                    void handleEmail() {
                      validateEmail();
                      if (_validateEmail(emailCtrl.text) != null) return;
                      Navigator.pop(sheetCtx);
                      _launchEmail(emailCtrl.text.trim());
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.c1,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // title row
                        Row(children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.c1.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.person_add_rounded,
                                color: AppColors.c1, size: 17),
                          ),
                          const SizedBox(width: 10),
                          const Text('New Contact',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ctext,
                              )),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(sheetCtx),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.c1, size: 20),
                          ),
                        ]),

                        const Divider(
                          height: 20,
                          color: AppColors.cborder,
                          thickness: 1,
                        ),

                        // ── Phone field ───────────────────────────────────
                        const _SheetLabel(label: 'Phone Number'),
                        const SizedBox(height: 6),
                        _SheetTextField(
                          controller: phoneCtrl,
                          hint: 'e.g. 98765 43210',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          hasError: phoneError != null,
                          // digits only, max 10
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (_) {
                            // clear error as user types
                            if (phoneError != null) {
                              setS(() => phoneError = null);
                            }
                          },
                        ),
                        // phone error message
                        if (phoneError != null) ...[
                          const SizedBox(height: 5),
                          _ErrorMessage(message: phoneError!),
                        ],

                        const SizedBox(height: 14),

                        // ── Email field ───────────────────────────────────
                        const _SheetLabel(label: 'Email Address'),
                        const SizedBox(height: 6),
                        _SheetTextField(
                          controller: emailCtrl,
                          hint: 'e.g. name@example.com',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          hasError: emailError != null,
                          onChanged: (_) {
                            // clear error as user types
                            if (emailError != null) {
                              setS(() => emailError = null);
                            }
                          },
                        ),
                        // email error message
                        if (emailError != null) ...[
                          const SizedBox(height: 5),
                          _ErrorMessage(message: emailError!),
                        ],

                        const SizedBox(height: 22),

                        // ── Action buttons ────────────────────────────────
                        Row(children: [
                          // WhatsApp — needs phone
                          Expanded(
                            child: _SheetActionBtn(
                              svgIcon: _kWhatsAppSvg,
                              label: 'WhatsApp',
                              // always tappable — validation runs on tap
                              enabled: true,
                              onTap: handleWhatsApp,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Call — needs phone
                          Expanded(
                            child: _SheetActionBtn(
                              icon: Icons.call_rounded,
                              label: 'Call',
                              enabled: true,
                              onTap: handleCall,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Email — needs email
                          Expanded(
                            child: _SheetActionBtn(
                              icon: Icons.email_rounded,
                              label: 'Email',
                              enabled: true,
                              onTap: handleEmail,
                            ),
                          ),
                        ]),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<LeadViewmodel>(
      builder: (context, vm, _) {
        final allMap = <int, LeadModel>{};
        for (final l in vm.assignedLeadList) {
          allMap[_leadKey(l)] = l;
        }
        for (final l in vm.leadList) {
          allMap[_leadKey(l)] = l;
        }
        final baseList = allMap.values.toList();
        final filtered = _filter(baseList);
        final sw = MediaQuery.of(context).size.width;
        final topPad = MediaQuery.of(context).padding.top;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // Header
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(context, topPad, sw, filtered.length),
                  ),
                ),

                // Body
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: SlideTransition(
                      position: _bodySlide,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          child: Column(
                            children: [
                              // drag handle
                              Container(
                                width: 40,
                                height: 4,
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.40),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // list
                              Expanded(
                                child: vm.getLeadLoader
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            color: AppColors.c1,
                                            strokeWidth: 2.5),
                                      )
                                    : filtered.isEmpty
                                        ? _buildEmptyState()
                                        : ListView.builder(
                                            padding: const EdgeInsets.fromLTRB(
                                                14, 6, 14, 24),
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: filtered.length,
                                            itemBuilder: (ctx, i) {
                                              final lead = filtered[i];
                                              final leadKey = _leadKey(lead);
                                              return _CommunicationCard(
                                                lead: lead,
                                                isExpanded:
                                                    _selectedId == leadKey,
                                                delay: Duration(
                                                    milliseconds: 40 + i * 45),
                                                onTap: () => setState(() {
                                                  _selectedId =
                                                      _selectedId == leadKey
                                                          ? null
                                                          : leadKey;
                                                }),
                                                onWhatsApp: () =>
                                                    _launchWhatsApp(
                                                        _safePhone(lead)),
                                                // ✅ CHANGED: was
                                                // _launchCall(_safePhone(lead))
                                                // now hits the schedule-task
                                                // API using the lead's id.
                                                onCall: () =>
                                                    _scheduleCall(lead),
                                                onEmail: () => _launchEmail(
                                                    _safeEmail(lead)),
                                              );
                                            },
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    int count,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 28,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
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
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Communication',
                      style: TextStyle(
                        color: AppColors.cdark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 2),
                  Text('$count lead${count != 1 ? 's' : ''} available',
                      style: const TextStyle(
                          color: AppColors.ctext, fontSize: 12)),
                ],
              ),
            ),

            // NEW button
            GestureDetector(
              onTap: () => _showNewContactSheet(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.c1,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.c1.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.white, size: 15),
                    SizedBox(width: 4),
                    Text('New',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cborder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              const Icon(Icons.search_rounded,
                  color: AppColors.ctext, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchTerm = v),
                  style: const TextStyle(fontSize: 13, color: AppColors.cdark),
                  decoration: const InputDecoration(
                    hintText: 'Search by name, company or phone…',
                    hintStyle: TextStyle(color: AppColors.ctext, fontSize: 13),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              if (_searchTerm.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _searchTerm = '');
                  },
                  child: Icon(Icons.close_rounded,
                      size: 16, color: AppColors.ctext),
                ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(Icons.contacts_rounded,
                  color: AppColors.c1, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Leads Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.cdark,
              ),
            ),
            const Text('Try adjusting your search',
                style: TextStyle(fontSize: 13, color: AppColors.ctext)),
          ],
        ),
      );
}

// ─── Error message widget ─────────────────────────────────────────────────────
class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 13, color: AppColors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.red,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sheet helpers ────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String label;
  const _SheetLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.ctext,
            letterSpacing: 0.4),
      );
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final List<TextInputFormatter>? inputFormatters;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.keyboardType,
    required this.onChanged,
    this.hasError = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        decoration: BoxDecoration(
          color: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                hasError ? AppColors.red.withOpacity(0.55) : AppColors.cborder,
            width: hasError ? 1.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(icon,
              color: hasError
                  ? AppColors.red.withOpacity(0.70)
                  : AppColors.c1.withOpacity(0.70),
              size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.c1,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: const TextStyle(fontSize: 13, color: AppColors.cdark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: AppColors.ctext, fontSize: 13),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ]),
      );
}

// ─── Sheet action button ──────────────────────────────────────────────────────
class _SheetActionBtn extends StatefulWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SheetActionBtn({
    this.icon,
    this.svgIcon,
    required this.label,
    required this.enabled,
    required this.onTap,
  }) : assert(
            icon != null || svgIcon != null, 'Provide either icon or svgIcon');

  @override
  State<_SheetActionBtn> createState() => _SheetActionBtnState();
}

class _SheetActionBtnState extends State<_SheetActionBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90),
        lowerBound: 0,
        upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
        onTapUp: widget.enabled
            ? (_) {
                _ctrl.reverse();
                widget.onTap();
              }
            : null,
        onTapCancel: widget.enabled ? () => _ctrl.reverse() : null,
        child: ScaleTransition(
          scale: _scale,
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.c1.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.svgIcon != null)
                    SvgPicture.string(
                      widget.svgIcon!,
                      width: 20,
                      height: 20,
                      colorFilter:
                          ColorFilter.mode(AppColors.c1, BlendMode.srcIn),
                    )
                  else
                    Icon(widget.icon, color: AppColors.c1, size: 20),
                  const SizedBox(height: 4),
                  Text(widget.label,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.c1)),
                ],
              ),
            ),
          ),
        ),
      );
}

// ─── Communication card ───────────────────────────────────────────────────────
class _CommunicationCard extends StatefulWidget {
  final LeadModel lead;
  final bool isExpanded;
  final Duration delay;
  final VoidCallback onTap;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const _CommunicationCard({
    required this.lead,
    required this.isExpanded,
    required this.delay,
    required this.onTap,
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
  });

  @override
  State<_CommunicationCard> createState() => _CommunicationCardState();
}

class _CommunicationCardState extends State<_CommunicationCard>
    with TickerProviderStateMixin {
  late final AnimationController _entrCtrl;
  late final Animation<double> _entrFade;
  late final Animation<Offset> _entrSlide;

  late final AnimationController _expandCtrl;
  late final Animation<double> _expandFade;

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _entrCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _entrFade = CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOut);
    _entrSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrCtrl, curve: Curves.easeOut));

    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _expandFade = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOut);

    _pressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90),
        lowerBound: 0,
        upperBound: 1);
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(_pressCtrl);

    Future.delayed(widget.delay, () {
      if (mounted) _entrCtrl.forward();
    });

    if (widget.isExpanded) _expandCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_CommunicationCard old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _expandCtrl.forward() : _expandCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _entrCtrl.dispose();
    _expandCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final isConverted = _safeStatus(lead).toUpperCase() == 'CONVERTED';
    final initials = lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?';
    final phone = _safePhone(lead);
    final email = _safeEmail(lead);
    final hasPhone = phone.isNotEmpty;
    final hasEmail = email.isNotEmpty;

    return FadeTransition(
      opacity: _entrFade,
      child: SlideTransition(
        position: _entrSlide,
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.forward(),
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressCtrl.reverse(),
          child: ScaleTransition(
            scale: _pressScale,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isExpanded
                      ? AppColors.c1.withOpacity(0.50)
                      : AppColors.c1.withOpacity(0.15),
                  width: widget.isExpanded ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isExpanded
                        ? AppColors.c1.withOpacity(0.18)
                        : AppColors.c1.withOpacity(0.30),
                    blurRadius: widget.isExpanded ? 18 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // top accent bar
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.c1,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),

                  // lead info row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.c1.withOpacity(0.20),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(initials,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isConverted
                                      ? AppColors.c1
                                      : AppColors.ctext)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lead.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ctext),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            if (lead.company.isNotEmpty)
                              Text(lead.company,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.ctext.withOpacity(0.50)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            if (hasPhone)
                              Row(children: [
                                Icon(Icons.phone_outlined,
                                    size: 10,
                                    color: AppColors.c1.withOpacity(0.70)),
                                const SizedBox(width: 3),
                                Text(phone,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            AppColors.ctext.withOpacity(0.45))),
                              ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _statusBadge(lead.statusDisplay, isConverted),
                          const SizedBox(height: 6),
                          AnimatedRotation(
                            turns: widget.isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 260),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: widget.isExpanded
                                  ? AppColors.c1
                                  : AppColors.ctext.withOpacity(0.40),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),

                  // expandable section
                  SizeTransition(
                    sizeFactor: _expandCtrl,
                    axisAlignment: -1,
                    child: FadeTransition(
                      opacity: _expandFade,
                      child: Column(children: [
                        Divider(
                            height: 1, color: AppColors.c1.withOpacity(0.20)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ContactDetail(
                                icon: Icons.phone_rounded,
                                value: hasPhone ? phone : 'No phone number',
                                isAvailable: hasPhone,
                              ),
                              const SizedBox(height: 6),
                              _ContactDetail(
                                icon: Icons.email_rounded,
                                value: hasEmail ? email : 'No email address',
                                isAvailable: hasEmail,
                              ),
                              const SizedBox(height: 14),
                              Row(children: [
                                Expanded(
                                  child: _ActionButton(
                                    svgIcon: _kWhatsAppSvg,
                                    label: 'WhatsApp',
                                    enabled: hasPhone,
                                    onTap: widget.onWhatsApp,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.call_rounded,
                                    label: 'Call',
                                    // ✅ Call is now always enabled — it
                                    // schedules a call task via API, it
                                    // doesn't require the phone to be
                                    // dialable directly.
                                    enabled: true,
                                    onTap: widget.onCall,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ActionButton(
                                    icon: Icons.email_rounded,
                                    label: 'Email',
                                    enabled: hasEmail,
                                    onTap: widget.onEmail,
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status, bool isConverted) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isConverted
              ? AppColors.c1.withOpacity(0.20)
              : AppColors.c1.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isConverted
                ? AppColors.c1.withOpacity(0.50)
                : AppColors.c1.withOpacity(0.35),
          ),
        ),
        child: Text(status,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isConverted ? AppColors.c1 : AppColors.ctext)),
      );
}

// ─── Contact detail row ───────────────────────────────────────────────────────
class _ContactDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isAvailable;

  const _ContactDetail({
    required this.icon,
    required this.value,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isAvailable
                ? AppColors.c1.withOpacity(0.18)
                : AppColors.c1.withOpacity(0.07),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon,
              size: 13,
              color: isAvailable
                  ? AppColors.c1
                  : AppColors.ctext.withOpacity(0.30)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 11,
                  color: isAvailable
                      ? AppColors.ctext.withOpacity(0.85)
                      : AppColors.ctext.withOpacity(0.30),
                  fontWeight: isAvailable ? FontWeight.w500 : FontWeight.w400),
              overflow: TextOverflow.ellipsis),
        ),
      ]);
}

// ─── Action button ────────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    this.icon,
    this.svgIcon,
    required this.label,
    required this.enabled,
    required this.onTap,
  }) : assert(
            icon != null || svgIcon != null, 'Provide either icon or svgIcon');

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90),
        lowerBound: 0,
        upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
        onTapUp: widget.enabled
            ? (_) {
                _ctrl.reverse();
                widget.onTap();
              }
            : null,
        onTapCancel: widget.enabled ? () => _ctrl.reverse() : null,
        child: ScaleTransition(
          scale: _scale,
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.c1.withOpacity(0.30),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.svgIcon != null)
                    SvgPicture.string(
                      widget.svgIcon!,
                      width: 18,
                      height: 18,
                      colorFilter:
                          ColorFilter.mode(AppColors.c1, BlendMode.srcIn),
                    )
                  else
                    Icon(widget.icon, color: AppColors.c1, size: 18),
                  const SizedBox(height: 4),
                  Text(widget.label,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.c1)),
                ],
              ),
            ),
          ),
        ),
      );
}
