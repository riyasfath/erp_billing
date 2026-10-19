// import 'package:flutter/material.dart';
// import 'package:pokakbilling/views/Screens/marketing/report/addreport1.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/marketing/report/edit_report.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/filterScreen.dart';

// class ReportsScreen extends StatefulWidget {
//   const ReportsScreen({super.key});

//   @override
//   State<ReportsScreen> createState() => _MarketingReportScreenState();
// }

// class _MarketingReportScreenState extends State<ReportsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   Widget _buildSearchBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//                 height: 38,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.search,
//                       color: Color(0xFFA4A0A0),
//                       size: 14, // reduced size
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: const InputDecoration(
//                           hintText: 'Search Reports',
//                           hintStyle: TextStyle(
//                             color: Color(0xFFA4A0A0),
//                             fontSize: 12, // smaller hint text
//                             fontWeight: FontWeight.w400, // 400 weight
//                           ),
//                           border: InputBorder.none,
//                           isDense: true,
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )),
//           ),
//           const SizedBox(width: 10),
//           InkWell(
//             onTap: () async {
//               final vm = context.read<MarketingReportViewmodel>();
//               await Navigator.of(context).push(
//                 MaterialPageRoute(
//                   fullscreenDialog: true,
//                   builder: (_) => MultiProvider(
//                     providers: [
//                       ChangeNotifierProvider.value(value: vm),
//                       ChangeNotifierProvider.value(
//                           value: context.read<SourceViewmodel>()),
//                       ChangeNotifierProvider.value(
//                           value: context.read<CategoryMarketingViewmodel>()),
//                       ChangeNotifierProvider.value(
//                           value: context.read<LocationViewmodel>()),
//                       ChangeNotifierProvider.value(
//                           value: context.read<SalesPersonViewmodel>()),
//                     ],
//                     child: const MarketingReportFilterPage(),
//                   ),
//                 ),
//               );
//             },
//             child: const SizedBox(
//               height: 42,
//               width: 42,
//               child: Icon(Icons.filter_alt_outlined, color: AppColors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<MarketingReport> _filterReports(List<MarketingReport> reports) {
//     if (_searchQuery.isEmpty) {
//       return reports;
//     }

//     return reports.where((report) {
//       return report.date.toLowerCase().contains(_searchQuery) ||
//           report.salesperson.toLowerCase().contains(_searchQuery) ||
//           report.category.toLowerCase().contains(_searchQuery) ||
//           report.location.toLowerCase().contains(_searchQuery) ||
//           report.source.toLowerCase().contains(_searchQuery) ||
//           report.calls.toString().contains(_searchQuery) ||
//           report.leads.toString().contains(_searchQuery);
//     }).toList();
//   }

//   Widget _buildReportCard(BuildContext context, MarketingReport report) {
//     const double cardHeight = 210.0;

