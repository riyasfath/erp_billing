// // lib/views/Screens/marketing/report/addreport1.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/marketing/report/addreport2.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/models/data-models/salesperson_model.dart';

// class AddReportStep1 extends StatefulWidget {
//   const AddReportStep1({super.key});

//   @override
//   State<AddReportStep1> createState() => _AddReportStep1State();
// }

// class _AddReportStep1State extends State<AddReportStep1> {
//   final TextEditingController dateController = TextEditingController();
//   int? selectedSalespersonId;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Date format changed to yyyy-MM-dd
//     dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final spVm = context.read<SalesPersonViewmodel>();
//       if (spVm.salesPersonList.isNotEmpty) {
//         setState(() =>
//             selectedSalespersonId = spVm.salesPersonList.first.salesPersonId);
//       } else {
//         spVm.getAllSalesPerson();
//       }
//     });
//   }

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate:
//           DateTime.tryParse(DateFormat('yyyy-MM-dd').format(DateTime.now())) ??
//               DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       // ✅ Show as Year-Month-Day
//       dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const Color borderColor = Color(0xFFCAD5E2);
//     final salesVm = context.watch<SalesPersonViewmodel>();

//     if (selectedSalespersonId == null && salesVm.salesPersonList.isNotEmpty) {
//       selectedSalespersonId = salesVm.salesPersonList.first.salesPersonId;
//     }

//     SalesPersonModel? getSelectedSalesperson() {
//       if (selectedSalespersonId == null) return null;
//       try {
//         return salesVm.salesPersonList
//             .firstWhere((s) => s.salesPersonId == selectedSalespersonId);
//       } catch (_) {
//         return null;
//       }
//     }

//     final selectedSalesperson = getSelectedSalesperson();

//     return Scaffold(
//       backgroundColor: AppColors.violetblue,
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         elevation: 0,
//         title: const Text(
//           'New Report',
//           style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.fromLTRB(14, 28, 14, 40),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'SALESPERSON *',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF6A7282),
//                         fontSize: 12,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       height: 40,
//                       child: salesVm.getSalesPersonLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : DropdownButtonFormField<int>(
//                               initialValue: selectedSalespersonId,
//                               hint: const Text('Select Salesperson'),
//                               isExpanded: true,
//                               icon: const Icon(
//                                 Icons.keyboard_arrow_down,
//                                 color: AppColors.softBorder,
//                               ),
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(
//                                   Icons.personal_injury_sharp,
//                                   color: AppColors.softBorder,
//                                 ),
//                                 filled: true,
//                                 fillColor: AppColors.white,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 10),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       const BorderSide(color: borderColor),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide:
//                                       const BorderSide(color: borderColor),
//                                 ),
//                               ),
//                               items: salesVm.salesPersonList.map((s) {
//                                 return DropdownMenuItem<int>(
//                                   value: s.salesPersonId,
//                                   child: Text(s.fullName),
//                                 );
//                               }).toList(),
//                               onChanged: (v) => setState(() {
//                                 selectedSalespersonId = v;
//                               }),
//                             ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: AppColors.lightPurple,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: selectedSalesperson == null
//                           ? const Text(
//                               'Email: -\nMobile: -',
//                               style: TextStyle(color: AppColors.headerPurple),
//                             )
//                           : Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Email: ',
//                                       style: TextStyle(
//                                         color: AppColors.headerPurple,
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         selectedSalesperson.email.isNotEmpty
//                                             ? selectedSalesperson.email
//                                             : '-',
//                                         style: const TextStyle(
//                                           color: AppColors.headerPurple,
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       'Mobile: ',
//                                       style: TextStyle(
//                                         color: AppColors.headerPurple,
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         selectedSalesperson.mobile.isNotEmpty
//                                             ? selectedSalesperson.mobile
//                                             : '-',
//                                         style: const TextStyle(
//                                           color: AppColors.headerPurple,
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 12,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                     ),
//                     const SizedBox(height: 18),
//                     const Text(
//                       'REPORT DATE *',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF6A7282),
//                         fontSize: 12,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       height: 44,
//                       child: TextField(
//                         controller: dateController,
//                         readOnly: true,
//                         onTap: _pickDate,
//                         style: const TextStyle(fontSize: 16),
//                         decoration: InputDecoration(
//                           hintText: 'Select Date',
//                           suffixIcon: const Icon(
//                             Icons.calendar_today_outlined,
//                             size: 20,
//                           ),
//                           filled: true,
//                           fillColor: AppColors.white,
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 12),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(color: borderColor),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: const BorderSide(color: borderColor),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     const Text(
//                       'Select the date for this marketing report',
//                       style: TextStyle(
//                         color: Color(0xFF6A7282),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         child: SizedBox(
//           height: 40,
//           child: ElevatedButton.icon(
//             onPressed: () {
//               final mrVm = context.read<MarketingReportViewmodel>();
//               final srcVm = context.read<SourceViewmodel>();
//               final locVm = context.read<LocationViewmodel>();
//               final catVm = context.read<CategoryMarketingViewmodel>();
//               final spVm = context.read<SalesPersonViewmodel>();

//               final selectedId = selectedSalespersonId ?? 0;

//               final target = MultiProvider(
//                 providers: [
//                   ChangeNotifierProvider.value(value: mrVm),
//                   ChangeNotifierProvider.value(value: srcVm),
//                   ChangeNotifierProvider.value(value: catVm),
//                   ChangeNotifierProvider.value(value: locVm),
//                   ChangeNotifierProvider.value(value: spVm),
//                 ],
//                 child: AddReportStep2(
//                   initialSalespersonId: selectedId,
//                   initialSalespersonName: selectedSalesperson?.fullName ?? '',
//                   initialDate: dateController.text,
//                 ),
//               );

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => target),
//               );
//             },
//             icon: const Icon(
//               Icons.add,
//               color: AppColors.black,
//               size: 16,
//             ),
//             label: const Text(
//               'Add Source',
//               style: TextStyle(
//                 color: AppColors.violetblue,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               padding: EdgeInsets.zero,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// lib/views/Screens/marketing/report/addreport1.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/report/addreport2.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';

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
const _kGreen = Color(0xFF10B981);
const _kCyan = Color(0xFF06B6D4);

