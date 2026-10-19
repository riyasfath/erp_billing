// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/category.dart'
//     as cat_mkt;
// import 'package:pokakbilling/models/data-models/salesperson_model.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:provider/provider.dart';

// class EditMarketingReportPage extends StatefulWidget {
//   final MarketingReport report;

//   const EditMarketingReportPage({super.key, required this.report});

//   @override
//   State<EditMarketingReportPage> createState() =>
//       _EditMarketingReportPageState();
// }

// class _EditMarketingReportPageState extends State<EditMarketingReportPage> {
//   late TextEditingController dateController;
//   late TextEditingController callsController;
//   late TextEditingController leadsController;

//   SalesPersonModel? selectedSalesperson;
//   int? selectedSalespersonId;
//   Source? selectedSource;
//   Location? selectedLocation;
//   cat_mkt.CategoryMarketing? selectedCategory;

//   @override
//   void initState() {
//     super.initState();
//     dateController = TextEditingController(text: widget.report.date);
//     callsController =
//         TextEditingController(text: widget.report.calls.toString());
//     leadsController =
//         TextEditingController(text: widget.report.leads.toString());
//     selectedSalespersonId = widget.report.salespersonId;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final salesVm = context.read<SalesPersonViewmodel>();
//       final sourceVm = context.read<SourceViewmodel>();
//       final locationVm = context.read<LocationViewmodel>();
//       final categoryVm = context.read<CategoryMarketingViewmodel>();

//       setState(() {
//         selectedSalesperson = salesVm.salesPersonList
//             .where((s) => s.salesPersonId == widget.report.salespersonId)
//             .cast<SalesPersonModel?>()
//             .followedBy([null]).first;

//         selectedSource = sourceVm.sources
//             .where((s) => s.id == widget.report.sourceId)
//             .cast<Source?>()
//             .followedBy([null]).first;

//         selectedLocation = locationVm.locations
//             .where((l) => l.id == widget.report.locationId)
//             .cast<Location?>()
//             .followedBy([null]).first;

//         selectedCategory = categoryVm.categories
//             .where((c) => c.id == widget.report.categoryId)
//             .cast<cat_mkt.CategoryMarketing?>()
//             .followedBy([null]).first;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     dateController.dispose();
//     callsController.dispose();
//     leadsController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickDate() async {
//     final initial = DateTime.tryParse(dateController.text) ?? DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: AppColors.violetblue,
//             onPrimary: Colors.white,
//             onSurface: Colors.black87,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       dateController.text = DateFormat('yyyy-MM-dd').format(picked);
//       setState(() {});
//     }
//   }

