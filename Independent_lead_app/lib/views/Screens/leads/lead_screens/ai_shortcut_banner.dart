// // lib/views/Screens/leads/common/ai_shortcut_banner.dart  (NEW)
// // Highlighted "AI Studio" card: quick access to AI Email + AI WhatsApp generator.

// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/views/Screens/leads/lead_screens/lead_widgets.dart';
// import 'package:pokakbilling/views/Screens/leads/lead_screens/whatsapp_icon.dart';

// class AiShortcutBanner extends StatelessWidget {
//   const AiShortcutBanner({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LeadUi.aiGradient,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF2A9BB8).withOpacity(.35),
//             blurRadius: 22,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: Stack(children: [
//           Positioned(
//             right: -30,
//             top: -34,
//             child: Container(
//               width: 130,
//               height: 130,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(.08),
//               ),
//             ),
//           ),
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(.16),
//                   borderRadius: BorderRadius.circular(13),
//                   border: Border.all(color: Colors.white.withOpacity(.28)),
//                 ),
//                 child: const Icon(Icons.auto_awesome_rounded,
//                     color: Colors.white, size: 21),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text('AI Studio',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: .3)),
//                   Text('Personalized follow-ups in seconds',
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(.78), fontSize: 11.5)),
//                 ]),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(.18),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text('AI',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: 1)),
//               ),
//             ]),
//             const SizedBox(height: 14),
//             Row(children: [
//               Expanded(
//                 child: _tile(
//                   context,
//                   icon: const IconBadge(
//                       icon: Icons.mail_rounded, color: Color(0xFF38BDF8), size: 40),
//                   title: 'AI Email',
//                   sub: 'Generator',
//                   channel: 'email',
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: _tile(
//                   context,
//                   icon: const WhatsAppLogo(size: 40),
//                   title: 'AI WhatsApp',
//                   sub: 'Generator',
//                   channel: 'whatsapp',
//                 ),
//               ),
//             ]),
//           ]),
//         ]),
//       ),
//     );
//   }

//   Widget _tile(
//     BuildContext context, {
//     required Widget icon,
//     required String title,
//     required String sub,
//     required String channel,
//   }) {
//     return GestureDetector(
//       onTap: () =>
//           pushNavigation(context, AiGeneratorScreen(initialChannel: channel)),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(.13),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white.withOpacity(.26)),
//         ),
//         child: Row(children: [
//           icon,
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w900)),
//               Text(sub,
//                   style: TextStyle(
//                       color: Colors.white.withOpacity(.75), fontSize: 10.5)),
//             ]),
//           ),
//           Icon(Icons.arrow_forward_rounded,
//               size: 16, color: Colors.white.withOpacity(.85)),
//         ]),
//       ),
//     );
//   }
// }