// // lib/views/Screens/marketing/report/filterScreen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';

// class MarketingReportFilterPage extends StatefulWidget {
//   const MarketingReportFilterPage({super.key});

//   @override
//   State<MarketingReportFilterPage> createState() =>
//       _MarketingReportFilterPageState();
// }

// class _MarketingReportFilterPageState extends State<MarketingReportFilterPage> {
//   final DateFormat _displayFormat = DateFormat('dd - MM - yyyy');
//   final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

//   final TextEditingController _fromController = TextEditingController();
//   final TextEditingController _toController = TextEditingController();

//   int? _selectedSourceId;
//   int? _selectedCategoryId;
//   int? _selectedLocationId;
//   int? _selectedSalespersonId;

//   static const Color uiColor = Color(0xFF6A7282);
//   static const Color fieldBorderColor = Color(0xFFE6E6EA);
//   static const double baseFieldHeight = 40.0;
//   static const double fieldRadius = 8.0;

//   static const TextStyle headingStyle =
//       TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: uiColor);
//   static const TextStyle fieldTextStyle = TextStyle(
//       fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87);

//   @override
//   void initState() {
//     super.initState();
//     final vm = context.read<MarketingReportViewmodel>();
//     if (vm.fromDate != null && vm.fromDate!.isNotEmpty) {
//       _fromController.text = vm.fromDate!;
//     }
//     if (vm.toDate != null && vm.toDate!.isNotEmpty) {
//       _toController.text = vm.toDate!;
//     }
//     _selectedSourceId = vm.selectedSourceId;
//     _selectedCategoryId = vm.selectedCategoryId;
//     _selectedLocationId = vm.selectedLocationId;
//     _selectedSalespersonId = vm.selectedSalespersonId;
//   }

//   @override
//   void dispose() {
//     _fromController.dispose();
//     _toController.dispose();
//     super.dispose();
//   }

//   // ── Apply current LOCAL dropdown state to a list of reports ──
//   // Called at export time so Export always reflects what's selected
//   // right now — even before "Save" is pressed.
//   List<MarketingReport> _applyLocalSelections(
//       List<MarketingReport> allReports) {
//     final apiFormat = DateFormat('yyyy-MM-dd');
//     DateTime? from;
//     DateTime? to;
//     try {
//       if (_fromController.text.isNotEmpty) {
//         from = apiFormat.parse(_fromController.text);
//       }
//     } catch (_) {}
//     try {
//       if (_toController.text.isNotEmpty) {
//         to = apiFormat.parse(_toController.text);
//       }
//     } catch (_) {}

//     return allReports.where((r) {
//       if (_selectedSourceId != null && r.sourceId != _selectedSourceId) {
//         return false;
//       }
//       if (_selectedCategoryId != null && r.categoryId != _selectedCategoryId) {
//         return false;
//       }
//       if (_selectedLocationId != null && r.locationId != _selectedLocationId) {
//         return false;
//       }
//       if (_selectedSalespersonId != null &&
//           r.salespersonId != _selectedSalespersonId) {
//         return false;
//       }
//       if (from != null || to != null) {
//         try {
//           final rd = apiFormat.parse(r.date);
//           if (from != null && rd.isBefore(from!)) return false;
//           if (to != null && rd.isAfter(to!)) return false;
//         } catch (_) {
//           return false;
//         }
//       }
//       return true;
//     }).toList();
//   }

//   // ── PDF Export ──
//   Future<void> _exportToPdf(BuildContext context) async {
//     final vm = context.read<MarketingReportViewmodel>();

//     // Filter the current vm reports by local selections
//     final filteredReports = _applyLocalSelections(vm.reports);

//     if (filteredReports.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No data to export for the selected filters.'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     final pdf = pw.Document();

//     // Build filter summary line for PDF header
//     String filterSummary = 'All Reports';
//     final summaryParts = <String>[];
//     if (_fromController.text.isNotEmpty) {
//       summaryParts.add('From: ${_fromController.text}');
//     }
//     if (_toController.text.isNotEmpty) {
//       summaryParts.add('To: ${_toController.text}');
//     }
//     if (summaryParts.isNotEmpty) {
//       filterSummary = summaryParts.join('  |  ');
//     }

//     const tableHeaders = [
//       'Date',
//       'Salesperson',
//       'Source',
//       'Location',
//       'Category',
//       'Calls',
//       'Leads',
//     ];

