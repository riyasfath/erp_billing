// // import 'package:flutter/material.dart';
// // import 'package:pokakbilling/models/contract/contract_model.dart';
// // import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
// // import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
// // import 'package:provider/provider.dart';
// // import 'package:pokakbilling/core/themes/app_colors.dart';
// // import 'package:pokakbilling/models/data-models/client_contract_model.dart';

// // class ContractDetailsDialog extends StatefulWidget {
// //   final ContractModel? contract;
// //   const ContractDetailsDialog({super.key, this.contract});

// //   @override
// //   State<ContractDetailsDialog> createState() => _ContractDetailsDialogState();
// // }

// // class _ContractDetailsDialogState extends State<ContractDetailsDialog>
// //     with SingleTickerProviderStateMixin {
// //   final TextEditingController contractTitleController = TextEditingController();
// //   List<ContractSectionModel> sections = [ContractSectionModel()];

// //   late final AnimationController _animCtrl;
// //   late final Animation<double> _scaleAnim;
// //   late final Animation<double> _fadeAnim;

// //   // ── Validation state ──────────────────────────────────────────────────────
// //   List<String> _validationErrors = [];
// //   bool _titleError = false;
// //   Set<int> _sectionTitleErrors = {};

// //   @override
// //   void initState() {
// //     super.initState();

// //     _animCtrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 350),
// //     );
// //     _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
// //       CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
// //     );
// //     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
// //     _animCtrl.forward();

// //     if (widget.contract != null) {
// //       contractTitleController.text = widget.contract!.name;
// //       sections = widget.contract!.sections.map((s) {
// //         final section = ContractSectionModel();
// //         section.sectionTitleController.text = s.title;
// //         section.points = s.points.map((p) {
// //           final controller = TextEditingController();
// //           controller.text = p.content;
// //           return controller;
// //         }).toList();
// //         return section;
// //       }).toList();
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _animCtrl.dispose();
// //     contractTitleController.dispose();
// //     super.dispose();
// //   }

// //   // ── Validation logic ──────────────────────────────────────────────────────
// //   bool _validate() {
// //     final errors = <String>[];
// //     bool titleErr = false;
// //     final Set<int> sectionErrs = {};

// //     if (contractTitleController.text.trim().isEmpty) {
// //       titleErr = true;
// //       errors.add('Contract title is required');
// //     }

// //     bool hasValidSection = false;
// //     for (int i = 0; i < sections.length; i++) {
// //       if (sections[i].sectionTitleController.text.trim().isEmpty) {
// //         sectionErrs.add(i);
// //         errors.add('Section ${i + 1} title is required');
// //       } else {
// //         hasValidSection = true;
// //       }
// //     }

// //     if (!hasValidSection && sectionErrs.isEmpty) {
// //       errors.add('Add at least one section with a title');
// //     }

// //     setState(() {
// //       _validationErrors = errors;
// //       _titleError = titleErr;
// //       _sectionTitleErrors = sectionErrs;
// //     });

// //     return errors.isEmpty;
// //   }

// //   void _clearTitleError() {
// //     if (_titleError) {
// //       setState(() {
// //         _titleError = false;
// //         _validationErrors.removeWhere(
// //             (e) => e.contains('title is required') && !e.contains('Section'));
// //       });
// //     }
// //   }

// //   void _clearSectionError(int index) {
// //     if (_sectionTitleErrors.contains(index)) {
// //       setState(() {
// //         _sectionTitleErrors.remove(index);
// //         _validationErrors
// //             .removeWhere((e) => e.contains('Section ${index + 1}'));
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final isEdit = widget.contract != null;

// //     return FadeTransition(
// //       opacity: _fadeAnim,
// //       child: ScaleTransition(
// //         scale: _scaleAnim,
// //         child: Dialog(
// //           insetPadding:
// //               const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
// //           backgroundColor: AppColors.white,
// //           elevation: 0,
// //           insetAnimationDuration: const Duration(milliseconds: 200),
// //           insetAnimationCurve: Curves.easeOut,
// //           child: LayoutBuilder(
// //             builder: (context, constraints) {
// //               final viewInsets = MediaQuery.of(context).viewInsets;
// //               final screenH = MediaQuery.of(context).size.height;
// //               final maxH = screenH -
// //                   viewInsets.bottom -
// //                   MediaQuery.of(context).padding.top -
// //                   48;