//     const labelStyle = TextStyle(
//       fontSize: 11,
//       color: AppColors.violetblue,
//       fontWeight: FontWeight.w700,
//       letterSpacing: 0.5,
//     );
//     const valueStyle = TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w700,
//       color: Colors.black,
//     );
//     const smallValueStyle = TextStyle(
//       fontSize: 13,
//       fontWeight: FontWeight.w600,
//       color: Colors.black,
//     );

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: SizedBox(
//         height: cardHeight,
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF1E9FF),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       // ignore: deprecated_member_use
//                       color: Colors.black.withOpacity(0.03),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 54,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('DATE', style: labelStyle),
//                           const SizedBox(height: 6),
//                           Text(report.date, style: valueStyle),
//                           const SizedBox(height: 28),
//                           const Text('SALES PERSON', style: labelStyle),
//                           const SizedBox(height: 6),
//                           Text(report.salesperson,
//                               style: smallValueStyle,
//                               overflow: TextOverflow.ellipsis),
//                           const SizedBox(height: 28),
//                           const Text('CATEGORY', style: labelStyle),
//                           const SizedBox(height: 6),
//                           Text(report.category,
//                               style: smallValueStyle,
//                               overflow: TextOverflow.ellipsis),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 28),
//                     Expanded(
//                       flex: 46,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('LOCATION', style: labelStyle),
//                           const SizedBox(height: 6),
//                           Text(report.location,
//                               style: valueStyle,
//                               overflow: TextOverflow.ellipsis),
//                           const SizedBox(height: 28),
//                           const Text('SOURCE', style: labelStyle),
//                           const SizedBox(height: 6),
//                           Text(report.source,
//                               style: smallValueStyle,
//                               overflow: TextOverflow.ellipsis),
//                           const SizedBox(height: 28),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text('CALLS', style: labelStyle),
//                                     const SizedBox(height: 6),
//                                     Text('${report.calls}',
//                                         style: smallValueStyle),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text('LEADS', style: labelStyle),
//                                     const SizedBox(height: 6),
//                                     Text('${report.leads}',
//                                         style: smallValueStyle),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 2,
//               right: -10,
//               child: PopupMenuButton<int>(
//                 padding: const EdgeInsets.all(4),
//                 color: Colors.white,
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8)),
//                 icon: const Icon(Icons.more_vert,
//                     color: Color(0xFF2C2A74), size: 20),
//                 onSelected: (value) async {
//                   final vm = context.read<MarketingReportViewmodel>();
//                   if (value == 1) {
//                     // ✅ FIX: Capture the result when returning from edit
//                     final updated = await Navigator.push<bool>(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => MultiProvider(
//                           providers: [
//                             ChangeNotifierProvider.value(value: vm),
//                             ChangeNotifierProvider.value(
//                                 value: context.read<SourceViewmodel>()),
//                             ChangeNotifierProvider.value(
//                                 value:
//                                     context.read<CategoryMarketingViewmodel>()),
//                             ChangeNotifierProvider.value(
//                                 value: context.read<LocationViewmodel>()),
//                             ChangeNotifierProvider.value(
//                                 value: context.read<SalesPersonViewmodel>()),
//                           ],
//                           child: EditMarketingReportPage(report: report),
//                         ),
//                       ),
//                     );

//                     // ✅ Show success message if update was successful
//                     if (updated == true && mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Report updated successfully!'),
//                           backgroundColor: Colors.green,
//                           duration: Duration(seconds: 2),
//                         ),
//                       );
//                     }
//                   } else if (value == 2) {
//                     if (vm.deleteReportLoading) return;
//                     final confirm = await showDialog<bool>(
//                       context: context,
//                       builder: (dCtx) => AlertDialog(
//                         title: const Text('Delete Report'),
//                         content: const Text(
//                             'Are you sure you want to delete this report?'),
//                         actions: [
//                           TextButton(
//                               onPressed: () => Navigator.of(dCtx).pop(false),
//                               child: const Text('Cancel')),
//                           TextButton(
//                               onPressed: () => Navigator.of(dCtx).pop(true),
//                               child: const Text('Delete',
//                                   style: TextStyle(color: Colors.red))),
//                         ],
//                       ),
//                     );
//                     if (confirm == true) {
//                       // ignore: use_build_context_synchronously
//                       vm.deleteReport(report.id, context);
//                     }
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(value: 1, child: Text('Edit')),
//                   const PopupMenuItem(
//                     value: 2,
//                     child: Row(
//                       children: [
//                         Icon(Icons.delete_outline, color: Colors.red, size: 18),
//                         SizedBox(width: 8),
//                         Text('Delete', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//             create: (_) => MarketingReportViewmodel()..fetchReports()),
//         ChangeNotifierProvider(
//             create: (_) => SourceViewmodel()..fetchSources()),
//         ChangeNotifierProvider(
//             create: (_) => CategoryMarketingViewmodel()..fetchCategories()),
//         ChangeNotifierProvider(
//             create: (_) => LocationViewmodel()..fetchLocations()),
//         ChangeNotifierProvider(
//             create: (_) => SalesPersonViewmodel()..getAllSalesPerson()),
//       ],
//       child: Builder(builder: (innerContext) {
//         return Scaffold(
//           backgroundColor: AppColors.violetblue, // full violet background
//           body: Consumer<MarketingReportViewmodel>(builder: (context, vm, _) {
//             if (vm.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (vm.errorMessage != null) {
//               return Center(child: Text('Error: ${vm.errorMessage}'));
//             }
//             final reports = vm.reports;
//             final filteredReports = _filterReports(reports);