class AddReportStep1 extends StatefulWidget {
  const AddReportStep1({super.key});

  @override
  State<AddReportStep1> createState() => _AddReportStep1State();
}

class _AddReportStep1State extends State<AddReportStep1> {
  final TextEditingController dateController = TextEditingController();
  int? selectedSalespersonId;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final spVm = context.read<SalesPersonViewmodel>();
      if (spVm.salesPersonList.isNotEmpty) {
        setState(() =>
            selectedSalespersonId = spVm.salesPersonList.first.salesPersonId);
      } else {
        spVm.getAllSalesPerson();
      }
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesVm = context.watch<SalesPersonViewmodel>();

    if (selectedSalespersonId == null && salesVm.salesPersonList.isNotEmpty) {
      selectedSalespersonId = salesVm.salesPersonList.first.salesPersonId;
    }

    SalesPersonModel? getSelectedSalesperson() {
      if (selectedSalespersonId == null) return null;
      try {
        return salesVm.salesPersonList
            .firstWhere((s) => s.salesPersonId == selectedSalespersonId);
      } catch (_) {
        return null;
      }
    }

    final selectedSalesperson = getSelectedSalesperson();

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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Step 1 of 2',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Step indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('1',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _kIndigo)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 16,
                      height: 2,
                      color: Colors.white38,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('2',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Salesperson card ────────────────────────────────────────
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                        Icons.person_outline, 'SALESPERSON', _kIndigo),
                    const SizedBox(height: 12),
                    salesVm.getSalesPersonLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: _kIndigo, strokeWidth: 2),
                            ),
                          )
                        : _styledDropdown(
                            value: selectedSalespersonId,
                            items: salesVm.salesPersonList
                                .map((s) => DropdownMenuItem<int>(
                                      value: s.salesPersonId,
                                      child: Text(s.fullName,
                                          style: const TextStyle(
                                              fontSize: 14, color: _kInk)),
                                    ))
                                .toList(),
                            hint: 'Select salesperson',
                            icon: Icons.person_outline,
                            onChanged: (v) =>
                                setState(() => selectedSalespersonId = v),
                          ),
                    if (selectedSalesperson != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _kSoftLilac,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kIndigo.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            _infoRow(
                              Icons.email_outlined,
                              'Email',
                              selectedSalesperson.email.isNotEmpty
                                  ? selectedSalesperson.email
                                  : '—',
                              _kIndigo,
                            ),
                            const SizedBox(height: 8),
                            _infoRow(
                              Icons.phone_outlined,
                              'Mobile',
                              selectedSalesperson.mobile.isNotEmpty
                                  ? selectedSalesperson.mobile
                                  : '—',
                              _kGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Date card ───────────────────────────────────────────────
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                        Icons.calendar_today_outlined, 'REPORT DATE', _kCyan),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _kBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _kCyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_today_outlined,
                                  size: 14, color: _kCyan),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                dateController.text.isEmpty
                                    ? 'Select date'
                                    : dateController.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: dateController.text.isEmpty
                                      ? _kSub
                                      : _kInk,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.edit_calendar_outlined,
                                size: 16, color: _kSub),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 12, color: _kSub),
                        SizedBox(width: 4),
                        Text(
                          'Select the date for this marketing report',
                          style: TextStyle(color: _kSub, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        decoration: BoxDecoration(
          color: _kCardBg,
          border: Border(
              top: BorderSide(color: _kIndigo.withValues(alpha: 0.1), width: 1)),
          boxShadow: [
            BoxShadow(
              color: _kIndigo.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  final mrVm = context.read<MarketingReportViewmodel>();
                  final srcVm = context.read<SourceViewmodel>();
                  final locVm = context.read<LocationViewmodel>();
                  final catVm = context.read<CategoryMarketingViewmodel>();
                  final spVm = context.read<SalesPersonViewmodel>();
                  final selectedId = selectedSalespersonId ?? 0;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: mrVm),
                          ChangeNotifierProvider.value(value: srcVm),
                          ChangeNotifierProvider.value(value: catVm),
                          ChangeNotifierProvider.value(value: locVm),
                          ChangeNotifierProvider.value(value: spVm),
                        ],
                        child: AddReportStep2(
                          initialSalespersonId: selectedId,
                          initialSalespersonName:
                              getSelectedSalesperson()?.fullName ?? '',
                          initialDate: dateController.text,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Continue to Sources',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kIndigo,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kIndigo.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: _kIndigo.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _kSub,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _styledDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required String hint,
    required IconData icon,
    required void Function(int?) onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _kSoftLilac,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: _kIndigo),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                hint: Text(hint,
                    style: const TextStyle(fontSize: 14, color: _kSub)),
                icon: const Icon(Icons.keyboard_arrow_down,
                    size: 18, color: _kSub),
                dropdownColor: _kCardBg,
                style: const TextStyle(
                    fontSize: 14, color: _kInk, fontWeight: FontWeight.w500),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: _kInk,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _kSub,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