//     final tableData = filteredReports
//         .map((r) => [
//               r.date,
//               r.salesperson,
//               r.source,
//               r.location,
//               r.category,
//               '${r.calls}',
//               '${r.leads}',
//             ])
//         .toList();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4.landscape,
//         margin: const pw.EdgeInsets.all(24),
//         header: (ctx) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text(
//               'Marketing Reports',
//               style: pw.TextStyle(
//                 fontSize: 18,
//                 fontWeight: pw.FontWeight.bold,
//                 color: const PdfColor.fromInt(0xFF643CB5),
//               ),
//             ),
//             pw.SizedBox(height: 4),
//             pw.Text(
//               filterSummary,
//               style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
//             ),
//             pw.SizedBox(height: 4),
//             pw.Text(
//               'Total Records: ${filteredReports.length}',
//               style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
//             ),
//             pw.Divider(color: const PdfColor.fromInt(0xFF643CB5), thickness: 1),
//             pw.SizedBox(height: 6),
//           ],
//         ),
//         build: (ctx) => [
//           pw.Table(
//             border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
//             columnWidths: {
//               0: const pw.FlexColumnWidth(1.2),
//               1: const pw.FlexColumnWidth(1.8),
//               2: const pw.FlexColumnWidth(1.4),
//               3: const pw.FlexColumnWidth(1.4),
//               4: const pw.FlexColumnWidth(1.8),
//               5: const pw.FlexColumnWidth(0.8),
//               6: const pw.FlexColumnWidth(0.8),
//             },
//             children: [
//               // Header row
//               pw.TableRow(
//                 decoration:
//                     const pw.BoxDecoration(color: PdfColor.fromInt(0xFF643CB5)),
//                 children: tableHeaders
//                     .map((h) => pw.Padding(
//                           padding: const pw.EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 6),
//                           child: pw.Text(h,
//                               style: pw.TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: PdfColors.white,
//                               )),
//                         ))
//                     .toList(),
//               ),
//               // Data rows — alternating background
//               ...tableData.asMap().entries.map((entry) {
//                 final isEven = entry.key % 2 == 0;
//                 return pw.TableRow(
//                   decoration: pw.BoxDecoration(
//                     color: isEven
//                         ? PdfColors.white
//                         : const PdfColor.fromInt(0xFFF5EEFF),
//                   ),
//                   children: entry.value
//                       .map((cell) => pw.Padding(
//                             padding: const pw.EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 5),
//                             child: pw.Text(cell,
//                                 style: const pw.TextStyle(fontSize: 9)),
//                           ))
//                       .toList(),
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (format) async => pdf.save(),
//       name: 'marketing_reports_${DateTime.now().millisecondsSinceEpoch}.pdf',
//     );
//   }

//   Future<void> _pickDate(
//     BuildContext context,
//     TextEditingController controller, {
//     DateTime? firstDate,
//     DateTime? lastDate,
//   }) async {
//     DateTime now = DateTime.now();
//     DateTime initialDate = now;
//     try {
//       if (controller.text.isNotEmpty) {
//         initialDate = _apiFormat.parse(controller.text);
//       }
//     } catch (_) {}

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate ?? DateTime(now.year - 10),
//       lastDate: lastDate ?? DateTime(now.year + 10),
//     );

//     if (picked != null) {
//       controller.text = _apiFormat.format(picked);
//       setState(() {});
//     }
//   }

//   InputDecoration _inputDecoration({
//     required String hint,
//     IconData? prefixIcon,
//     Widget? suffix,
//     double horizontalPadding = 16,
//     double verticalPadding = 14,
//   }) {
//     return InputDecoration(
//       isDense: true,
//       contentPadding: EdgeInsets.symmetric(
//           horizontal: horizontalPadding, vertical: verticalPadding),
//       hintText: hint,
//       hintStyle: fieldTextStyle.copyWith(color: uiColor.withOpacity(0.7)),
//       prefixIcon: prefixIcon != null
//           ? Padding(
//               padding: const EdgeInsets.only(left: 10, right: 8),
//               child: Icon(prefixIcon, size: 20, color: uiColor),
//             )
//           : null,
//       prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
//       suffixIcon: suffix,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(fieldRadius),
//         borderSide: const BorderSide(color: fieldBorderColor, width: 1.4),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(fieldRadius),
//         borderSide: const BorderSide(color: fieldBorderColor, width: 1.2),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(fieldRadius),
//         borderSide: BorderSide(
//             color: AppColors.violetblue.withOpacity(0.9), width: 1.6),
//       ),
//       filled: true,
//       fillColor: Colors.white,
//     );
//   }