//             return Column(
//               children: [
//                 const SizedBox(height: 8),
//                 _buildSearchBar(innerContext),
//                 const SizedBox(height: 6),
//                 Expanded(
//                   child: filteredReports.isEmpty
//                       ? const Center(child: Text('No reports available'))
//                       : ListView.builder(
//                           padding: const EdgeInsets.only(bottom: 90),
//                           itemCount: filteredReports.length,
//                           itemBuilder: (context, index) {
//                             final r = filteredReports[index];
//                             return _buildReportCard(context, r);
//                           },
//                         ),
//                 ),
//               ],
//             );
//           }),

//           // ✅ FAB: white background, black + icon
//           floatingActionButton: SizedBox(
//             width: 75,
//             height: 73,
//             child: FloatingActionButton(
//               shape: const CircleBorder(),
//               backgroundColor: Colors.white, // white background
//               onPressed: () async {
//                 final vm = innerContext.read<MarketingReportViewmodel>();
//                 final created = await Navigator.push<bool>(
//                   innerContext,
//                   MaterialPageRoute(
//                     builder: (_) => MultiProvider(
//                       providers: [
//                         ChangeNotifierProvider.value(value: vm),
//                         ChangeNotifierProvider.value(
//                             value: innerContext.read<SourceViewmodel>()),
//                         ChangeNotifierProvider.value(
//                             value: innerContext
//                                 .read<CategoryMarketingViewmodel>()),
//                         ChangeNotifierProvider.value(
//                             value: innerContext.read<LocationViewmodel>()),
//                         ChangeNotifierProvider.value(
//                             value: innerContext.read<SalesPersonViewmodel>()),
//                       ],
//                       child: const AddReportStep1(),
//                     ),
//                   ),
//                 );

//                 if (created == true && mounted) {
//                   ScaffoldMessenger.of(innerContext).showSnackBar(
//                     const SnackBar(
//                       content: Text('Report added successfully!'),
//                       backgroundColor: Colors.green,
//                       duration: Duration(seconds: 2),
//                     ),
//                   );
//                 }
//               },
//               child: const Icon(Icons.add, color: Colors.black, size: 32),
//             ),
//           ),
//           floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/marketing/report/addreport1.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/report/edit_report.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/filterScreen.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kMetricInk = Color(0xFF1E1B4B);
const _kSoftLilac = Color(0xFFF0EEFF);

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _MarketingReportScreenState();
}

