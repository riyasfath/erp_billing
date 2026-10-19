// import 'package:flutter/material.dart';

// class TwoContainerCard extends StatelessWidget {
//   const TwoContainerCard({
//     super.key,
//     required this.locationName,
//     this.onEdit,
//     this.onDelete,
//   });

//   final String locationName;
//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   // Exact sizes
//   static const double _cardW = 353.0;
//   static const double _cardH = 54.0;
//   static const double _leftW = 281.53;
//   static const double _rightW = _cardW - _leftW; // 71.47
//   static const Color _borderColor = Color(0xFF232792);
//   static const List<Color> _gradient = [
//     Color(0xFF232792),
//     Color(0xFF141BE4),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     const double pad = 8; // inside right section
//     const double gap = 8; // between buttons
//     final double squareSide = (_rightW - pad * 2 - gap) / 2;

//     return SizedBox(
//       width: _cardW,
//       height: _cardH,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           border: Border.all(color: _borderColor, width: 1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // LEFT gradient panel
//             Container(
//               width: _leftW,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                   colors: _gradient,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(8),
//                   bottomLeft: Radius.circular(8),
//                   topRight: Radius.circular(44),
//                   bottomRight: Radius.circular(44),
//                 ),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 children: [
//                   const Icon(Icons.location_on_outlined,
//                       color: Colors.white, size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       locationName,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // RIGHT: two white squares
//             SizedBox(
//               width: _rightW,
//               child: Padding(
//                 padding: const EdgeInsets.all(pad),
//                 child: Row(
//                   children: [
//                     _SquareIconButton(
//                       side: squareSide,
//                       icon: Icons.edit_outlined,
//                       onTap: onEdit,
//                     ),
//                     const SizedBox(width: gap),
//                     _SquareIconButton(
//                       side: squareSide,
//                       icon: Icons.delete_outline,
//                       onTap: onDelete,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SquareIconButton extends StatelessWidget {
//   const _SquareIconButton({
//     required this.side,
//     required this.icon,
//     this.onTap,
//   });

//   final double side;
//   final IconData icon;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: side,
//       height: side,
//       child: Material(
//         color: Colors.white,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.zero, // no radius
//         ),
//         child: InkWell(
//           onTap: onTap,
//           child: Center(
//             child: Icon(icon, size: 18, color: Color(0xFF0C0F1A)),
//           ),
//         ),
//       ),
//     );
//   }
// }