//   Widget _fieldLabel(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(text.toUpperCase(), style: headingStyle),
//     );
//   }

//   Widget _buildDropdown<T>({
//     required String label,
//     required List<T> items,
//     required int? selectedId,
//     required void Function(int?) onChanged,
//     required String Function(T) getName,
//     required int Function(T) getId,
//     required IconData icon,
//     String? hint,
//     double fieldHeight = baseFieldHeight,
//   }) {
//     final itemList = items.map((item) {
//       return DropdownMenuItem<int>(
//         value: getId(item),
//         child: Text(getName(item), style: fieldTextStyle),
//       );
//     }).toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _fieldLabel(label),
//         SizedBox(
//           height: fieldHeight,
//           child: DropdownButtonFormField<int>(
//             isExpanded: true,
//             initialValue: selectedId,
//             style: fieldTextStyle,
//             dropdownColor: Colors.white,
//             icon:
//                 const Icon(Icons.keyboard_arrow_down, size: 18, color: uiColor),
//             items: itemList,
//             onChanged: onChanged,
//             decoration: _inputDecoration(
//               hint: hint ?? 'Choose',
//               prefixIcon: icon,
//               horizontalPadding: 14,
//               verticalPadding: 12,
//             ),
//             hint: Text(hint ?? 'Choose',
//                 style:
//                     fieldTextStyle.copyWith(color: uiColor.withOpacity(0.6))),
//           ),
//         ),
//       ],
//     );
//   }

//   void _clearAllFilters() {
//     setState(() {
//       _fromController.text = '';
//       _toController.text = '';
//       _selectedSourceId = null;
//       _selectedCategoryId = null;
//       _selectedLocationId = null;
//       _selectedSalespersonId = null;
//     });
//     context.read<MarketingReportViewmodel>().clearFilters();
//     Navigator.of(context).pop('clear');
//   }

//   void _saveFilters() {
//     final from = _fromController.text.isNotEmpty ? _fromController.text : null;
//     final to = _toController.text.isNotEmpty ? _toController.text : null;

//     context.read<MarketingReportViewmodel>().applyFilters(
//           from: from,
//           to: to,
//           sourceId: _selectedSourceId,
//           categoryId: _selectedCategoryId,
//           locationId: _selectedLocationId,
//           salespersonId: _selectedSalespersonId,
//         );

//     Navigator.of(context).pop('save');
//   }

//   String formatDisplay(String apiDate) {
//     try {
//       final dt = _apiFormat.parse(apiDate);
//       return _displayFormat.format(dt);
//     } catch (_) {
//       return apiDate;
//     }
//   }

//   Widget _dateBox({
//     required String label,
//     required TextEditingController controller,
//     required VoidCallback onTap,
//     required IconData icon,
//     double fieldHeight = baseFieldHeight,
//     double? textSize,
//   }) {
//     final text = controller.text.isEmpty ? '' : formatDisplay(controller.text);
//     final double effectiveFontSize = textSize ?? fieldTextStyle.fontSize ?? 15;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _fieldLabel(label),
//         GestureDetector(
//           onTap: onTap,
//           child: Container(
//             height: fieldHeight,
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(fieldRadius),
//               border: Border.all(color: fieldBorderColor, width: 1.2),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     text.isEmpty ? 'dd - mm - yyyy' : text,
//                     style: text.isEmpty
//                         ? fieldTextStyle.copyWith(
//                             color: Colors.black, fontSize: effectiveFontSize)
//                         : fieldTextStyle.copyWith(fontSize: effectiveFontSize),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 if (text.isNotEmpty)
//                   GestureDetector(
//                     onTap: () => setState(() => controller.text = ''),
//                     child: const Padding(
//                       padding: EdgeInsets.only(right: 8.0),
//                       child: Icon(Icons.clear, size: 20, color: Colors.black38),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 6),
//                   child: Icon(icon, size: 18, color: Colors.black),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sourceVm = Provider.of<SourceViewmodel>(context);
//     final categoryVm = Provider.of<CategoryMarketingViewmodel>(context);
//     final locationVm = Provider.of<LocationViewmodel>(context);
//     final salespersonVm = Provider.of<SalesPersonViewmodel>(context);

