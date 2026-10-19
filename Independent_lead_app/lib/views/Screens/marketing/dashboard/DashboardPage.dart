// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/views/bottom_bar/home_screen.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/dataScreen.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/reports.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/bottom_nav/app_bottom_nav.dart';

// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';

// import 'package:pokakbilling/models/services/lead_services.dart';
// import 'package:pokakbilling/models/services/marketing_report_service.dart';
// import 'package:pokakbilling/models/services/marketing_source.dart';
// import 'package:pokakbilling/models/services/marketing_location.dart';

// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart'
//     as MR;
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
//     as SModel;
// import 'package:pokakbilling/models/data-models/lead_model.dart';

// import 'package:pokakbilling/views/Screens/marketing/report/utils/marketing_pdf.dart';
// import 'package:pokakbilling/views/Screens/marketing/report/utils/pdf_previewscreen.dart';

// const _kSoftLilac = Color(0xFFF0E8FF);
// const _kGradientStart = Color(0xFF9B68F9);
// const _kGradientEnd = Color(0xFFFFFFFF);
// const Color _metricInk = Color(0xFF201E4F);
// const Color _metricSub = Color(0xFF7F7EA0);

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   int _selectedIndexBottomNav = 1;
//   int _selectedSegment = 2; // 0=today, 1=week, 2=month

//   // header stats
//   int? _leadCount;
//   bool _isLeadLoading = false;

//   int? _sourceCount;
//   bool _isSourceLoading = false;

//   int? _callsCount;
//   bool _isCallsLoading = false;

//   int _locationCount = 0;
//   bool _isLocationLoading = false;
//   String? _locationError;
//   VoidCallback? _locationVmListener;

//   List<SModel.Source>? _sourcesCache;
//   List<MR.MarketingReport>? _reportsCache;

//   bool get _pageLoading {
//     // Full-screen gate until all four datasets are ready
//     return _isLeadLoading ||
//         _isSourceLoading ||
//         _isCallsLoading ||
//         _isLocationLoading ||
//         _leadCount == null ||
//         _sourceCount == null ||
//         _callsCount == null;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initLeadCount();
//     _initSourceCount();
//     _initCallsAndReports();
//     _initLocationCount();
//   }

//   @override
//   void dispose() {
//     try {
//       final locVm = Provider.of<LocationViewmodel>(context, listen: false);
//       if (_locationVmListener != null) {
//         locVm.removeListener(_locationVmListener!);
//       }
//     } catch (_) {}
//     super.dispose();
//   }

//   // ---------- LOCATION ----------
//   Future<void> _initLocationCount() async {
//     try {
//       final vm = Provider.of<LocationViewmodel>(context, listen: false);
//       setState(() {
//         _locationCount = vm.locations.length;
//         _isLocationLoading = vm.isLoading;
//         _locationError = vm.errorMessage;
//       });
//       _locationVmListener = () {
//         if (!mounted) return;
//         setState(() {
//           _locationCount = vm.locations.length;
//           _isLocationLoading = vm.isLoading;
//           _locationError = vm.errorMessage;
//         });
//       };
//       vm.addListener(_locationVmListener!);
//       return;
//     } catch (_) {}

//     setState(() {
//       _isLocationLoading = true;
//       _locationError = null;
//     });

//     try {
//       final list = await LocationServices.getLocations();
//       if (!mounted) return;
//       setState(() {
//         _locationCount = list.length;
//         _isLocationLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _locationCount = 0;
//         _isLocationLoading = false;
//         _locationError = e.toString();
//       });
//     }
//   }

//   // ---------- LEADS ----------
//   Future<void> _initLeadCount() async {
//     try {
//       final vm = Provider.of<LeadViewmodel>(context, listen: false);
//       setState(() {
//         _leadCount = vm.leadList.length;
//         _isLeadLoading = vm.getLeadLoader;
//       });
//       vm.addListener(() {
//         if (!mounted) return;
//         setState(() {
//           _leadCount = vm.leadList.length;
//           _isLeadLoading = vm.getLeadLoader;
//         });
//       });
//     } catch (_) {
//       setState(() => _isLeadLoading = true);
//       try {
//         final list = await LeadServices.getLeads();
//         if (!mounted) return;
//         setState(() {
//           _leadCount = list.length;
//           _isLeadLoading = false;
//         });
//       } catch (_) {
//         if (!mounted) return;
//         setState(() {
//           _leadCount = 0;
//           _isLeadLoading = false;
//         });
//       }
//     }
//   }