//   Future<void> _showCategoryPicker(
//       List<cat_mkt.CategoryMarketing> options) async {
//     final chosen = await showModalBottomSheet<cat_mkt.CategoryMarketing>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.6,
//           minChildSize: 0.3,
//           maxChildSize: 0.95,
//           expand: false,
//           builder: (context, scrollController) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 4,
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     decoration: BoxDecoration(
//                         color: Colors.black12,
//                         borderRadius: BorderRadius.circular(4)),
//                   ),
//                   const Padding(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text('Select category',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                   const Divider(height: 1),
//                   Expanded(
//                     child: ListView.separated(
//                       controller: scrollController,
//                       itemCount: options.length,
//                       separatorBuilder: (_, __) => const Divider(height: 1),
//                       itemBuilder: (context, index) {
//                         final c = options[index];
//                         final isSelected = selectedCategory?.id == c.id;
//                         return ListTile(
//                           title: Text(c.name),
//                           trailing: isSelected
//                               ? const Icon(Icons.check,
//                                   color: AppColors.violetblue)
//                               : null,
//                           onTap: () {
//                             Navigator.of(context).pop(c);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );

//     if (chosen != null) {
//       setState(() {
//         selectedCategory = chosen;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final reportVm = context.watch<MarketingReportViewmodel>();
//     final salesVm = context.watch<SalesPersonViewmodel>();
//     final sourceVm = context.watch<SourceViewmodel>();
//     final locationVm = context.watch<LocationViewmodel>();
//     final categoryVm = context.watch<CategoryMarketingViewmodel>();

//     final List<cat_mkt.CategoryMarketing> categoryOptions =
//         selectedSource == null
//             ? categoryVm.categories
//             : categoryVm.categories
//                 .where((c) => c.source == selectedSource!.id)
//                 .toList();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         title: const Text('Edit Report',
//             style: TextStyle(color: AppColors.white, fontSize: 16)),
//         leading: IconButton(
//           icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Card(
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     elevation: 8,
//                     shadowColor: Colors.grey.withOpacity(0.3),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _label('Date'),
//                           const SizedBox(height: 8),
//                           SizedBox(
//                             height: 43,
//                             child: TextField(
//                               controller: dateController,
//                               readOnly: true,
//                               onTap: _pickDate,
//                               decoration: _input('Select date (YYYY-MM-DD)')
//                                   .copyWith(
//                                       suffixIcon: const Icon(Icons.date_range)),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _label('Salesperson'),
//                           const SizedBox(height: 8),
//                           DropdownButtonFormField<SalesPersonModel>(
//                             value: selectedSalesperson,
//                             items: salesVm.salesPersonList
//                                 .map((s) => DropdownMenuItem(
//                                       value: s,
//                                       child: Text('${s.firstName} ${s.lastName}'
//                                           .trim()),
//                                     ))
//                                 .toList(),
//                             onChanged: (v) {
//                               setState(() {
//                                 selectedSalesperson = v;
//                                 selectedSalespersonId = v?.salesPersonId;
//                               });
//                             },
//                             decoration: _input('Select salesperson'),
//                           ),
//                           const SizedBox(height: 16),
//                           _label('Source'),
//                           const SizedBox(height: 8),
//                           DropdownButtonFormField<Source>(
//                             value: selectedSource,
//                             items: sourceVm.sources
//                                 .map((s) => DropdownMenuItem(
//                                     value: s, child: Text(s.name)))
//                                 .toList(),
//                             onChanged: (v) {
//                               setState(() {
//                                 selectedSource = v;
//                                 if (selectedCategory != null &&
//                                     selectedSource != null &&
//                                     selectedCategory!.source !=
//                                         selectedSource!.id) {
//                                   selectedCategory = null;
//                                 }
//                               });
//                             },
//                             decoration: _input('Select source'),
//                           ),
//                           const SizedBox(height: 16),
//                           _label('Location'),
//                           const SizedBox(height: 8),
//                           DropdownButtonFormField<Location>(
//                             value: selectedLocation,
//                             items: locationVm.locations
//                                 .map((l) => DropdownMenuItem(
//                                     value: l, child: Text(l.name)))
//                                 .toList(),
//                             onChanged: (v) =>
//                                 setState(() => selectedLocation = v),
//                             decoration: _input('Select location'),
//                           ),
//                           const SizedBox(height: 16),
//                           _label('Category'),
//                           const SizedBox(height: 8),
//                           GestureDetector(
//                             onTap: () {
//                               _showCategoryPicker(categoryOptions);
//                             },
//                             child: InputDecorator(
//                               decoration: _input(selectedSource == null
//                                   ? 'Select category (all)'
//                                   : 'Select category (filtered by source)'),
//                               isEmpty: selectedCategory == null,
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       selectedCategory?.name ??
//                                           'Choose category',
//                                       style: TextStyle(
//                                         color: selectedCategory == null
//                                             ? const Color(0xFFCAD5E2)
//                                             : Colors.black87,
//                                       ),
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   const Icon(Icons.arrow_drop_down)
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _label('Calls'),
//                           const SizedBox(height: 8),
//                           SizedBox(
//                             height: 43,
//                             child: TextField(
//                               controller: callsController,
//                               keyboardType: TextInputType.number,
//                               decoration: _input('Enter calls'),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           _label('Leads'),
//                           const SizedBox(height: 8),
//                           SizedBox(
//                             height: 43,
//                             child: TextField(
//                               controller: leadsController,
//                               keyboardType: TextInputType.number,
//                               decoration: _input('Enter leads'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // ✅ FIXED: Update button - awaits result and returns true
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: reportVm.editReportLoading
//                       ? null
//                       : () async {
//                           final date = dateController.text.trim();
//                           final calls =
//                               int.tryParse(callsController.text.trim()) ?? 0;
//                           final leads =
//                               int.tryParse(leadsController.text.trim()) ?? 0;

//                           if (date.isEmpty ||
//                               selectedSalespersonId == null ||
//                               selectedSource == null ||
//                               selectedLocation == null ||
//                               selectedCategory == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content:
//                                       Text('Please fill all required fields')),
//                             );
//                             return;
//                           }

//                           // ✅ Awaits bool result from editReport
//                           final success = await reportVm.editReport(
//                             reportId: widget.report.id,
//                             date: date,
//                             salespersonId: selectedSalespersonId!,
//                             sourceId: selectedSource!.id,
//                             locationId: selectedLocation!.id,
//                             categoryId: selectedCategory!.id,
//                             calls: calls,
//                             leads: leads,
//                             context: context,
//                           );

//                           if (success == true && mounted) {
//                             Navigator.pop(context, true); // ✅ Signals success
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.violetblue,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: reportVm.editReportLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text('Update',
//                           style: TextStyle(fontSize: 16, color: Colors.white)),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     side: const BorderSide(color: Color(0xFFCAD5E2)),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text('Cancel',
//                       style: TextStyle(fontSize: 16, color: Color(0xFFCAD5E2))),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _input(String hint) => InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Color(0xFFCAD5E2)),
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFCAD5E2)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: Color(0xFFCAD5E2)),
//         ),
//       );