//     final sources = sourceVm.sources ?? [];
//     final categories = categoryVm.categories ?? [];
//     final locations = locationVm.locations ?? [];
//     final salespersons = salespersonVm.salesPersonList;

//     final screenH = MediaQuery.of(context).size.height;
//     final double adaptiveFieldHeight =
//         (screenH > 800) ? baseFieldHeight + 10 : baseFieldHeight;
//     final double verticalSpacing = (screenH > 820) ? 18.0 : 12.0;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         elevation: 0,
//         centerTitle: false,
//         titleSpacing: 0,
//         automaticallyImplyLeading: false,
//         title: const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(width: 4),
//             Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Text(
//                 'Marketing Reports',
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // ── Export: uses _applyLocalSelections so it always exports
//           //    exactly what the current dropdowns reflect ──
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: SizedBox(
//               height: 30,
//               width: 82,
//               child: TextButton.icon(
//                 onPressed: () => _exportToPdf(context),
//                 icon: const Icon(Icons.upload_outlined,
//                     size: 16, color: AppColors.violetblue),
//                 label: const Text(
//                   'Export',
//                   style: TextStyle(
//                     color: AppColors.violetblue,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//                 style: TextButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   padding: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Filters header strip
//             Container(
//               width: double.infinity,
//               height: 39,
//               color: const Color(0xFFF0E8FF),
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.filter_alt_outlined,
//                       color: Colors.black, size: 20),
//                   const SizedBox(width: 8),
//                   const Expanded(
//                     child: Text(
//                       'Filters',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () => Navigator.of(context).pop(),
//                     borderRadius: BorderRadius.circular(16),
//                     child: const SizedBox(
//                       height: 28,
//                       width: 28,
//                       child: Icon(Icons.close, size: 12, color: Colors.black54),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Scrollable filter form
//             Expanded(
//               child: LayoutBuilder(builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
//                   physics: const BouncingScrollPhysics(),
//                   child: ConstrainedBox(
//                     constraints:
//                         BoxConstraints(minHeight: constraints.maxHeight - 36),
//                     child: IntrinsicHeight(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(2),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 118,
//                                       child: _dateBox(
//                                         label: 'FROM DATE',
//                                         controller: _fromController,
//                                         onTap: () async => await _pickDate(
//                                             context, _fromController),
//                                         icon: Icons.calendar_today_outlined,
//                                         fieldHeight: 29,
//                                         textSize: 12,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     SizedBox(
//                                       width: 118,
//                                       child: _dateBox(
//                                         label: 'TO DATE',
//                                         controller: _toController,
//                                         onTap: () async => await _pickDate(
//                                             context, _toController),
//                                         icon: Icons.calendar_today_outlined,
//                                         fieldHeight: 29,
//                                         textSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: verticalSpacing),
//                                 _buildDropdown(
//                                   label: 'SOURCE',
//                                   items: sources,
//                                   selectedId: _selectedSourceId,
//                                   onChanged: (v) =>
//                                       setState(() => _selectedSourceId = v),
//                                   getName: (item) =>
//                                       (item.name ?? item.toString()),
//                                   getId: (item) => item.id,
//                                   icon: Icons.circle_sharp,
//                                   hint: 'Choose a source...',
//                                   fieldHeight: adaptiveFieldHeight,
//                                 ),
//                                 SizedBox(height: verticalSpacing),
//                                 _buildDropdown(
//                                   label: 'CATEGORY',
//                                   items: categories,
//                                   selectedId: _selectedCategoryId,
//                                   onChanged: (v) =>
//                                       setState(() => _selectedCategoryId = v),
//                                   getName: (item) =>
//                                       (item.name ?? item.toString()),
//                                   getId: (item) => item.id,
//                                   icon: Icons.local_offer_outlined,
//                                   hint: 'Choose a category...',
//                                   fieldHeight: adaptiveFieldHeight,
//                                 ),
//                                 SizedBox(height: verticalSpacing),
//                                 _buildDropdown(
//                                   label: 'LOCATION',
//                                   items: locations,
//                                   selectedId: _selectedLocationId,
//                                   onChanged: (v) =>
//                                       setState(() => _selectedLocationId = v),
//                                   getName: (item) =>
//                                       (item.name ?? item.toString()),
//                                   getId: (item) => item.id,
//                                   icon: Icons.location_on_outlined,
//                                   hint: 'Choose a location...',
//                                   fieldHeight: adaptiveFieldHeight,
//                                 ),
//                                 SizedBox(height: verticalSpacing),
//                                 _buildDropdown(
//                                   label: 'SALESPERSON',
//                                   items: salespersons,
//                                   selectedId: _selectedSalespersonId,
//                                   onChanged: (v) => setState(
//                                       () => _selectedSalespersonId = v),
//                                   getName: (item) =>
//                                       '${item.firstName} ${item.lastName}'
//                                           .trim(),
//                                   getId: (item) => item.salesPersonId,
//                                   icon: Icons.person_outline,
//                                   hint: 'Choose a salesperson...',
//                                   fieldHeight: adaptiveFieldHeight,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 18),
//                           const Spacer(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),

//             // Footer buttons
//             Container(
//               color: const Color(0xFFF0E8FF),
//               padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
//               child: SafeArea(
//                 top: false,
//                 bottom: true,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 136,
//                       height: 32,
//                       child: OutlinedButton.icon(
//                         onPressed: _clearAllFilters,
//                         icon: const Icon(Icons.close,
//                             size: 11, color: Colors.black54),
//                         label: const Text(
//                           'Clear Filters',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           ),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           side: const BorderSide(
//                               color: fieldBorderColor, width: 1.0),
//                           padding: EdgeInsets.zero,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     SizedBox(
//                       width: 144,
//                       height: 32,
//                       child: ElevatedButton(
//                         onPressed: _saveFilters,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.violetblue,
//                           padding: EdgeInsets.zero,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           elevation: 0,
//                           minimumSize: const Size(160, 32),
//                         ),
//                         child: const Text(
//                           'Save',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
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
// lib/views/Screens/marketing/report/filterScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';

// ── Shared design tokens ──────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoDark = Color(0xFF4338CA);
const _kIndigoLight = Color(0xFF818CF8);
const _kBg = Color(0xFFF5F4FF);
const _kCardBg = Colors.white;
const _kInk = Color(0xFF1E1B4B);
const _kSub = Color(0xFF6B7280);
const _kBorder = Color(0xFFE5E7EB);
const _kSoftLilac = Color(0xFFF0EEFF);

class MarketingReportFilterPage extends StatefulWidget {
  const MarketingReportFilterPage({super.key});

  @override
  State<MarketingReportFilterPage> createState() =>
      _MarketingReportFilterPageState();
}

class _MarketingReportFilterPageState extends State<MarketingReportFilterPage> {
  final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  int? _selectedSourceId;
  int? _selectedCategoryId;
  int? _selectedLocationId;
  int? _selectedSalespersonId;

  @override
  void initState() {
    super.initState();
    final vm = context.read<MarketingReportViewmodel>();
    if (vm.fromDate != null && vm.fromDate!.isNotEmpty) {
      _fromController.text = vm.fromDate!;
    }
    if (vm.toDate != null && vm.toDate!.isNotEmpty) {
      _toController.text = vm.toDate!;
    }
    _selectedSourceId = vm.selectedSourceId;
    _selectedCategoryId = vm.selectedCategoryId;
    _selectedLocationId = vm.selectedLocationId;
    _selectedSalespersonId = vm.selectedSalespersonId;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  List<MarketingReport> _applyLocalSelections(
      List<MarketingReport> allReports) {
    DateTime? from;
    DateTime? to;
    try {
      if (_fromController.text.isNotEmpty) {
        from = _apiFormat.parse(_fromController.text);
      }
    } catch (_) {}
    try {
      if (_toController.text.isNotEmpty) {
        to = _apiFormat.parse(_toController.text);
      }
    } catch (_) {}

    return allReports.where((r) {
      if (_selectedSourceId != null && r.sourceId != _selectedSourceId) {
        return false;
      }
      if (_selectedCategoryId != null && r.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_selectedLocationId != null && r.locationId != _selectedLocationId) {
        return false;
      }
      if (_selectedSalespersonId != null &&
          r.salespersonId != _selectedSalespersonId) {
        return false;
      }
      if (from != null || to != null) {
        try {
          final rd = _apiFormat.parse(r.date);
          if (from != null && rd.isBefore(from)) return false;
          if (to != null && rd.isAfter(to)) return false;
        } catch (_) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> _exportToPdf(BuildContext context) async {
    final vm = context.read<MarketingReportViewmodel>();
    final filteredReports = _applyLocalSelections(vm.reports);

    if (filteredReports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No data to export for the selected filters.'),
          backgroundColor: _kIndigo,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final pdf = pw.Document();
    final summaryParts = <String>[];
    if (_fromController.text.isNotEmpty) {
      summaryParts.add('From: ${_fromController.text}');
    }
    if (_toController.text.isNotEmpty) {
      summaryParts.add('To: ${_toController.text}');
    }
    final filterSummary =
        summaryParts.isNotEmpty ? summaryParts.join('  |  ') : 'All Reports';

    const tableHeaders = [
      'Date',
      'Salesperson',
      'Source',
      'Location',
      'Category',
      'Calls',
      'Leads',
    ];

    final tableData = filteredReports
        .map((r) => [
              r.date,
              r.salesperson,
              r.source,
              r.location,
              r.category,
              '${r.calls}',
              '${r.leads}',
            ])
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Marketing Reports',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF6366F1))),
            pw.SizedBox(height: 4),
            pw.Text(filterSummary,
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text('Total Records: ${filteredReports.length}',
                style:
                    const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Divider(color: const PdfColor.fromInt(0xFF6366F1), thickness: 1),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.8),
              2: const pw.FlexColumnWidth(1.4),
              3: const pw.FlexColumnWidth(1.4),
              4: const pw.FlexColumnWidth(1.8),
              5: const pw.FlexColumnWidth(0.8),
              6: const pw.FlexColumnWidth(0.8),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColor.fromInt(0xFF6366F1)),
                children: tableHeaders
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: pw.Text(h,
                              style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white)),
                        ))
                    .toList(),
              ),
              ...tableData.asMap().entries.map((entry) {
                final isEven = entry.key % 2 == 0;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven
                        ? PdfColors.white
                        : const PdfColor.fromInt(0xFFF0EEFF),
                  ),
                  children: entry.value
                      .map((cell) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: pw.Text(cell,
                                style: const pw.TextStyle(fontSize: 9)),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'marketing_reports_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();
    try {
      if (controller.text.isNotEmpty) {
        initialDate = _apiFormat.parse(controller.text);
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kIndigo,
            onPrimary: Colors.white,
            onSurface: _kInk,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      controller.text = _apiFormat.format(picked);
      setState(() {});
    }
  }

  void _clearAllFilters() {
    setState(() {
      _fromController.text = '';
      _toController.text = '';
      _selectedSourceId = null;
      _selectedCategoryId = null;
      _selectedLocationId = null;
      _selectedSalespersonId = null;
    });
    context.read<MarketingReportViewmodel>().clearFilters();
    Navigator.of(context).pop('clear');
  }

  void _saveFilters() {
    final from = _fromController.text.isNotEmpty ? _fromController.text : null;
    final to = _toController.text.isNotEmpty ? _toController.text : null;

    context.read<MarketingReportViewmodel>().applyFilters(
          from: from,
          to: to,
          sourceId: _selectedSourceId,
          categoryId: _selectedCategoryId,
          locationId: _selectedLocationId,
          salespersonId: _selectedSalespersonId,
        );

    Navigator.of(context).pop('save');
  }

  String _formatDisplay(String apiDate) {
    try {
      return _displayFormat.format(_apiFormat.parse(apiDate));
    } catch (_) {
      return apiDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceVm = Provider.of<SourceViewmodel>(context);
    final categoryVm = Provider.of<CategoryMarketingViewmodel>(context);
    final locationVm = Provider.of<LocationViewmodel>(context);
    final salespersonVm = Provider.of<SalesPersonViewmodel>(context);

    final sources = sourceVm.sources;
    final categories = categoryVm.categories;
    final locations = locationVm.locations;
    final salespersons = salespersonVm.salesPersonList;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kIndigo,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Marketing Reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Filter & Export',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Export button
              GestureDetector(
                onTap: () => _exportToPdf(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_outlined,
                          size: 14, color: _kIndigoDark),
                      SizedBox(width: 4),
                      Text(
                        'Export',
                        style: TextStyle(
                          color: _kIndigoDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filter header strip ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _kSoftLilac,
                border: Border(
                    bottom:
                        BorderSide(color: _kIndigo.withValues(alpha: 0.1), width: 1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kIndigo.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.filter_alt_outlined,
                        color: _kIndigo, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Refine Results',
                      style: TextStyle(
                        color: _kInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Icon(Icons.close, size: 14, color: _kSub),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable filters ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date range row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateBox(
                            label: 'FROM DATE',
                            controller: _fromController,
                            onTap: () => _pickDate(context, _fromController),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateBox(
                            label: 'TO DATE',
                            controller: _toController,
                            onTap: () => _pickDate(context, _toController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownCard<dynamic>(
                      label: 'SOURCE',
                      icon: Icons.share_outlined,
                      items: sources,
                      selectedId: _selectedSourceId,
                      getName: (item) => item.name ?? item.toString(),
                      getId: (item) => item.id,
                      hint: 'Choose a source...',
                      onChanged: (v) => setState(() => _selectedSourceId = v),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownCard<dynamic>(
                      label: 'CATEGORY',
                      icon: Icons.local_offer_outlined,
                      items: categories,
                      selectedId: _selectedCategoryId,
                      getName: (item) => item.name ?? item.toString(),
                      getId: (item) => item.id,
                      hint: 'Choose a category...',
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownCard<dynamic>(
                      label: 'LOCATION',
                      icon: Icons.location_on_outlined,
                      items: locations,
                      selectedId: _selectedLocationId,
                      getName: (item) => item.name ?? item.toString(),
                      getId: (item) => item.id,
                      hint: 'Choose a location...',
                      onChanged: (v) => setState(() => _selectedLocationId = v),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownCard<dynamic>(
                      label: 'SALESPERSON',
                      icon: Icons.person_outline,
                      items: salespersons,
                      selectedId: _selectedSalespersonId,
                      getName: (item) =>
                          '${item.firstName} ${item.lastName}'.trim(),
                      getId: (item) => item.salesPersonId,
                      hint: 'Choose a salesperson...',
                      onChanged: (v) =>
                          setState(() => _selectedSalespersonId = v),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Footer buttons ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                color: _kCardBg,
                border: Border(
                    top:
                        BorderSide(color: _kIndigo.withValues(alpha: 0.1), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: _kIndigo.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _clearAllFilters,
                            icon:
                                const Icon(Icons.close, size: 14, color: _kSub),
                            label: const Text(
                              'Clear All',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kInk,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _kBorder, width: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _saveFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kIndigo,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final hasValue = controller.text.isNotEmpty;
    final displayText = hasValue ? _formatDisplay(controller.text) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kSub,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasValue ? _kIndigo.withValues(alpha: 0.4) : _kBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: hasValue ? _kIndigo : _kSub),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    displayText ?? 'dd MMM yyyy',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasValue ? _kInk : _kSub,
                      fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasValue)
                  GestureDetector(
                    onTap: () => setState(() => controller.text = ''),
                    child: const Icon(Icons.close, size: 14, color: _kSub),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard<T>({
    required String label,
    required IconData icon,
    required List<T> items,
    required int? selectedId,
    required String Function(T) getName,
    required int Function(T) getId,
    required String hint,
    required void Function(int?) onChanged,
  }) {
    final selectedItem = selectedId != null
        ? items.cast<T?>().firstWhere(
            (item) => item != null && getId(item) == selectedId,
            orElse: () => null)
        : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedItem != null ? _kIndigo.withValues(alpha: 0.3) : _kBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _kIndigo.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selectedItem != null
                      ? _kIndigo.withValues(alpha: 0.1)
                      : _kSoftLilac,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon,
                    size: 12, color: selectedItem != null ? _kIndigo : _kSub),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _kSub,
                  letterSpacing: 0.5,
                ),
              ),
              if (selectedItem != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => onChanged(null),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: _kBorder,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 10, color: _kSub),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: DropdownButtonFormField<int>(
              initialValue: selectedId,
              isExpanded: true,
              icon:
                  const Icon(Icons.keyboard_arrow_down, size: 16, color: _kSub),
              dropdownColor: _kCardBg,
              style: const TextStyle(
                  fontSize: 13, color: _kInk, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                hintText: hint,
                hintStyle: const TextStyle(
                    fontSize: 13, color: _kSub, fontWeight: FontWeight.w400),
                filled: true,
                fillColor: _kBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _kIndigo, width: 1.5),
                ),
              ),
              items: items
                  .map((item) => DropdownMenuItem<int>(
                        value: getId(item),
                        child: Text(getName(item),
                            style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