//   // ---------- SOURCES ----------
//   Future<void> _initSourceCount() async {
//     try {
//       final vm = Provider.of<SourceViewmodel>(context, listen: false);
//       setState(() {
//         _sourceCount = vm.sources.length;
//         _isSourceLoading = vm.isLoading;
//         _sourcesCache = vm.sources.map((s) {
//           return s;
//           return SModel.Source.fromJson(s as Map<String, dynamic>);
//         }).toList();
//       });
//       vm.addListener(() {
//         if (!mounted) return;
//         setState(() {
//           _sourceCount = vm.sources.length;
//           _isSourceLoading = vm.isLoading;
//           _sourcesCache = vm.sources.map((s) {
//             return s;
//             return SModel.Source.fromJson(s as Map<String, dynamic>);
//           }).toList();
//         });
//       });
//     } catch (_) {
//       // fallback to API when provider isn't mounted above
//       setState(() => _isSourceLoading = true);
//       try {
//         final list = await SourceServices.getSources();
//         if (!mounted) return;
//         setState(() {
//           _sourceCount = list.length;
//           _isSourceLoading = false;
//           _sourcesCache = list;
//         });
//       } catch (_) {
//         if (!mounted) return;
//         setState(() {
//           _sourceCount = 0;
//           _isSourceLoading = false;
//           _sourcesCache = const [];
//         });
//       }
//     }
//   }

//   // ---------- CALLS ----------
//   Future<void> _initCallsAndReports() async {
//     try {
//       final vm = Provider.of<MarketingReportViewmodel>(context, listen: false);
//       setState(() {
//         _reportsCache = vm.reports
//             .map((r) => MR.MarketingReport(
//                   id: r.id,
//                   date: r.date,
//                   salespersonId: r.salespersonId,
//                   salesperson: r.salesperson,
//                   sourceId: r.sourceId,
//                   source: r.source,
//                   locationId: r.locationId,
//                   location: r.location,
//                   categoryId: r.categoryId,
//                   category: r.category,
//                   calls: r.calls ?? 0,
//                   leads: r.leads ?? 0,
//                 ))
//             .toList();
//         _callsCount = _reportsCache!.fold<int>(0, (sum, r) => sum + r.calls);
//         _isCallsLoading = vm.isLoading;
//       });
//       vm.addListener(() {
//         if (!mounted) return;
//         final list = vm.reports
//             .map((r) => MR.MarketingReport(
//                   id: r.id,
//                   date: r.date,
//                   salespersonId: r.salespersonId,
//                   salesperson: r.salesperson,
//                   sourceId: r.sourceId,
//                   source: r.source,
//                   locationId: r.locationId,
//                   location: r.location,
//                   categoryId: r.categoryId,
//                   category: r.category,
//                   calls: r.calls ?? 0,
//                   leads: r.leads ?? 0,
//                 ))
//             .toList();
//         setState(() {
//           _reportsCache = list;
//           _callsCount = list.fold<int>(0, (sum, r) => sum + r.calls);
//           _isCallsLoading = vm.isLoading;
//         });
//       });
//     } catch (_) {
//       setState(() => _isCallsLoading = true);
//       try {
//         final raw = await MarketingReportService.getReports();
//         final parsed = raw
//             .map((r) => MR.MarketingReport.fromJson(r as Map<String, dynamic>))
//             .toList();
//         if (!mounted) return;
//         setState(() {
//           _reportsCache = parsed;
//           _callsCount = parsed.fold<int>(0, (sum, r) => sum + r.calls);
//           _isCallsLoading = false;
//         });
//       } catch (_) {
//         if (!mounted) return;
//         setState(() {
//           _reportsCache = const [];
//           _callsCount = 0;
//           _isCallsLoading = false;
//         });
//       }
//     }
//   }

//   // ---------- HELPERS ----------
//   DateTimeRange _rangeForSegment(int segment) {
//     final now = DateTime.now();
//     if (segment == 0) {
//       final start = DateTime(now.year, now.month, now.day);
//       final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
//       return DateTimeRange(start: start, end: end);
//     } else if (segment == 1) {
//       // Mon..Sun
//       final weekday = now.weekday; // 1..7
//       final start = DateTime(now.year, now.month, now.day)
//           .subtract(Duration(days: weekday - 1));
//       final end = DateTime(start.year, start.month, start.day, 23, 59, 59)
//           .add(const Duration(days: 6));
//       return DateTimeRange(start: start, end: end);
//     } else {
//       final start = DateTime(now.year, now.month, 1);
//       final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
//       return DateTimeRange(start: start, end: end);
//     }
//   }

//   bool _isInRange(String dateStr, DateTimeRange r) {
//     try {
//       final dt = DateTime.tryParse(dateStr);
//       if (dt == null) return false;
//       return !dt.isBefore(r.start) && !dt.isAfter(r.end);
//     } catch (_) {
//       return false;
//     }
//   }