class _MarketingReportScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.toLowerCase());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                    fontSize: 13.5,
                    color: _isDark ? Colors.white : _kMetricInk),
                decoration: InputDecoration(
                  hintText: 'Search reports…',
                  hintStyle: TextStyle(
                      color: _isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                  filled: true,
                  fillColor:
                      _isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                  prefixIcon: Icon(Icons.search,
                      color: _isDark ? _kIndigoLight : _kIndigo, size: 19),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : _kIndigo.withValues(alpha: 0.15),
                        width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                        color: _kIndigo.withValues(alpha: 0.5), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter button
          GestureDetector(
            onTap: () async {
              final vm = context.read<MarketingReportViewmodel>();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: vm),
                      ChangeNotifierProvider.value(
                          value: context.read<SourceViewmodel>()),
                      ChangeNotifierProvider.value(
                          value: context.read<CategoryMarketingViewmodel>()),
                      ChangeNotifierProvider.value(
                          value: context.read<LocationViewmodel>()),
                      ChangeNotifierProvider.value(
                          value: context.read<SalesPersonViewmodel>()),
                    ],
                    child: const MarketingReportFilterPage(),
                  ),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : _kIndigo.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : _kIndigo.withValues(alpha: 0.2)),
              ),
              child: Icon(Icons.filter_alt_outlined,
                  color: _isDark ? _kIndigoLight : _kIndigoDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  List<MarketingReport> _filterReports(List<MarketingReport> reports) {
    if (_searchQuery.isEmpty) return reports;
    return reports.where((report) {
      return report.date.toLowerCase().contains(_searchQuery) ||
          report.salesperson.toLowerCase().contains(_searchQuery) ||
          report.category.toLowerCase().contains(_searchQuery) ||
          report.location.toLowerCase().contains(_searchQuery) ||
          report.source.toLowerCase().contains(_searchQuery) ||
          report.calls.toString().contains(_searchQuery) ||
          report.leads.toString().contains(_searchQuery);
    }).toList();
  }

  Widget _buildReportCard(BuildContext context, MarketingReport report) {
    const labelStyle = TextStyle(
      fontSize: 10.5,
      color: _kIndigo,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final valueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: _isDark ? Colors.white : _kMetricInk,
    );
    final smallValueStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: _isDark ? Colors.white : _kMetricInk,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.1)
              : _kIndigo.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: _isDark
            ? null
            : [
                BoxShadow(
                  color: _kIndigo.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 40, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DATE', style: labelStyle),
                      const SizedBox(height: 5),
                      Text(report.date, style: valueStyle),
                      const SizedBox(height: 16),
                      const Text('SALES PERSON', style: labelStyle),
                      const SizedBox(height: 5),
                      Text(report.salesperson,
                          style: smallValueStyle,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      const Text('CATEGORY', style: labelStyle),
                      const SizedBox(height: 5),
                      Text(report.category,
                          style: smallValueStyle,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 46,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LOCATION', style: labelStyle),
                      const SizedBox(height: 5),
                      Text(report.location,
                          style: valueStyle, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      const Text('SOURCE', style: labelStyle),
                      const SizedBox(height: 5),
                      Text(report.source,
                          style: smallValueStyle,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CALLS', style: labelStyle),
                                const SizedBox(height: 5),
                                // Calls badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _isDark
                                        ? const Color(0xFF10B981)
                                            .withValues(alpha: 0.15)
                                        : const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('${report.calls}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF065F46))),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('LEADS', style: labelStyle),
                                const SizedBox(height: 5),
                                // Leads badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _isDark
                                        ? _kIndigo.withValues(alpha: 0.2)
                                        : _kSoftLilac,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('${report.leads}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _kIndigoDark)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Three-dot menu ─────────────────────────────────────────────
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<int>(
              padding: EdgeInsets.zero,
              color: _isDark ? const Color(0xFF2A2750) : Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : _kIndigo.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert_rounded,
                    color: _isDark ? _kIndigoLight : _kIndigoDark, size: 17),
              ),
              onSelected: (value) async {
                final vm = context.read<MarketingReportViewmodel>();
                if (value == 1) {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: vm),
                          ChangeNotifierProvider.value(
                              value: context.read<SourceViewmodel>()),
                          ChangeNotifierProvider.value(
                              value:
                                  context.read<CategoryMarketingViewmodel>()),
                          ChangeNotifierProvider.value(
                              value: context.read<LocationViewmodel>()),
                          ChangeNotifierProvider.value(
                              value: context.read<SalesPersonViewmodel>()),
                        ],
                        child: EditMarketingReportPage(report: report),
                      ),
                    ),
                  );
                  if (updated == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Report updated successfully!'),
                      backgroundColor: _kIndigo,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ));
                  }
                } else if (value == 2) {
                  if (vm.deleteReportLoading) return;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor:
                          _isDark ? const Color(0xFF2A2750) : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      title: Text('Delete Report',
                          style: TextStyle(
                              color: _isDark ? Colors.white : _kMetricInk,
                              fontWeight: FontWeight.w700)),
                      content: Text(
                          'Are you sure you want to delete this report?',
                          style: TextStyle(
                              color:
                                  _isDark ? Colors.white70 : Colors.black87)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(dCtx).pop(false),
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: _isDark
                                        ? Colors.white54
                                        : Colors.grey))),
                        TextButton(
                            onPressed: () => Navigator.of(dCtx).pop(true),
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    // ignore: use_build_context_synchronously
                    vm.deleteReport(report.id, context);
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 1,
                    child: Row(children: [
                      Icon(Icons.edit_outlined,
                          size: 16,
                          color: _isDark ? _kIndigoLight : _kIndigoDark),
                      const SizedBox(width: 8),
                      Text('Edit',
                          style: TextStyle(
                              color: _isDark ? _kIndigoLight : _kIndigoDark,
                              fontWeight: FontWeight.w600)),
                    ])),
                const PopupMenuItem(
                  value: 2,
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 16),
                    SizedBox(width: 8),
                    Text('Delete',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => MarketingReportViewmodel()..fetchReports()),
        ChangeNotifierProvider(
            create: (_) => SourceViewmodel()..fetchSources()),
        ChangeNotifierProvider(
            create: (_) => CategoryMarketingViewmodel()..fetchCategories()),
        ChangeNotifierProvider(
            create: (_) => LocationViewmodel()..fetchLocations()),
        ChangeNotifierProvider(
            create: (_) => SalesPersonViewmodel()..getAllSalesPerson()),
      ],
      child: Builder(builder: (innerContext) {
        return Scaffold(
          backgroundColor:
              _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
          body: Consumer<MarketingReportViewmodel>(builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: _kIndigo));
            }
            if (vm.errorMessage != null) {
              return Center(child: Text('Error: ${vm.errorMessage}'));
            }
            final filteredReports = _filterReports(vm.reports);

            return Column(
              children: [
                const SizedBox(height: 6),
                _buildSearchBar(innerContext),
                const SizedBox(height: 4),
                Expanded(
                  child: filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: _isDark
                                      ? _kIndigo.withValues(alpha: 0.15)
                                      : _kSoftLilac,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.description_outlined,
                                    size: 32,
                                    color:
                                        _isDark ? _kIndigoLight : _kIndigoDark),
                              ),
                              const SizedBox(height: 12),
                              Text('No reports available',
                                  style: TextStyle(
                                      color: _isDark
                                          ? Colors.white60
                                          : _kMetricInk,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            return _buildReportCard(
                                context, filteredReports[index]);
                          },
                        ),
                ),
              ],
            );
          }),
          floatingActionButton: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: _kIndigo,
              onPressed: () async {
                final vm = innerContext.read<MarketingReportViewmodel>();
                final created = await Navigator.push<bool>(
                  innerContext,
                  MaterialPageRoute(
                    builder: (_) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(value: vm),
                        ChangeNotifierProvider.value(
                            value: innerContext.read<SourceViewmodel>()),
                        ChangeNotifierProvider.value(
                            value: innerContext
                                .read<CategoryMarketingViewmodel>()),
                        ChangeNotifierProvider.value(
                            value: innerContext.read<LocationViewmodel>()),
                        ChangeNotifierProvider.value(
                            value: innerContext.read<SalesPersonViewmodel>()),
                      ],
                      child: const AddReportStep1(),
                    ),
                  ),
                );
                if (created == true && mounted) {
                  ScaffoldMessenger.of(innerContext).showSnackBar(SnackBar(
                    content: const Text('Report added successfully!'),
                    backgroundColor: _kIndigo,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ));
                }
              },
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      }),
    );
  }
}