// //               return Container(
// //                 constraints: BoxConstraints(maxHeight: maxH < 400 ? 400 : maxH),
// //                 decoration: BoxDecoration(
// //                   color: AppColors.white,
// //                   borderRadius: BorderRadius.circular(16),
// //                   border: Border.all(color: AppColors.cborder),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: AppColors.c1.withOpacity(0.06),
// //                       blurRadius: 14,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 clipBehavior: Clip.hardEdge,
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     _buildDialogHeader(isEdit),
// //                     Flexible(
// //                       child: SingleChildScrollView(
// //                         physics: const BouncingScrollPhysics(),
// //                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             // ── Validation banner ─────────────────────────
// //                             if (_validationErrors.isNotEmpty)
// //                               _buildValidationBanner(),
// //                             _buildTitleField(),
// //                             const SizedBox(height: 20),
// //                             Row(
// //                               children: [
// //                                 Container(
// //                                   width: 28,
// //                                   height: 28,
// //                                   decoration: BoxDecoration(
// //                                     color: AppColors.cxl,
// //                                     borderRadius: BorderRadius.circular(8),
// //                                     border:
// //                                         Border.all(color: AppColors.cborder),
// //                                   ),
// //                                   child: const Icon(
// //                                     Icons.list_alt_rounded,
// //                                     color: AppColors.c1,
// //                                     size: 15,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 8),
// //                                 const Text(
// //                                   'Contract Sections',
// //                                   style: TextStyle(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w700,
// //                                     color: AppColors.cdark,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 12),
// //                             ListView.builder(
// //                               shrinkWrap: true,
// //                               physics: const NeverScrollableScrollPhysics(),
// //                               itemCount: sections.length,
// //                               itemBuilder: (_, i) => _buildSectionCard(i),
// //                             ),
// //                             _buildAddSectionBtn(),
// //                             const SizedBox(height: 16),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     _buildActionBar(isEdit),
// //                   ],
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Validation banner ─────────────────────────────────────────────────────
// //   Widget _buildValidationBanner() {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 250),
// //       curve: Curves.easeOut,
// //       margin: const EdgeInsets.only(bottom: 16),
// //       padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFFEF2F2),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFFFECACA)),
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Icon(Icons.error_outline_rounded,
// //               color: Color(0xFFDC2626), size: 18),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text(
// //                   'Please fix the following before saving:',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: FontWeight.w700,
// //                     color: Color(0xFF991B1B),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 ...(_validationErrors.map(
// //                   (e) => Padding(
// //                     padding: const EdgeInsets.only(top: 3),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Padding(
// //                           padding: EdgeInsets.only(top: 5),
// //                           child: CircleAvatar(
// //                             radius: 2.5,
// //                             backgroundColor: Color(0xFFB91C1C),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 7),
// //                         Expanded(
// //                           child: Text(
// //                             e,
// //                             style: const TextStyle(
// //                               fontSize: 12,
// //                               color: Color(0xFFB91C1C),
// //                               height: 1.5,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 )),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Dialog header ─────────────────────────────────────────────────────────
// //   Widget _buildDialogHeader(bool isEdit) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.fromLTRB(16, 18, 8, 18),
// //       decoration: const BoxDecoration(
// //         color: AppColors.white,
// //         border: Border(
// //           bottom: BorderSide(color: AppColors.cborder, width: 1.5),
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 38,
// //             height: 38,
// //             decoration: BoxDecoration(
// //               color: AppColors.cxl,
// //               shape: BoxShape.circle,
// //               border: Border.all(color: AppColors.cborder),
// //             ),
// //             child: Icon(
// //               isEdit ? Icons.edit_document : Icons.note_add_outlined,
// //               color: AppColors.c3,
// //               size: 18,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   isEdit ? 'Edit Contract' : 'New Contract',
// //                   style: const TextStyle(
// //                     color: AppColors.cdark,
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //                 Text(
// //                   isEdit
// //                       ? 'Update contract details'
// //                       : 'Fill in sections & points',
// //                   style: const TextStyle(
// //                     color: AppColors.ctext,
// //                     fontSize: 11,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           GestureDetector(
// //             onTap: () => Navigator.pop(context),
// //             child: Container(
// //               width: 32,
// //               height: 32,
// //               decoration: BoxDecoration(
// //                 color: AppColors.cxl,
// //                 shape: BoxShape.circle,
// //                 border: Border.all(color: AppColors.cborder),
// //               ),
// //               child: const Icon(
// //                 Icons.close_rounded,
// //                 color: AppColors.c3,
// //                 size: 15,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Contract title field ──────────────────────────────────────────────────
// //   Widget _buildTitleField() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Row(
// //           children: [
// //             Container(
// //               width: 28,
// //               height: 28,
// //               decoration: BoxDecoration(
// //                 color: AppColors.cxl,
// //                 borderRadius: BorderRadius.circular(7),
// //               ),
// //               child: const Icon(
// //                 Icons.article_outlined,
// //                 color: AppColors.c1,
// //                 size: 15,
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             const Text(
// //               'Contract Title',
// //               style: TextStyle(
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.w700,
// //                 color: AppColors.cdark,
// //               ),
// //             ),
// //             const Text(
// //               ' *',
// //               style: TextStyle(
// //                 color: AppColors.tagRed,
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ],
// //         ),
// //         const SizedBox(height: 8),
// //         TextField(
// //           controller: contractTitleController,
// //           onChanged: (_) => _clearTitleError(),
// //           style: const TextStyle(fontSize: 14, color: AppColors.ctext),
// //           decoration: InputDecoration(
// //             hintText: 'e.g. Service Agreement 2024',
// //             hintStyle: const TextStyle(
// //               color: AppColors.ctext,
// //               fontSize: 13,
// //             ),
// //             filled: true,
// //             fillColor: _titleError ? const Color(0xFFFFF9F9) : AppColors.cxl,
// //             prefixIcon: const Icon(
// //               Icons.article_outlined,
// //               size: 18,
// //               color: AppColors.c1,
// //             ),
// //             contentPadding:
// //                 const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //               borderSide: const BorderSide(color: AppColors.cborder),
// //             ),
// //             enabledBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //               borderSide: BorderSide(
// //                 color:
// //                     _titleError ? const Color(0xFFFCA5A5) : AppColors.cborder,
// //               ),
// //             ),
// //             focusedBorder: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(10),
// //               borderSide: BorderSide(
// //                 color: _titleError ? const Color(0xFFF87171) : AppColors.c1,
// //                 width: 1.5,
// //               ),
// //             ),
// //           ),
// //         ),
// //         // Inline field-level error
// //         if (_titleError)
// //           Padding(
// //             padding: const EdgeInsets.only(top: 5, left: 4),
// //             child: Row(
// //               children: const [
// //                 Icon(Icons.info_outline_rounded,
// //                     size: 13, color: Color(0xFFDC2626)),
// //                 SizedBox(width: 4),
// //                 Text(
// //                   'Contract title is required',
// //                   style: TextStyle(
// //                     fontSize: 11,
// //                     color: Color(0xFFDC2626),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //       ],
// //     );
// //   }

// //   // ── Section card ──────────────────────────────────────────────────────────
// //   Widget _buildSectionCard(int sectionIndex) {
// //     final section = sections[sectionIndex];
// //     final hasError = _sectionTitleErrors.contains(sectionIndex);

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       decoration: BoxDecoration(
// //         color: AppColors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(
// //           color: hasError ? const Color(0xFFFCA5A5) : AppColors.cborder,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: AppColors.c1.withOpacity(0.06),
// //             blurRadius: 14,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // Section header
// //           Container(
// //             padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
// //             decoration: BoxDecoration(
// //               color: hasError ? const Color(0xFFFFF9F9) : AppColors.white,
// //               borderRadius: const BorderRadius.only(
// //                 topLeft: Radius.circular(14),
// //                 topRight: Radius.circular(14),
// //               ),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       width: 22,
// //                       height: 22,
// //                       decoration: BoxDecoration(
// //                         color: AppColors.cxl,
// //                         shape: BoxShape.circle,
// //                         border:
// //                             Border.all(color: AppColors.cborder, width: 0.8),
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           '${sectionIndex + 1}',
// //                           style: const TextStyle(
// //                             color: AppColors.ctext,
// //                             fontSize: 11,
// //                             fontWeight: FontWeight.w700,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: TextField(
// //                         controller: section.sectionTitleController,
// //                         onChanged: (_) => _clearSectionError(sectionIndex),
// //                         style: const TextStyle(
// //                           fontSize: 13,
// //                           fontWeight: FontWeight.w600,
// //                           color: AppColors.ctext,
// //                         ),
// //                         decoration: InputDecoration(
// //                           hintText: 'Section title…',
// //                           hintStyle: const TextStyle(
// //                             color: AppColors.ctext,
// //                             fontSize: 12,
// //                           ),
// //                           isDense: true,
// //                           contentPadding: const EdgeInsets.symmetric(
// //                               horizontal: 10, vertical: 10),
// //                           filled: true,
// //                           fillColor: hasError
// //                               ? const Color(0xFFFFF9F9)
// //                               : AppColors.cxl,
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                             borderSide:
// //                                 const BorderSide(color: AppColors.cborder),
// //                           ),
// //                           enabledBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                             borderSide: BorderSide(
// //                               color: hasError
// //                                   ? const Color(0xFFFCA5A5)
// //                                   : AppColors.cborder,
// //                             ),
// //                           ),
// //                           focusedBorder: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                             borderSide: BorderSide(
// //                               color: hasError
// //                                   ? const Color(0xFFF87171)
// //                                   : AppColors.c1,
// //                               width: 1.5,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     if (sections.length > 1)
// //                       GestureDetector(
// //                         onTap: () =>
// //                             setState(() => sections.removeAt(sectionIndex)),
// //                         child: Container(
// //                           margin: const EdgeInsets.only(left: 6),
// //                           width: 28,
// //                           height: 28,
// //                           decoration: BoxDecoration(
// //                             color: AppColors.tagRed.withOpacity(0.10),
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: const Icon(
// //                             Icons.delete_outline_rounded,
// //                             color: AppColors.tagRed,
// //                             size: 14,
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //                 // Inline section field error
// //                 if (hasError)
// //                   Padding(
// //                     padding: const EdgeInsets.only(top: 5, left: 32),
// //                     child: Row(
// //                       children: const [
// //                         Icon(Icons.info_outline_rounded,
// //                             size: 12, color: Color(0xFFDC2626)),
// //                         SizedBox(width: 4),
// //                         Text(
// //                           'Section title is required',
// //                           style: TextStyle(
// //                             fontSize: 11,
// //                             color: Color(0xFFDC2626),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),

// //           // Points list
// //           Padding(
// //             padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
// //             child: ListView.builder(
// //               shrinkWrap: true,
// //               physics: const NeverScrollableScrollPhysics(),
// //               itemCount: section.points.length,
// //               itemBuilder: (_, pointIndex) =>
// //                   _buildPointRow(section, pointIndex),
// //             ),
// //           ),

// //           // Add Point button
// //           Padding(
// //             padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
// //             child: GestureDetector(
// //               onTap: () =>
// //                   setState(() => section.points.add(TextEditingController())),
// //               child: Container(
// //                 padding:
// //                     const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
// //                 decoration: BoxDecoration(
// //                   color: AppColors.cxl,
// //                   borderRadius: BorderRadius.circular(20),
// //                   border: Border.all(color: AppColors.cborder),
// //                 ),
// //                 child: const Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Icon(Icons.add_rounded, color: AppColors.c1, size: 14),
// //                     SizedBox(width: 4),
// //                     Text(
// //                       'Add Point',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w600,
// //                         color: AppColors.cdark,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Point row ─────────────────────────────────────────────────────────────
// //   Widget _buildPointRow(ContractSectionModel section, int pointIndex) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 7,
// //             height: 7,
// //             decoration: const BoxDecoration(
// //               color: AppColors.c3,
// //               shape: BoxShape.circle,
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: TextField(
// //               controller: section.points[pointIndex],
// //               maxLines: 2,
// //               minLines: 1,
// //               style: const TextStyle(
// //                 fontSize: 13,
// //                 color: AppColors.ctext,
// //               ),
// //               decoration: InputDecoration(
// //                 hintText: 'Enter point…',
// //                 hintStyle: const TextStyle(
// //                   color: AppColors.ctext,
// //                   fontSize: 12,
// //                 ),
// //                 isDense: true,
// //                 filled: true,
// //                 fillColor: AppColors.cxl,
// //                 contentPadding:
// //                     const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                   borderSide: const BorderSide(color: AppColors.cborder),
// //                 ),
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                   borderSide: const BorderSide(color: AppColors.cborder),
// //                 ),
// //                 focusedBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                   borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           if (section.points.length > 1)
// //             GestureDetector(
// //               onTap: () => setState(() => section.points.removeAt(pointIndex)),
// //               child: const Padding(
// //                 padding: EdgeInsets.only(left: 6),
// //                 child:
// //                     Icon(Icons.close_rounded, size: 16, color: AppColors.ctext),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ── Add Section button ────────────────────────────────────────────────────
// //   Widget _buildAddSectionBtn() {
// //     return GestureDetector(
// //       onTap: () => setState(() => sections.add(ContractSectionModel())),
// //       child: Container(
// //         width: double.infinity,
// //         padding: const EdgeInsets.symmetric(vertical: 12),
// //         decoration: BoxDecoration(
// //           color: AppColors.white,
// //           borderRadius: BorderRadius.circular(16),
// //           border: Border.all(color: AppColors.cborder),
// //           boxShadow: [
// //             BoxShadow(
// //               color: AppColors.c1.withOpacity(0.06),
// //               blurRadius: 14,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Container(
// //               width: 24,
// //               height: 24,
// //               decoration: BoxDecoration(
// //                 color: AppColors.cxl,
// //                 shape: BoxShape.circle,
// //                 border: Border.all(color: AppColors.cborder),
// //               ),
// //               child:
// //                   const Icon(Icons.add_rounded, color: AppColors.c3, size: 14),
// //             ),
// //             const SizedBox(width: 8),
// //             const Text(
// //               'Add Section',
// //               style: TextStyle(
// //                 fontSize: 13,
// //                 fontWeight: FontWeight.w600,
// //                 color: AppColors.cdark,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Action bar ────────────────────────────────────────────────────────────
// //   Widget _buildActionBar(bool isEdit) {
// //     return Consumer<ContractViewmodel>(
// //       builder: (context, vm, _) {
// //         return Container(
// //           padding: const EdgeInsets.all(10),
// //           decoration: const BoxDecoration(
// //             border: Border(
// //               top: BorderSide(color: AppColors.cborder, width: 1),
// //             ),
// //           ),
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 flex: 1,
// //                 child: GestureDetector(
// //                   onTap: () => Navigator.pop(context),
// //                   child: Container(
// //                     height: 46,
// //                     decoration: BoxDecoration(
// //                       color: AppColors.cxl,
// //                       borderRadius: BorderRadius.circular(23),
// //                       border: Border.all(color: AppColors.cborder),
// //                     ),
// //                     child: const Center(
// //                       child: Text(
// //                         'Cancel',
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w600,
// //                           color: AppColors.cdark,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               Expanded(
// //                 flex: 2,
// //                 child: GestureDetector(
// //                   onTap:
// //                       vm.createLoading ? null : () => _submitContract(isEdit),
// //                   child: Container(
// //                     height: 46,
// //                     decoration: BoxDecoration(
// //                       color: AppColors.c1,
// //                       borderRadius: BorderRadius.circular(16),
// //                       border: Border.all(color: AppColors.cborder),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: AppColors.c1.withOpacity(0.06),
// //                           blurRadius: 14,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Center(
// //                       child: vm.createLoading
// //                           ? const SizedBox(
// //                               width: 18,
// //                               height: 18,
// //                               child: CircularProgressIndicator(
// //                                 color: AppColors.white,
// //                                 strokeWidth: 2,
// //                               ),
// //                             )
// //                           : Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(
// //                                   isEdit
// //                                       ? Icons.check_rounded
// //                                       : Icons.save_outlined,
// //                                   color: AppColors.white,
// //                                   size: 16,
// //                                 ),
// //                                 const SizedBox(width: 6),
// //                                 Text(
// //                                   isEdit
// //                                       ? 'Update Contract'
// //                                       : 'Create Contract',
// //                                   style: const TextStyle(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w700,
// //                                     color: AppColors.white,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // ── Submit ────────────────────────────────────────────────────────────────
// //   Future<void> _submitContract(bool isEdit) async {
// //     if (!_validate()) return; // shows errors inside modal, stops here

// //     List<ContractSection> apiSections = [];
// //     for (int i = 0; i < sections.length; i++) {
// //       final s = sections[i];
// //       if (s.sectionTitleController.text.trim().isEmpty) continue;
// //       List<ContractPoint> points = [];
// //       for (int j = 0; j < s.points.length; j++) {
// //         final text = s.points[j].text.trim();
// //         if (text.isEmpty) continue;
// //         points.add(ContractPoint(content: text, order: j + 1));
// //       }
// //       apiSections.add(ContractSection(
// //         title: s.sectionTitleController.text.trim(),
// //         order: i + 1,
// //         points: points,
// //       ));
// //     }

// //     final updatedContract = ContractModel(
// //       id: widget.contract?.id,
// //       name: contractTitleController.text.trim(),
// //       isActive: true,
// //       sections: apiSections,
// //     );

// //     final vm = Provider.of<ContractViewmodel>(context, listen: false);
// //     final success = isEdit
// //         ? await vm.editContract(updatedContract)
// //         : await vm.createContract(updatedContract);

// //     if (success) {
// //       if (isEdit) {
// //         vm.currentContract = updatedContract;
// //         vm.notifyListeners();
// //       }
// //       if (!mounted) return;
// //       Navigator.pop(context);
// //       showSuccessMessage(
// //         context,
// //         isEdit
// //             ? 'Contract updated successfully'
// //             : 'Contract created successfully',
// //       );
// //     } else {
// //       // API failure — show inside banner
// //       setState(() {
// //         _validationErrors = ['Failed to save contract. Please try again.'];
// //       });
// //     }
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:pokakbilling/models/contract/contract_model.dart';
// import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
// import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/client_contract_model.dart';

// class ContractDetailsDialog extends StatefulWidget {
//   final ContractModel? contract;
//   const ContractDetailsDialog({super.key, this.contract});

//   @override
//   State<ContractDetailsDialog> createState() => _ContractDetailsDialogState();
// }

// class _ContractDetailsDialogState extends State<ContractDetailsDialog>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController contractTitleController = TextEditingController();
//   List<ContractSectionModel> sections = [ContractSectionModel()];

//   late final AnimationController _animCtrl;
//   late final Animation<double> _scaleAnim;
//   late final Animation<double> _fadeAnim;

//   // ── Validation state ──────────────────────────────────────────────────────
//   String? _errTitle;
//   Map<int, String?> _errSectionTitles = {};

//   @override
//   void initState() {
//     super.initState();

//     _animCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
//       CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
//     );
//     _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
//     _animCtrl.forward();

//     if (widget.contract != null) {
//       contractTitleController.text = widget.contract!.name;
//       sections = widget.contract!.sections.map((s) {
//         final section = ContractSectionModel();
//         section.sectionTitleController.text = s.title;
//         section.points = s.points.map((p) {
//           final controller = TextEditingController();
//           controller.text = p.content;
//           return controller;
//         }).toList();
//         return section;
//       }).toList();
//     }
//   }

//   @override
//   void dispose() {
//     _animCtrl.dispose();
//     contractTitleController.dispose();
//     super.dispose();
//   }

//   // ── Validation ────────────────────────────────────────────────────────────
//   bool _validate() {
//     final titleErr = contractTitleController.text.trim().isEmpty
//         ? 'Contract title is required'
//         : null;

//     final Map<int, String?> sectionErrs = {};
//     for (int i = 0; i < sections.length; i++) {
//       if (sections[i].sectionTitleController.text.trim().isEmpty) {
//         sectionErrs[i] = 'Section title is required';
//       }
//     }

//     setState(() {
//       _errTitle = titleErr;
//       _errSectionTitles = sectionErrs;
//     });

//     return titleErr == null && sectionErrs.isEmpty;
//   }

//   // ── Shared InputDecoration (mirrors _field in CreateNewCustomer) ──────────
//   InputDecoration _fieldDecoration(
//     String label,
//     IconData icon, {
//     bool isRequired = false,
//     bool hasError = false,
//     String? hintText,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hintText,
//       labelStyle: TextStyle(
//         fontSize: 13,
//         color: AppColors.ctext.withOpacity(0.75),
//       ),
//       hintStyle: TextStyle(
//         fontSize: 13,
//         color: AppColors.ctext.withOpacity(0.55),
//       ),
//       prefixIcon: Icon(
//         icon,
//         size: 18,
//         color: hasError ? AppColors.red : AppColors.c1,
//       ),
//       suffixIcon: isRequired
//           ? Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: Icon(Icons.circle, size: 6, color: AppColors.red),
//             )
//           : null,
//       suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//       filled: true,
//       fillColor: hasError ? AppColors.red.withOpacity(0.04) : AppColors.cxl,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//           color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//           color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(
//           color: hasError ? AppColors.red : AppColors.c1,
//           width: 1.5,
//         ),
//       ),
//     );
//   }

//   // ── Inline error row (mirrors CreateNewCustomer) ──────────────────────────
//   Widget _inlineError(String message) {
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
//               message,
//               style: const TextStyle(
//                 fontSize: 12,
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

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.contract != null;

//     return FadeTransition(
//       opacity: _fadeAnim,
//       child: ScaleTransition(
//         scale: _scaleAnim,
//         child: Dialog(
//           insetPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//           backgroundColor: AppColors.white,
//           elevation: 0,
//           insetAnimationDuration: const Duration(milliseconds: 200),
//           insetAnimationCurve: Curves.easeOut,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final viewInsets = MediaQuery.of(context).viewInsets;
//               final screenH = MediaQuery.of(context).size.height;
//               final maxH = screenH -
//                   viewInsets.bottom -
//                   MediaQuery.of(context).padding.top -
//                   48;

//               return Container(
//                 constraints: BoxConstraints(maxHeight: maxH < 400 ? 400 : maxH),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.cborder),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.c1.withOpacity(0.06),
//                       blurRadius: 14,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 clipBehavior: Clip.hardEdge,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     _buildDialogHeader(isEdit),
//                     Flexible(
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // ── Contract Title ────────────────────────────
//                             _buildSectionBlock(
//                               icon: Icons.article_outlined,
//                               title: 'Contract Title',
//                               children: [
//                                 _buildTitleField(),
//                               ],
//                             ),
//                             const SizedBox(height: 14),
//                             // ── Sections ──────────────────────────────────
//                             _buildSectionBlock(
//                               icon: Icons.list_alt_rounded,
//                               title: 'Contract Sections',
//                               children: [
//                                 ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: sections.length,
//                                   itemBuilder: (_, i) => _buildSectionCard(i),
//                                 ),
//                                 _buildAddSectionBtn(),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//                         ),
//                       ),
//                     ),
//                     _buildActionBar(isEdit),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Dialog header ─────────────────────────────────────────────────────────
//   Widget _buildDialogHeader(bool isEdit) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 18, 8, 18),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom: BorderSide(color: AppColors.cborder, width: 1.5),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: AppColors.cxl,
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.cborder),
//             ),
//             child: Icon(
//               isEdit ? Icons.edit_document : Icons.note_add_outlined,
//               color: AppColors.c3,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isEdit ? 'Edit Contract' : 'New Contract',
//                   style: const TextStyle(
//                     color: AppColors.cdark,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 Text(
//                   isEdit
//                       ? 'Update contract details'
//                       : 'Fill in sections & points',
//                   style: const TextStyle(
//                     color: AppColors.ctext,
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: const Icon(
//                 Icons.close_rounded,
//                 color: AppColors.c3,
//                 size: 15,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Section block (card wrapper — mirrors _buildSection in new client) ─────
//   Widget _buildSectionBlock({
//     required IconData icon,
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: AppColors.cdark,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 20, thickness: 1, color: AppColors.cborder),
//           ...children,
//         ],
//       ),
//     );
//   }

//   // ── Contract title field ──────────────────────────────────────────────────
//   Widget _buildTitleField() {
//     final hasError = _errTitle != null && _errTitle!.isNotEmpty;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextField(
//           controller: contractTitleController,
//           onChanged: (_) {
//             if (_errTitle != null) setState(() => _errTitle = null);
//           },
//           style: const TextStyle(fontSize: 14, color: AppColors.cdark),
//           decoration: _fieldDecoration(
//             'Contract Title',
//             Icons.article_outlined,
//             isRequired: true,
//             hasError: hasError,
//             hintText: 'e.g. Service Agreement 2024',
//           ),
//         ),
//         if (hasError) _inlineError(_errTitle!),
//       ],
//     );
//   }

//   // ── Section card ──────────────────────────────────────────────────────────
//   Widget _buildSectionCard(int sectionIndex) {
//     final section = sections[sectionIndex];
//     final sectionErr = _errSectionTitles[sectionIndex];
//     final hasError = sectionErr != null && sectionErr.isNotEmpty;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: hasError ? AppColors.red.withOpacity(0.60) : AppColors.cborder,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.c1.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Section number + title field row ──────────────────────────
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Number badge
//               Container(
//                 width: 28,
//                 height: 48,
//                 alignment: Alignment.center,
//                 child: Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: AppColors.cxl,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: AppColors.cborder, width: 0.8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${sectionIndex + 1}',
//                       style: const TextStyle(
//                         color: AppColors.ctext,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // Title text field
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextField(
//                       controller: section.sectionTitleController,
//                       onChanged: (_) {
//                         if (_errSectionTitles.containsKey(sectionIndex)) {
//                           setState(
//                               () => _errSectionTitles.remove(sectionIndex));
//                         }
//                       },
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: AppColors.cdark,
//                       ),
//                       decoration: _fieldDecoration(
//                         'Section Title',
//                         Icons.segment_rounded,
//                         isRequired: true,
//                         hasError: hasError,
//                       ),
//                     ),
//                     if (hasError) _inlineError(sectionErr),
//                   ],
//                 ),
//               ),
//               // Delete section button
//               if (sections.length > 1)
//                 Padding(
//                   padding: const EdgeInsets.only(left: 8, top: 10),
//                   child: GestureDetector(
//                     onTap: () =>
//                         setState(() => sections.removeAt(sectionIndex)),
//                     child: Container(
//                       width: 32,
//                       height: 32,
//                       decoration: BoxDecoration(
//                         color: AppColors.tagRed.withOpacity(0.10),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.delete_outline_rounded,
//                         color: AppColors.tagRed,
//                         size: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // ── Points ────────────────────────────────────────────────────
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: section.points.length,
//             itemBuilder: (_, pointIndex) => _buildPointRow(section, pointIndex),
//           ),

//           // ── Add Point button ──────────────────────────────────────────
//           GestureDetector(
//             onTap: () =>
//                 setState(() => section.points.add(TextEditingController())),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.add_rounded, color: AppColors.c1, size: 14),
//                   SizedBox(width: 4),
//                   Text(
//                     'Add Point',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.cdark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Point row ─────────────────────────────────────────────────────────────
//   Widget _buildPointRow(ContractSectionModel section, int pointIndex) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 7,
//             height: 7,
//             decoration: const BoxDecoration(
//               color: AppColors.c3,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: section.points[pointIndex],
//               maxLines: 2,
//               minLines: 1,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColors.cdark,
//               ),
//               decoration: _fieldDecoration(
//                 'Point',
//                 Icons.short_text_rounded,
//                 hintText: 'Enter point…',
//               ),
//             ),
//           ),
//           if (section.points.length > 1)
//             GestureDetector(
//               onTap: () => setState(() => section.points.removeAt(pointIndex)),
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: AppColors.tagRed.withOpacity(0.10),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.close_rounded,
//                     size: 14,
//                     color: AppColors.tagRed,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // ── Add Section button ────────────────────────────────────────────────────
//   Widget _buildAddSectionBtn() {
//     return GestureDetector(
//       onTap: () => setState(() => sections.add(ContractSectionModel())),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 13),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.cborder),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.c1.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 24,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child:
//                   const Icon(Icons.add_rounded, color: AppColors.c3, size: 14),
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Add Section',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.cdark,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Action bar ────────────────────────────────────────────────────────────
//   Widget _buildActionBar(bool isEdit) {
//     return Consumer<ContractViewmodel>(
//       builder: (context, vm, _) {
//         final isLoading = vm.createLoading;
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: const BoxDecoration(
//             color: AppColors.white,
//             border: Border(
//               top: BorderSide(color: AppColors.cborder, width: 1),
//             ),
//           ),
//           child: Row(
//             children: [
//               // Cancel
//               Expanded(
//                 flex: 1,
//                 child: GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: AppColors.cxl,
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(color: AppColors.cborder),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.cdark,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               // Save / Update
//               Expanded(
//                 flex: 2,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: AppColors.c1,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.c1.withOpacity(0.30),
//                         blurRadius: 14,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : () => _submitContract(isEdit),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       shadowColor: Colors.transparent,
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(24),
//                       ),
//                     ),
//                     child: isLoading
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                               color: AppColors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 isEdit
//                                     ? Icons.check_rounded
//                                     : Icons.save_outlined,
//                                 color: AppColors.white,
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 isEdit ? 'Update Contract' : 'Create Contract',
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColors.white,
//                                   letterSpacing: 0.4,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ── Submit ────────────────────────────────────────────────────────────────
//   Future<void> _submitContract(bool isEdit) async {
//     if (!_validate()) return;

//     final List<ContractSection> apiSections = [];
//     for (int i = 0; i < sections.length; i++) {
//       final s = sections[i];
//       if (s.sectionTitleController.text.trim().isEmpty) continue;
//       final List<ContractPoint> points = [];
//       for (int j = 0; j < s.points.length; j++) {
//         final text = s.points[j].text.trim();
//         if (text.isEmpty) continue;
//         points.add(ContractPoint(content: text, order: j + 1));
//       }
//       apiSections.add(ContractSection(
//         title: s.sectionTitleController.text.trim(),
//         order: i + 1,
//         points: points,
//       ));
//     }

//     final updatedContract = ContractModel(
//       id: widget.contract?.id,
//       name: contractTitleController.text.trim(),
//       isActive: true,
//       sections: apiSections,
//     );

//     final vm = Provider.of<ContractViewmodel>(context, listen: false);
//     final success = isEdit
//         ? await vm.editContract(updatedContract)
//         : await vm.createContract(updatedContract);

//     if (success) {
//       if (isEdit) {
//         vm.currentContract = updatedContract;
//         vm.notifyListeners();
//       }
//       if (!mounted) return;
//       Navigator.pop(context);
//       showSuccessMessage(
//         context,
//         isEdit
//             ? 'Contract updated successfully'
//             : 'Contract created successfully',
//       );
//     } else {
//       setState(() {
//         _errTitle = 'Failed to save contract. Please try again.';
//       });
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/models/contract/contract_model.dart';
import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
import 'package:pokakbilling/views/commonWidgets/response-message/success-message.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/client_contract_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContractDetailsPage  — Full-screen page (replaces the old Dialog)
//
// NAVIGATION:
//   // Open from CreateNewCustomer add-button:
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => ChangeNotifierProvider.value(
//         value: context.read<ContractViewmodel>(),
//         child: const ContractDetailsPage(),
//       ),
//     ),
//   );
//
//   // To edit an existing contract pass it in:
//   ContractDetailsPage(contract: existingContract)
// ─────────────────────────────────────────────────────────────────────────────

class ContractDetailsPage extends StatefulWidget {
  final ContractModel? contract;
  const ContractDetailsPage({super.key, this.contract});

  @override
  State<ContractDetailsPage> createState() => _ContractDetailsPageState();
}

class _ContractDetailsPageState extends State<ContractDetailsPage>
    with SingleTickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  final TextEditingController _titleCtrl = TextEditingController();
  List<ContractSectionModel> _sections = [ContractSectionModel()];

  // ── Entrance animation ────────────────────────────────────────────────────
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Validation ────────────────────────────────────────────────────────────
  String? _errTitle;
  Map<int, String?> _errSectionTitles = {};

  // ── Init ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    if (widget.contract != null) {
      _titleCtrl.text = widget.contract!.name;
      _sections = widget.contract!.sections.map((s) {
        final section = ContractSectionModel();
        section.sectionTitleController.text = s.title;
        section.points = s.points.map((p) {
          final c = TextEditingController();
          c.text = p.content;
          return c;
        }).toList();
        return section;
      }).toList();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validate() {
    String? titleErr;
    final Map<int, String?> sectionErrs = {};

    if (_titleCtrl.text.trim().isEmpty) {
      titleErr = 'Contract title is required';
    }

    for (int i = 0; i < _sections.length; i++) {
      if (_sections[i].sectionTitleController.text.trim().isEmpty) {
        sectionErrs[i] = 'Section title is required';
      }
    }

    setState(() {
      _errTitle = titleErr;
      _errSectionTitles = sectionErrs;
    });

    return titleErr == null && sectionErrs.isEmpty;
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submitContract(bool isEdit, ContractViewmodel vm) async {
    if (!_validate()) return;

    final apiSections = <ContractSection>[];
    for (int i = 0; i < _sections.length; i++) {
      final s = _sections[i];
      if (s.sectionTitleController.text.trim().isEmpty) continue;
      final points = <ContractPoint>[];
      for (int j = 0; j < s.points.length; j++) {
        final text = s.points[j].text.trim();
        if (text.isEmpty) continue;
        points.add(ContractPoint(content: text, order: j + 1));
      }
      apiSections.add(ContractSection(
        title: s.sectionTitleController.text.trim(),
        order: i + 1,
        points: points,
      ));
    }

    final updatedContract = ContractModel(
      id: widget.contract?.id,
      name: _titleCtrl.text.trim(),
      isActive: true,
      sections: apiSections,
    );

    final success = isEdit
        ? await vm.editContract(updatedContract)
        : await vm.createContract(updatedContract);

    if (success) {
      if (isEdit) {
        vm.currentContract = updatedContract;
        vm.notifyListeners();
      }
      if (!mounted) return;
      Navigator.pop(context);
      showSuccessMessage(
        context,
        isEdit
            ? 'Contract updated successfully'
            : 'Contract created successfully',
      );
    } else {
      // Show API error inline under title field
      setState(() {
        _errTitle = 'Failed to save contract. Please try again.';
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contract != null;
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<ContractViewmodel>(
        builder: (context, vm, _) {
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeader(context, sw, topPad, isEdit),

                // ── Scrollable body ──────────────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          children: [
                            // ── Contract Title ───────────────────────────
                            _buildSection(
                              icon: Icons.article_outlined,
                              title: 'Contract Title',
                              children: [
                                _field(
                                  _titleCtrl,
                                  'Contract Title',
                                  Icons.article_outlined,
                                  hint: 'e.g. Service Agreement 2024',
                                  isRequired: true,
                                  error: _errTitle,
                                  onChanged: (_) {
                                    if (_errTitle != null) {
                                      setState(() => _errTitle = null);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // ── Sections ─────────────────────────────────
                            _buildSection(
                              icon: Icons.list_alt_rounded,
                              title: 'Contract Sections',
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _sections.length,
                                  itemBuilder: (_, i) => _buildSectionCard(i),
                                ),
                                _buildAddSectionBtn(),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Save bar ─────────────────────────────────
                            _buildSaveBar(isEdit, vm),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header (identical layout to CreateNewCustomer) ────────────────────────
  Widget _buildHeader(
      BuildContext context, double sw, double topPad, bool isEdit) {
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
              Text(
                isEdit ? 'Edit Contract' : 'New Contract',
                style: const TextStyle(
                  color: AppColors.cdark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                isEdit
                    ? 'Update contract details'
                    : 'Fill in sections & points',
                style: const TextStyle(color: AppColors.ctext, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section card wrapper (identical to CreateNewCustomer) ─────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: AppColors.cborder),
          ...children,
        ],
      ),
    );
  }

  // ── Reusable text field — IDENTICAL to CreateNewCustomer._field() ─────────
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    int minLines = 1,
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
            maxLines: maxLines,
            minLines: minLines,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.cdark),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.ctext.withOpacity(0.55),
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                color: AppColors.ctext.withOpacity(0.75),
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
                      : AppColors.cborder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColors.red.withOpacity(0.60)
                      : AppColors.cborder,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError ? AppColors.red : AppColors.c1,
                  width: 1.5,
                ),
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
                    child: Text(
                      error,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Individual section card ───────────────────────────────────────────────
  Widget _buildSectionCard(int sectionIndex) {
    final section = _sections[sectionIndex];
    final sectionErr = _errSectionTitles[sectionIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (sectionErr != null)
              ? AppColors.red.withOpacity(0.60)
              : AppColors.cborder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header row ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                // Section number badge
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: Center(
                    child: Text(
                      '${sectionIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.c1,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Section',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ctext,
                  ),
                ),
                const Spacer(),
                if (_sections.length > 1)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _sections.removeAt(sectionIndex);
                        _errSectionTitles.remove(sectionIndex);
                      });
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.tagRed.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.tagRed,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Section title field ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _field(
              section.sectionTitleController,
              'Section Title',
              Icons.title_rounded,
              isRequired: true,
              error: sectionErr,
              onChanged: (_) {
                if (_errSectionTitles.containsKey(sectionIndex)) {
                  setState(() => _errSectionTitles.remove(sectionIndex));
                }
              },
            ),
          ),

          // ── Points list ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.points.length,
              itemBuilder: (_, pointIndex) =>
                  _buildPointRow(section, pointIndex),
            ),
          ),

          // ── Add Point button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GestureDetector(
              onTap: () =>
                  setState(() => section.points.add(TextEditingController())),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cborder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_rounded, color: AppColors.c1, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Add Point',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cdark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Point row — uses same _field style ────────────────────────────────────
  Widget _buildPointRow(ContractSectionModel section, int pointIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bullet dot
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.c3,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: section.points[pointIndex],
              maxLines: 2,
              minLines: 1,
              cursorColor: AppColors.c1,
              style: const TextStyle(fontSize: 14, color: AppColors.cdark),
              decoration: InputDecoration(
                labelText: 'Point ${pointIndex + 1}',
                hintText: 'Enter point…',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.ctext.withOpacity(0.55),
                ),
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.ctext.withOpacity(0.75),
                ),
                isDense: false,
                filled: true,
                fillColor: AppColors.cxl,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cborder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cborder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.c1, width: 1.5),
                ),
              ),
            ),
          ),
          if (section.points.length > 1)
            GestureDetector(
              onTap: () => setState(() => section.points.removeAt(pointIndex)),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child:
                    Icon(Icons.close_rounded, size: 18, color: AppColors.ctext),
              ),
            ),
        ],
      ),
    );
  }

  // ── Add Section button ────────────────────────────────────────────────────
  Widget _buildAddSectionBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: GestureDetector(
        onTap: () => setState(() => _sections.add(ContractSectionModel())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.cborder, style: BorderStyle.solid),
            boxShadow: [
              BoxShadow(
                color: AppColors.c1.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.cxl,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cborder),
                ),
                child: const Icon(Icons.add_rounded,
                    color: AppColors.c3, size: 14),
              ),
              const SizedBox(width: 8),
              const Text(
                'Add Section',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cdark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save bar (identical height/style to CreateNewCustomer) ────────────────
  Widget _buildSaveBar(bool isEdit, ContractViewmodel vm) {
    final isLoading = vm.createLoading;

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
          onPressed: isLoading ? null : () => _submitContract(isEdit, vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: AppColors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEdit ? Icons.check_rounded : Icons.save_outlined,
                      color: AppColors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEdit ? 'Save Changes' : 'Create Contract',
                      style: const TextStyle(
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