//   Widget _label(String text) => Text(
//         text,
//         style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF643CB5)),
//       );
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
import 'package:pokakbilling/models/data-models/marketing_model/category.dart'
    as cat_mkt;
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:provider/provider.dart';

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

class EditMarketingReportPage extends StatefulWidget {
  final MarketingReport report;
  const EditMarketingReportPage({super.key, required this.report});

  @override
  State<EditMarketingReportPage> createState() =>
      _EditMarketingReportPageState();
}

class _EditMarketingReportPageState extends State<EditMarketingReportPage> {
  late TextEditingController dateController;
  late TextEditingController callsController;
  late TextEditingController leadsController;

  SalesPersonModel? selectedSalesperson;
  int? selectedSalespersonId;
  Source? selectedSource;
  Location? selectedLocation;
  cat_mkt.CategoryMarketing? selectedCategory;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.report.date);
    callsController =
        TextEditingController(text: widget.report.calls.toString());
    leadsController =
        TextEditingController(text: widget.report.leads.toString());
    selectedSalespersonId = widget.report.salespersonId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final salesVm = context.read<SalesPersonViewmodel>();
      final sourceVm = context.read<SourceViewmodel>();
      final locationVm = context.read<LocationViewmodel>();
      final categoryVm = context.read<CategoryMarketingViewmodel>();

      setState(() {
        selectedSalesperson = salesVm.salesPersonList
            .where((s) => s.salesPersonId == widget.report.salespersonId)
            .cast<SalesPersonModel?>()
            .followedBy([null]).first;

        selectedSource = sourceVm.sources
            .where((s) => s.id == widget.report.sourceId)
            .cast<Source?>()
            .followedBy([null]).first;

        selectedLocation = locationVm.locations
            .where((l) => l.id == widget.report.locationId)
            .cast<Location?>()
            .followedBy([null]).first;

        selectedCategory = categoryVm.categories
            .where((c) => c.id == widget.report.categoryId)
            .cast<cat_mkt.CategoryMarketing?>()
            .followedBy([null]).first;
      });
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    callsController.dispose();
    leadsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<void> _showCategoryPicker(
      List<cat_mkt.CategoryMarketing> options) async {
    final chosen = await showModalBottomSheet<cat_mkt.CategoryMarketing>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: _kCardBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _kIndigo,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _kInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _kBorder),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: options.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: _kBorder),
                      itemBuilder: (context, index) {
                        final c = options[index];
                        final isSelected = selectedCategory?.id == c.id;
                        return ListTile(
                          title: Text(
                            c.name,
                            style: TextStyle(
                              color: isSelected ? _kIndigo : _kInk,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: _kIndigo,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 14),
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (chosen != null) setState(() => selectedCategory = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final reportVm = context.watch<MarketingReportViewmodel>();
    final salesVm = context.watch<SalesPersonViewmodel>();
    final sourceVm = context.watch<SourceViewmodel>();
    final locationVm = context.watch<LocationViewmodel>();
    final categoryVm = context.watch<CategoryMarketingViewmodel>();

    final List<cat_mkt.CategoryMarketing> categoryOptions =
        selectedSource == null
            ? categoryVm.categories
            : categoryVm.categories
                .where((c) => c.source == selectedSource!.id)
                .toList();

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
                  child: const Icon(CupertinoIcons.arrow_left,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSection(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date',
                      child: _buildDateField(),
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.person_outline,
                      title: 'Salesperson',
                      child: _buildDropdownField<SalesPersonModel>(
                        value: selectedSalesperson,
                        items: salesVm.salesPersonList,
                        hint: 'Select salesperson',
                        getName: (s) => '${s.firstName} ${s.lastName}'.trim(),
                        onChanged: (v) => setState(() {
                          selectedSalesperson = v;
                          selectedSalespersonId = v?.salesPersonId;
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.share_outlined,
                      title: 'Source',
                      child: _buildDropdownField<Source>(
                        value: selectedSource,
                        items: sourceVm.sources,
                        hint: 'Select source',
                        getName: (s) => s.name,
                        onChanged: (v) => setState(() {
                          selectedSource = v;
                          if (selectedCategory != null &&
                              v != null &&
                              selectedCategory!.source != v.id) {
                            selectedCategory = null;
                          }
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      child: _buildDropdownField<Location>(
                        value: selectedLocation,
                        items: locationVm.locations,
                        hint: 'Select location',
                        getName: (l) => l.name,
                        onChanged: (v) => setState(() => selectedLocation = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSection(
                      icon: Icons.local_offer_outlined,
                      title: 'Category',
                      child: _buildCategoryTile(categoryOptions),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSection(
                            icon: Icons.phone_outlined,
                            title: 'Calls',
                            child: _buildNumberField(
                                callsController, 'Enter calls'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSection(
                            icon: Icons.trending_up_outlined,
                            title: 'Leads',
                            child: _buildNumberField(
                                leadsController, 'Enter leads'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // ── Bottom action buttons ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: _kCardBg,
                border: Border(
                    top:
                        BorderSide(color: _kIndigo.withValues(alpha: 0.1), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: _kIndigo.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: reportVm.editReportLoading
                            ? null
                            : () async {
                                final date = dateController.text.trim();
                                final calls =
                                    int.tryParse(callsController.text.trim()) ??
                                        0;
                                final leads =
                                    int.tryParse(leadsController.text.trim()) ??
                                        0;

                                if (date.isEmpty ||
                                    selectedSalespersonId == null ||
                                    selectedSource == null ||
                                    selectedLocation == null ||
                                    selectedCategory == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Please fill all required fields'),
                                      backgroundColor: _kIndigo,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  );
                                  return;
                                }

                                final success = await reportVm.editReport(
                                  reportId: widget.report.id,
                                  date: date,
                                  salespersonId: selectedSalespersonId!,
                                  sourceId: selectedSource!.id,
                                  locationId: selectedLocation!.id,
                                  categoryId: selectedCategory!.id,
                                  calls: calls,
                                  leads: leads,
                                  context: context,
                                );

                                if (success == true && mounted) {
                                  Navigator.pop(context, true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kIndigo,
                          disabledBackgroundColor: _kIndigo.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: reportVm.editReportLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'Update Report',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: _kIndigo.withValues(alpha: 0.3), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _kIndigo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kIndigo.withValues(alpha: 0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: _kIndigo.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _kSoftLilac,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: _kIndigo),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kSub,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dateController.text.isEmpty
                    ? 'Select date'
                    : dateController.text,
                style: TextStyle(
                  fontSize: 14,
                  color: dateController.text.isEmpty ? _kSub : _kInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: _kIndigo),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T) getName,
    required void Function(T?) onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 14, color: _kSub)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSub),
          dropdownColor: _kCardBg,
          style: const TextStyle(
              fontSize: 14, color: _kInk, fontWeight: FontWeight.w500),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(getName(item)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategoryTile(List<cat_mkt.CategoryMarketing> options) {
    return GestureDetector(
      onTap: () => _showCategoryPicker(options),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCategory?.name ?? 'Choose category',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedCategory == null ? _kSub : _kInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _kSub),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String hint) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
              fontSize: 14, color: _kInk, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: _kSub),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