//   /// Use provider if mounted; else cached list/fallback
//   List<SModel.Source> _safeSources(BuildContext context) {
//     try {
//       return Provider.of<SourceViewmodel>(context).sources;
//     } catch (_) {
//       return _sourcesCache ?? const [];
//     }
//   }

//   /// Build leaderboard of sources by lead count in the selected range
//   List<Map<String, dynamic>> _computeTopSources({
//     required List<SModel.Source> sources,
//     required List<LeadModel> leads,
//     required int segment,
//   }) {
//     final range = _rangeForSegment(segment);
//     final Map<String, int> counts = {};

//     // Source names from master table
//     final sourceNames = sources
//         .map((s) => (s.name ?? '').trim())
//         .where((s) => s.isNotEmpty)
//         .toList();

//     for (final lead in leads) {
//       // ✅ FIXED: use createdAt instead of date
//       if (!_isInRange(lead.createdAt, range)) continue;

//       // ✅ FIXED: use source instead of leadSource
//       final srcRaw = (lead.source ?? '').trim();
//       if (srcRaw.isEmpty) continue;

//       final matched = sourceNames.firstWhere(
//         (n) => n.toLowerCase() == srcRaw.toLowerCase(),
//         orElse: () => 'Other',
//       );

//       counts[matched] = (counts[matched] ?? 0) + 1;
//     }

//     final items = counts.entries
//         .map((e) => {
//               'label': e.key,
//               'value': e.value,
//             })
//         .toList()
//       ..sort(
//         (a, b) => (b['value'] as int).compareTo(a['value'] as int),
//       );

//     return items;
//   }

//   Future<void> _exportPdf(BuildContext context) async {
//     final reports = _reportsCache ?? [];
//     if (reports.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No reports available to export')),
//       );
//       return;
//     }
//     final bytes = await buildMarketingPdfSimple(reports: reports);
//     if (!mounted) return;
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => PdfPreviewScreen(
//           title: 'Marketing Report',
//           pdfBytesBuilder: (_) async => bytes,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Use LeadViewmodel (expected to be provided globally)
//     final leadVm = Provider.of<LeadViewmodel>(context);

//     final sources = _safeSources(context);
//     final leads = leadVm.leadList;
//     final topSources = _computeTopSources(
//         sources: sources, leads: leads, segment: _selectedSegment);

//     // header stats always total
//     final statsLocal = [
//       {
//         'icon': Icons.trending_up_outlined,
//         'value': _isLeadLoading ? '...' : '${_leadCount ?? 0}',
//         'label': 'Leads Generated'
//       },
//       {
//         'icon': Icons.location_on_outlined,
//         'value': _isLocationLoading ? '...' : '$_locationCount',
//         'label': 'Number of locations'
//       },
//       {
//         'icon': Icons.phone_outlined,
//         'value': _isCallsLoading ? '...' : '${_callsCount ?? 0}',
//         'label': 'Calls Made'
//       },
//       {
//         'icon': Icons.share_outlined,
//         'value': _isSourceLoading ? '...' : '${_sourceCount ?? 0}',
//         'label': 'Total Source added'
//       },
//     ];

//     return Scaffold(
//       backgroundColor: AppColors.violetblue,
//       appBar: AppBar(
//         backgroundColor: AppColors.violetblue,
//         automaticallyImplyLeading: false,
//         centerTitle: _selectedIndexBottomNav != 3,
//         titleSpacing: 0,
//         title: Row(
//           children: [
//             if (_selectedIndexBottomNav == 3) const SizedBox(width: 24),
//             Expanded(
//               child: Text(
//                 _selectedIndexBottomNav == 1
//                     ? 'Marketing Dashboard'
//                     : _selectedIndexBottomNav == 2
//                         ? 'Marketing Data'
//                         : _selectedIndexBottomNav == 3
//                             ? 'Marketing Reports'
//                             : 'Home',
//                 textAlign: _selectedIndexBottomNav == 3
//                     ? TextAlign.left
//                     : TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             if (_selectedIndexBottomNav == 3)
//               Padding(
//                 padding: const EdgeInsets.only(right: 20),
//                 child: SizedBox(
//                   height: 30,
//                   width: 82,
//                   child: ElevatedButton.icon(
//                     onPressed: () => _exportPdf(context),
//                     icon: const Icon(Icons.upload_outlined,
//                         size: 16, color: AppColors.violetblue),
//                     label: const Text(
//                       'Export',
//                       overflow: TextOverflow.fade,
//                       style: TextStyle(
//                         color: AppColors.violetblue,
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       elevation: 0,
//                       padding: EdgeInsets.zero,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: MarketingBottomNav(
//         currentIndex: _selectedIndexBottomNav,
//         onTap: (i) {
//           if (i == 0) {
//             Navigator.popUntil(context, (route) => route.isFirst);
//           } else {
//             setState(() => _selectedIndexBottomNav = i);
//           }
//         },
//       ),
//       body: _pageLoading
//           ? const _FullPageLoader()
//           : IndexedStack(
//               index: _selectedIndexBottomNav,
//               children: [
//                 // Important: disable Hero only for the *inactive* tabs to avoid duplicate DefaultHeroTag
//                 HeroMode(
//                   enabled: _selectedIndexBottomNav == 0,
//                   child: const HomePage(),
//                 ),
//                 HeroMode(
//                   enabled: _selectedIndexBottomNav == 1,
//                   child: SafeArea(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // header stats
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//                           child: _buildStatsGridFromList(statsLocal),
//                         ),
//                         const SizedBox(height: 16),

//                         // section title
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Text(
//                             _selectedSegment == 0
//                                 ? 'Top Leads Generated sources (Today)'
//                                 : _selectedSegment == 1
//                                     ? 'Top Leads Generated sources (This Week)'
//                                     : 'Top Leads Generated sources (This Month)',
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         // segmented control
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: _buildSegmentedControl(),
//                         ),
//                         const SizedBox(height: 12),

//                         // list or empty
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: (topSources.isEmpty ||
//                                     topSources
//                                         .every((m) => (m['value'] as int) == 0))
//                                 ? const Center(
//                                     child: Text(
//                                       'No leads generated',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   )
//                                 : ListView.separated(
//                                     physics: const BouncingScrollPhysics(),
//                                     padding: const EdgeInsets.only(bottom: 8),
//                                     itemCount: topSources.length,
//                                     separatorBuilder: (_, __) =>
//                                         const SizedBox(height: 12),
//                                     itemBuilder: (context, i) {
//                                       final m = topSources[i];
//                                       return _SourceGradientCard(
//                                         title: m['label'] as String,
//                                         value: m['value'] as int,
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 HeroMode(
//                   enabled: _selectedIndexBottomNav == 2,
//                   child: const DataScreen(),
//                 ),
//                 HeroMode(
//                   enabled: _selectedIndexBottomNav == 3,
//                   child: const ReportsScreen(),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildSegmentedControl() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       padding: const EdgeInsets.all(6),
//       child: Row(
//         children: [
//           _segmentedButton('Today', 0),
//           _segmentedButton('This week', 1),
//           _segmentedButton('This Month', 2),
//         ],
//       ),
//     );
//   }

//   Widget _segmentedButton(String title, int index) {
//     final isSelected = _selectedSegment == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedSegment = index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: isSelected
//               ? BoxDecoration(
//                   color: _kSoftLilac,
//                   borderRadius: BorderRadius.circular(20),
//                 )
//               : null,
//           child: Center(
//             child: Text(
//               title,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color:
//                     isSelected ? AppColors.violetblue : const Color(0xFF9A9AB5),
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGridFromList(List<Map<String, dynamic>> stats) {
//     // Keep exact visual; nothing removed.
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(child: _StatCard(data: stats[0])),
//             const SizedBox(width: 12),
//             Expanded(child: _StatCard(data: stats[1])),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _StatCard(data: stats[2])),
//             const SizedBox(width: 12),
//             Expanded(child: _StatCard(data: stats[3])),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _FullPageLoader extends StatelessWidget {
//   const _FullPageLoader();

//   @override
//   Widget build(BuildContext context) {
//     return const SafeArea(
//       child: Center(
//         child: SizedBox(
//           width: 48,
//           height: 48,
//           child: CircularProgressIndicator(strokeWidth: 4),
//         ),
//       ),
//     );
//   }
// }

// class _SourceGradientCard extends StatelessWidget {
//   final String title;
//   final int value;
//   const _SourceGradientCard({required this.title, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 60,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [_kGradientStart, _kGradientEnd],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   '$value',
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: _metricInk,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.trending_up, size: 18, color: _metricInk),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final Map<String, dynamic> data;
//   const _StatCard({required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final icon = data['icon'] as IconData;
//     final value = data['value'] as String;
//     final label = data['label'] as String;

//     return Container(
//       height: 138,
//       decoration: BoxDecoration(
//         color: _kSoftLilac,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: AppColors.violetblue, size: 22),
//           ),
//           Text(
//             value,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w700,
//               color: _metricInk,
//             ),
//           ),
//           Text(
//             label,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: _metricSub,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
