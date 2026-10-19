// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:pokakbilling/views/bottom_bar/home_screen.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/dataScreen.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/reports.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/bottom_nav/app_bottom_nav.dart';

// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';

// import 'package:pokakbilling/models/services/marketing_report_service.dart';
// import 'package:pokakbilling/models/services/marketing_source.dart';
// import 'package:pokakbilling/models/services/marketing_location.dart';

// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart'
//     as MR;
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
//     as SModel;

// import 'package:pokakbilling/views/Screens/marketing/report/utils/marketing_pdf.dart';
// import 'package:pokakbilling/views/Screens/marketing/report/utils/pdf_previewscreen.dart';

// // ── Theme constants matching LeadScreen ──────────────────────────────────────
// const _kIndigo = Color(0xFF6366F1);
// const _kIndigoLight = Color(0xFF818CF8);
// const _kIndigoDark = Color(0xFF4338CA);
// const _kSoftLilac = Color(0xFFF0EEFF);
// const _kCardBgLight = Color(0xFFFAFAFF);
// const _kGradientStart = Color(0xFF6366F1);
// const _kGradientEnd = Color(0xFFFFFFFF);
// const Color _metricInk = Color(0xFF1E1B4B);
// const Color _metricSub = Color(0xFF6B7280);

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   int _selectedIndexBottomNav = 1;
//   int _selectedSegment = 2;

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

//   bool get _pageLoading =>
//       _isSourceLoading ||
//       _isCallsLoading ||
//       _isLocationLoading ||
//       _sourceCount == null ||
//       _callsCount == null;

//   bool get _isDark => Theme.of(context).brightness == Brightness.dark;

//   @override
//   void initState() {
//     super.initState();
//     _initSourceCount();
//     _initCallsAndReports();
//     _initLocationCount();
//   }

//   @override
//   void dispose() {
//     try {
//       final locVm = Provider.of<LocationViewmodel>(context, listen: false);
//       if (_locationVmListener != null)
//         locVm.removeListener(_locationVmListener!);
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

//   // ---------- SOURCES ----------
//   Future<void> _initSourceCount() async {
//     try {
//       final vm = Provider.of<SourceViewmodel>(context, listen: false);
//       setState(() {
//         _sourceCount = vm.sources.length;
//         _isSourceLoading = vm.isLoading;
//         _sourcesCache = List<SModel.Source>.from(vm.sources);
//       });
//       vm.addListener(() {
//         if (!mounted) return;
//         setState(() {
//           _sourceCount = vm.sources.length;
//           _isSourceLoading = vm.isLoading;
//           _sourcesCache = List<SModel.Source>.from(vm.sources);
//         });
//       });
//     } catch (_) {
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

//   // ---------- CALLS + LEADS ----------
//   Future<void> _initCallsAndReports() async {
//     try {
//       final vm = Provider.of<MarketingReportViewmodel>(context, listen: false);

//       void applyReports(List<MR.MarketingReport> list) {
//         _reportsCache = list;
//         _callsCount = list.fold<int>(0, (sum, r) => sum + (r.calls ?? 0));
//         _leadCount = list.fold<int>(0, (sum, r) => sum + (r.leads ?? 0));
//         _isCallsLoading = false;
//         _isLeadLoading = false;
//       }

//       setState(() {
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
//         applyReports(list);
//         _isCallsLoading = vm.isLoading;
//         _isLeadLoading = vm.isLoading;
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
//         setState(() => applyReports(list));
//       });
//     } catch (_) {
//       setState(() {
//         _isCallsLoading = true;
//         _isLeadLoading = true;
//       });
//       try {
//         final raw = await MarketingReportService.getReports();
//         final parsed = raw
//             .map((r) => MR.MarketingReport.fromJson(r as Map<String, dynamic>))
//             .toList();
//         if (!mounted) return;
//         setState(() {
//           _reportsCache = parsed;
//           _callsCount = parsed.fold<int>(0, (sum, r) => sum + (r.calls ?? 0));
//           _leadCount = parsed.fold<int>(0, (sum, r) => sum + (r.leads ?? 0));
//           _isCallsLoading = false;
//           _isLeadLoading = false;
//         });
//       } catch (_) {
//         if (!mounted) return;
//         setState(() {
//           _reportsCache = const [];
//           _callsCount = 0;
//           _leadCount = 0;
//           _isCallsLoading = false;
//           _isLeadLoading = false;
//         });
//       }
//     }
//   }

//   // ---------- HELPERS ----------
//   DateTimeRange _rangeForSegment(int segment) {
//     final now = DateTime.now();
//     if (segment == 0) {
//       final start = DateTime(now.year, now.month, now.day);
//       return DateTimeRange(
//           start: start,
//           end: DateTime(now.year, now.month, now.day, 23, 59, 59));
//     } else if (segment == 1) {
//       final weekday = now.weekday;
//       final start = DateTime(now.year, now.month, now.day)
//           .subtract(Duration(days: weekday - 1));
//       return DateTimeRange(
//           start: start,
//           end: DateTime(start.year, start.month, start.day, 23, 59, 59)
//               .add(const Duration(days: 6)));
//     } else {
//       return DateTimeRange(
//           start: DateTime(now.year, now.month, 1),
//           end: DateTime(now.year, now.month + 1, 0, 23, 59, 59));
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

//   List<SModel.Source> _safeSources(BuildContext context) {
//     try {
//       return Provider.of<SourceViewmodel>(context).sources;
//     } catch (_) {
//       return _sourcesCache ?? const [];
//     }
//   }

//   List<Map<String, dynamic>> _computeTopSources({
//     required List<SModel.Source> sources,
//     required List<MR.MarketingReport> reports,
//     required int segment,
//   }) {
//     final range = _rangeForSegment(segment);
//     final Map<String, int> counts = {};
//     final Map<int, String> idToName = {
//       for (final s in sources)
//         if (s.name.trim().isNotEmpty) s.id: s.name.trim(),
//     };
//     for (final report in reports) {
//       if (!_isInRange(report.date, range)) continue;
//       final resolvedName =
//           idToName[report.sourceId] ?? 'Source #${report.sourceId}';
//       counts[resolvedName] = (counts[resolvedName] ?? 0) + (report.leads ?? 0);
//     }
//     final items = counts.entries
//         .map((e) => {'label': e.key, 'value': e.value})
//         .toList()
//       ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));
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

//   // ── App bar ──────────────────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar(String title) {
//     return AppBar(
//       backgroundColor: _isDark ? const Color(0xFF1A1730) : _kIndigo,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       titleSpacing: 0,
//       title: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 title,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//             if (_selectedIndexBottomNav == 3)
//               _ExportButton(onPressed: () => _exportPdf(context)),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sources = _safeSources(context);
//     final topSources = _computeTopSources(
//       sources: sources,
//       reports: _reportsCache ?? [],
//       segment: _selectedSegment,
//     );

//     final statsLocal = [
//       {
//         'icon': Icons.trending_up_outlined,
//         'value': _isLeadLoading ? '…' : '${_leadCount ?? 0}',
//         'label': 'Leads Generated',
//         'accent': const Color(0xFF6366F1),
//       },
//       {
//         'icon': Icons.location_on_outlined,
//         'value': _isLocationLoading ? '…' : '$_locationCount',
//         'label': 'Locations',
//         'accent': const Color(0xFF06B6D4),
//       },
//       {
//         'icon': Icons.phone_outlined,
//         'value': _isCallsLoading ? '…' : '${_callsCount ?? 0}',
//         'label': 'Calls Made',
//         'accent': const Color(0xFF10B981),
//       },
//       {
//         'icon': Icons.share_outlined,
//         'value': _isSourceLoading ? '…' : '${_sourceCount ?? 0}',
//         'label': 'Total Sources',
//         'accent': const Color(0xFFF59E0B),
//       },
//     ];

//     final String appBarTitle = _selectedIndexBottomNav == 1
//         ? 'Marketing Dashboard'
//         : _selectedIndexBottomNav == 2
//             ? 'Marketing Data'
//             : _selectedIndexBottomNav == 3
//                 ? 'Marketing Reports'
//                 : 'Home';

//     return Scaffold(
//       backgroundColor:
//           _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
//       appBar: _buildAppBar(appBarTitle),
//       bottomNavigationBar: _StyledMarketingBottomNav(
//         currentIndex: _selectedIndexBottomNav,
//         isDark: _isDark,
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
//                         const SizedBox(height: 16),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           child: _buildStatsGrid(statsLocal),
//                         ),
//                         const SizedBox(height: 20),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           child: _sectionLabel(
//                             _selectedSegment == 0
//                                 ? 'Top Sources — Today'
//                                 : _selectedSegment == 1
//                                     ? 'Top Sources — This Week'
//                                     : 'Top Sources — This Month',
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           child: _buildSegmentedControl(),
//                         ),
//                         const SizedBox(height: 12),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             child: (topSources.isEmpty ||
//                                     topSources
//                                         .every((m) => (m['value'] as int) == 0))
//                                 ? Center(
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.all(18),
//                                           decoration: BoxDecoration(
//                                             color: _isDark
//                                                 ? _kIndigo.withOpacity(0.15)
//                                                 : _kSoftLilac,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           child: Icon(
//                                             Icons.bar_chart_rounded,
//                                             size: 32,
//                                             color: _isDark
//                                                 ? _kIndigoLight
//                                                 : _kIndigoDark,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 12),
//                                         Text(
//                                           'No leads generated',
//                                           style: TextStyle(
//                                             color: _isDark
//                                                 ? Colors.white70
//                                                 : _metricInk,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                                 : ListView.separated(
//                                     physics: const BouncingScrollPhysics(),
//                                     padding: const EdgeInsets.only(bottom: 24),
//                                     itemCount: topSources.length,
//                                     separatorBuilder: (_, __) =>
//                                         const SizedBox(height: 10),
//                                     itemBuilder: (context, i) {
//                                       final m = topSources[i];
//                                       return _SourceGradientCard(
//                                         title: m['label'] as String,
//                                         value: m['value'] as int,
//                                         rank: i + 1,
//                                         isDark: _isDark,
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

//   Widget _sectionLabel(String text) => Row(children: [
//         Container(
//           width: 3,
//           height: 14,
//           decoration: BoxDecoration(
//               color: _isDark ? _kIndigoLight : _kIndigo,
//               borderRadius: BorderRadius.circular(3)),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               fontWeight: FontWeight.w800,
//               fontSize: 13.5,
//               color: _isDark ? Colors.white : _metricInk,
//             ),
//           ),
//         ),
//       ]);

//   Widget _buildSegmentedControl() {
//     return Container(
//       decoration: BoxDecoration(
//         color: _isDark
//             ? Colors.white.withOpacity(0.08)
//             : Colors.white.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: _isDark
//               ? Colors.white.withOpacity(0.1)
//               : _kIndigo.withOpacity(0.15),
//           width: 1,
//         ),
//       ),
//       padding: const EdgeInsets.all(4),
//       child: Row(
//         children: [
//           _segBtn('Today', 0),
//           _segBtn('This Week', 1),
//           _segBtn('This Month', 2),
//         ],
//       ),
//     );
//   }

//   Widget _segBtn(String title, int index) {
//     final isSelected = _selectedSegment == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedSegment = index),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 9),
//           decoration: isSelected
//               ? BoxDecoration(
//                   color: _kIndigo,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: _kIndigo.withOpacity(0.35),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 )
//               : null,
//           child: Center(
//             child: Text(
//               title,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: isSelected
//                     ? Colors.white
//                     : (_isDark ? Colors.white54 : _metricSub),
//                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid(List<Map<String, dynamic>> stats) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         // ── FIX: increased from 1.35 → 1.55 so each card is taller,
//         //         giving the inner Column enough room to avoid overflow.
//         childAspectRatio: 1.6,
//       ),
//       itemCount: stats.length,
//       itemBuilder: (_, i) {
//         final s = stats[i];
//         final accent = s['accent'] as Color;
//         return _StatCard(
//           icon: s['icon'] as IconData,
//           value: s['value'] as String,
//           label: s['label'] as String,
//           accent: accent,
//           isDark: _isDark,
//         );
//       },
//     );
//   }
// }

// // ── Export button ─────────────────────────────────────────────────────────────
// class _ExportButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   const _ExportButton({required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 30,
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: const Icon(Icons.upload_outlined,
//             size: 15, color: Color(0xFF4338CA)),
//         label: const Text(
//           'Export',
//           style: TextStyle(
//             color: Color(0xFF4338CA),
//             fontWeight: FontWeight.w700,
//             fontSize: 12,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Styled bottom nav ─────────────────────────────────────────────────────────
// class _StyledMarketingBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final bool isDark;
//   final ValueChanged<int> onTap;
//   const _StyledMarketingBottomNav(
//       {required this.currentIndex, required this.isDark, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return MarketingBottomNav(currentIndex: currentIndex, onTap: onTap);
//   }
// }

// // ── Stat card ─────────────────────────────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color accent;
//   final bool isDark;
//   const _StatCard(
//       {required this.icon,
//       required this.value,
//       required this.label,
//       required this.accent,
//       required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // ── FIX: reduced padding from 14 → 12 to recover vertical space
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color:
//               isDark ? Colors.white.withOpacity(0.1) : accent.withOpacity(0.18),
//           width: 1,
//         ),
//         boxShadow: isDark
//             ? null
//             : [
//                 BoxShadow(
//                   color: accent.withOpacity(0.08),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//       ),
//       // ── FIX: LayoutBuilder reads the real constrained height at runtime;
//       //         FittedBox(scaleDown) proportionally shrinks the Column only
//       //         when it would overflow — works on any screen density.
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: SizedBox(
//               width: constraints.maxWidth,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       color: isDark
//                           ? accent.withOpacity(0.18)
//                           : accent.withOpacity(0.10),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: Icon(icon, size: 18, color: accent),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w800,
//                       color: isDark ? Colors.white : _metricInk,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     label,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? Colors.white54 : _metricSub,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ── Source gradient card ──────────────────────────────────────────────────────
// class _SourceGradientCard extends StatelessWidget {
//   final String title;
//   final int value;
//   final int rank;
//   final bool isDark;
//   const _SourceGradientCard(
//       {required this.title,
//       required this.value,
//       required this.rank,
//       required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 62,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: isDark
//               ? [const Color(0xFF4338CA), const Color(0xFF2D2A5E)]
//               : [_kGradientStart, _kGradientEnd],
//         ),
//         border: Border.all(
//           color: isDark
//               ? _kIndigoLight.withOpacity(0.2)
//               : _kIndigo.withOpacity(0.15),
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         child: Row(
//           children: [
//             Container(
//               width: 26,
//               height: 26,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(isDark ? 0.12 : 0.25),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   '$rank',
//                   style: const TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   '$value',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: isDark ? Colors.white : _metricInk,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Icon(
//                   Icons.trending_up,
//                   size: 16,
//                   color: isDark ? Colors.white70 : _metricInk,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Full page loader ──────────────────────────────────────────────────────────
// class _FullPageLoader extends StatelessWidget {
//   const _FullPageLoader();
//   @override
//   Widget build(BuildContext context) {
//     return const SafeArea(
//       child: Center(
//         child: SizedBox(
//           width: 44,
//           height: 44,
//           child: CircularProgressIndicator(
//             strokeWidth: 3,
//             color: _kIndigo,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/views/Screens/marketing/dashboard/dataScreen.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/reports.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/bottom_nav/app_bottom_nav.dart';

import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';

import 'package:pokakbilling/models/services/marketing_report_service.dart';
import 'package:pokakbilling/models/services/marketing_source.dart';
import 'package:pokakbilling/models/services/marketing_location.dart';

import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart'
    as MR;
import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
    as SModel;

import 'package:pokakbilling/views/Screens/marketing/report/utils/marketing_pdf.dart';
import 'package:pokakbilling/views/Screens/marketing/report/utils/pdf_previewscreen.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kSoftLilac = Color(0xFFF0EEFF);
const _kGradientStart = Color(0xFF6366F1);
const _kGradientEnd = Color(0xFFFFFFFF);
const Color _metricInk = Color(0xFF1E1B4B);
const Color _metricSub = Color(0xFF6B7280);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ── Index meaning (NO home tab here — home = Navigator.pop) ──────────────
  // 0 = Dashboard, 1 = Data, 2 = Reports
  int _selectedIndexBottomNav = 0;
  int _selectedSegment = 2;

  int? _leadCount;
  bool _isLeadLoading = false;
  int? _sourceCount;
  bool _isSourceLoading = false;
  int? _callsCount;
  bool _isCallsLoading = false;
  int _locationCount = 0;
  bool _isLocationLoading = false;
  String? _locationError;
  VoidCallback? _locationVmListener;

  List<SModel.Source>? _sourcesCache;
  List<MR.MarketingReport>? _reportsCache;

  bool get _pageLoading =>
      _isSourceLoading ||
      _isCallsLoading ||
      _isLocationLoading ||
      _sourceCount == null ||
      _callsCount == null;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _initSourceCount();
    _initCallsAndReports();
    _initLocationCount();
  }

  @override
  void dispose() {
    try {
      final locVm = Provider.of<LocationViewmodel>(context, listen: false);
      if (_locationVmListener != null) {
        locVm.removeListener(_locationVmListener!);
      }
    } catch (_) {}
    super.dispose();
  }

  // ---------- LOCATION ----------
  Future<void> _initLocationCount() async {
    try {
      final vm = Provider.of<LocationViewmodel>(context, listen: false);
      setState(() {
        _locationCount = vm.locations.length;
        _isLocationLoading = vm.isLoading;
        _locationError = vm.errorMessage;
      });
      _locationVmListener = () {
        if (!mounted) return;
        setState(() {
          _locationCount = vm.locations.length;
          _isLocationLoading = vm.isLoading;
          _locationError = vm.errorMessage;
        });
      };
      vm.addListener(_locationVmListener!);
      return;
    } catch (_) {}
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });
    try {
      final list = await LocationServices.getLocations();
      if (!mounted) return;
      setState(() {
        _locationCount = list.length;
        _isLocationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationCount = 0;
        _isLocationLoading = false;
        _locationError = e.toString();
      });
    }
  }

  // ---------- SOURCES ----------
  Future<void> _initSourceCount() async {
    try {
      final vm = Provider.of<SourceViewmodel>(context, listen: false);
      setState(() {
        _sourceCount = vm.sources.length;
        _isSourceLoading = vm.isLoading;
        _sourcesCache = List<SModel.Source>.from(vm.sources);
      });
      vm.addListener(() {
        if (!mounted) return;
        setState(() {
          _sourceCount = vm.sources.length;
          _isSourceLoading = vm.isLoading;
          _sourcesCache = List<SModel.Source>.from(vm.sources);
        });
      });
    } catch (_) {
      setState(() => _isSourceLoading = true);
      try {
        final list = await SourceServices.getSources();
        if (!mounted) return;
        setState(() {
          _sourceCount = list.length;
          _isSourceLoading = false;
          _sourcesCache = list;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _sourceCount = 0;
          _isSourceLoading = false;
          _sourcesCache = const [];
        });
      }
    }
  }

  // ---------- CALLS + LEADS ----------
  Future<void> _initCallsAndReports() async {
    try {
      final vm = Provider.of<MarketingReportViewmodel>(context, listen: false);

      void applyReports(List<MR.MarketingReport> list) {
        _reportsCache = list;
        _callsCount = list.fold<int>(0, (sum, r) => sum + (r.calls ?? 0));
        _leadCount = list.fold<int>(0, (sum, r) => sum + (r.leads ?? 0));
        _isCallsLoading = false;
        _isLeadLoading = false;
      }

      setState(() {
        final list = vm.reports
            .map((r) => MR.MarketingReport(
                  id: r.id,
                  date: r.date,
                  salespersonId: r.salespersonId,
                  salesperson: r.salesperson,
                  sourceId: r.sourceId,
                  source: r.source,
                  locationId: r.locationId,
                  location: r.location,
                  categoryId: r.categoryId,
                  category: r.category,
                  calls: r.calls ?? 0,
                  leads: r.leads ?? 0,
                ))
            .toList();
        applyReports(list);
        _isCallsLoading = vm.isLoading;
        _isLeadLoading = vm.isLoading;
      });

      vm.addListener(() {
        if (!mounted) return;
        final list = vm.reports
            .map((r) => MR.MarketingReport(
                  id: r.id,
                  date: r.date,
                  salespersonId: r.salespersonId,
                  salesperson: r.salesperson,
                  sourceId: r.sourceId,
                  source: r.source,
                  locationId: r.locationId,
                  location: r.location,
                  categoryId: r.categoryId,
                  category: r.category,
                  calls: r.calls ?? 0,
                  leads: r.leads ?? 0,
                ))
            .toList();
        setState(() => applyReports(list));
      });
    } catch (_) {
      setState(() {
        _isCallsLoading = true;
        _isLeadLoading = true;
      });
      try {
        final raw = await MarketingReportService.getReports();
        final parsed = raw
            .map((r) => MR.MarketingReport.fromJson(r as Map<String, dynamic>))
            .toList();
        if (!mounted) return;
        setState(() {
          _reportsCache = parsed;
          _callsCount = parsed.fold<int>(0, (sum, r) => sum + (r.calls ?? 0));
          _leadCount = parsed.fold<int>(0, (sum, r) => sum + (r.leads ?? 0));
          _isCallsLoading = false;
          _isLeadLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _reportsCache = const [];
          _callsCount = 0;
          _leadCount = 0;
          _isCallsLoading = false;
          _isLeadLoading = false;
        });
      }
    }
  }

  // ---------- HELPERS ----------
  DateTimeRange _rangeForSegment(int segment) {
    final now = DateTime.now();
    if (segment == 0) {
      final start = DateTime(now.year, now.month, now.day);
      return DateTimeRange(
          start: start,
          end: DateTime(now.year, now.month, now.day, 23, 59, 59));
    } else if (segment == 1) {
      final weekday = now.weekday;
      final start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: weekday - 1));
      return DateTimeRange(
          start: start,
          end: DateTime(start.year, start.month, start.day, 23, 59, 59)
              .add(const Duration(days: 6)));
    } else {
      return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59));
    }
  }

  bool _isInRange(String dateStr, DateTimeRange r) {
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return false;
      return !dt.isBefore(r.start) && !dt.isAfter(r.end);
    } catch (_) {
      return false;
    }
  }

  List<SModel.Source> _safeSources(BuildContext context) {
    try {
      return Provider.of<SourceViewmodel>(context).sources;
    } catch (_) {
      return _sourcesCache ?? const [];
    }
  }

  List<Map<String, dynamic>> _computeTopSources({
    required List<SModel.Source> sources,
    required List<MR.MarketingReport> reports,
    required int segment,
  }) {
    final range = _rangeForSegment(segment);
    final Map<String, int> counts = {};
    final Map<int, String> idToName = {
      for (final s in sources)
        if (s.name.trim().isNotEmpty) s.id: s.name.trim(),
    };
    for (final report in reports) {
      if (!_isInRange(report.date, range)) continue;
      final resolvedName =
          idToName[report.sourceId] ?? 'Source #${report.sourceId}';
      counts[resolvedName] = (counts[resolvedName] ?? 0) + (report.leads ?? 0);
    }
    final items = counts.entries
        .map((e) => {'label': e.key, 'value': e.value})
        .toList()
      ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int));
    return items;
  }

  Future<void> _exportPdf(BuildContext context) async {
    final reports = _reportsCache ?? [];
    if (reports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reports available to export')),
      );
      return;
    }
    final bytes = await buildMarketingPdfSimple(reports: reports);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          title: 'Marketing Report',
          pdfBytesBuilder: (_) async => bytes,
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(String title) {
    return AppBar(
      backgroundColor: _isDark ? const Color(0xFF1A1730) : _kIndigo,
      elevation: 0,
      // ── Back arrow → pops to main BottomBar ──────────────────────────────
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (_selectedIndexBottomNav == 2)
              _ExportButton(onPressed: () => _exportPdf(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sources = _safeSources(context);
    final topSources = _computeTopSources(
      sources: sources,
      reports: _reportsCache ?? [],
      segment: _selectedSegment,
    );

    final statsLocal = [
      {
        'icon': Icons.trending_up_outlined,
        'value': _isLeadLoading ? '…' : '${_leadCount ?? 0}',
        'label': 'Leads Generated',
        'accent': const Color(0xFF6366F1),
      },
      {
        'icon': Icons.location_on_outlined,
        'value': _isLocationLoading ? '…' : '$_locationCount',
        'label': 'Locations',
        'accent': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.phone_outlined,
        'value': _isCallsLoading ? '…' : '${_callsCount ?? 0}',
        'label': 'Calls Made',
        'accent': const Color(0xFF10B981),
      },
      {
        'icon': Icons.share_outlined,
        'value': _isSourceLoading ? '…' : '${_sourceCount ?? 0}',
        'label': 'Total Sources',
        'accent': const Color(0xFFF59E0B),
      },
    ];

    // ── Tab titles: index 0=Dashboard, 1=Data, 2=Reports ─────────────────
    final String appBarTitle = _selectedIndexBottomNav == 0
        ? 'Marketing Dashboard'
        : _selectedIndexBottomNav == 1
            ? 'Marketing Data'
            : 'Marketing Reports';

    return Scaffold(
      backgroundColor:
          _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
      appBar: _buildAppBar(appBarTitle),
      // ── Marketing-only bottom nav (Home taps pop this route) ─────────────
      bottomNavigationBar: _StyledMarketingBottomNav(
        currentIndex: _selectedIndexBottomNav,
        isDark: _isDark,
        onTap: (i) {
          if (i == 0) {
            // Home → go back to main BottomBar
            Navigator.of(context).pop();
          } else {
            // Shift: marketing nav items 1=Dashboard,2=Data,3=Reports
            // map to our internal 0=Dashboard,1=Data,2=Reports
            setState(() => _selectedIndexBottomNav = i - 1);
          }
        },
      ),
      body: _pageLoading
          ? const _FullPageLoader()
          : IndexedStack(
              index: _selectedIndexBottomNav,
              children: [
                // 0 — Dashboard
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: _buildStatsGrid(statsLocal),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: _sectionLabel(
                          _selectedSegment == 0
                              ? 'Top Sources — Today'
                              : _selectedSegment == 1
                                  ? 'Top Sources — This Week'
                                  : 'Top Sources — This Month',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: _buildSegmentedControl(),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: (topSources.isEmpty ||
                                  topSources
                                      .every((m) => (m['value'] as int) == 0))
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
                                        child: Icon(
                                          Icons.bar_chart_rounded,
                                          size: 32,
                                          color: _isDark
                                              ? _kIndigoLight
                                              : _kIndigoDark,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No leads generated',
                                        style: TextStyle(
                                          color: _isDark
                                              ? Colors.white70
                                              : _metricInk,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: topSources.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, i) {
                                    final m = topSources[i];
                                    return _SourceGradientCard(
                                      title: m['label'] as String,
                                      value: m['value'] as int,
                                      rank: i + 1,
                                      isDark: _isDark,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 1 — Data
                const DataScreen(),

                // 2 — Reports
                const ReportsScreen(),
              ],
            ),
    );
  }

  Widget _sectionLabel(String text) => Row(children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
              color: _isDark ? _kIndigoLight : _kIndigo,
              borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: _isDark ? Colors.white : _metricInk,
            ),
          ),
        ),
      ]);

  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.1)
              : _kIndigo.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _segBtn('Today', 0),
          _segBtn('This Week', 1),
          _segBtn('This Month', 2),
        ],
      ),
    );
  }

  Widget _segBtn(String title, int index) {
    final isSelected = _selectedSegment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSegment = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: isSelected
              ? BoxDecoration(
                  color: _kIndigo,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _kIndigo.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Center(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (_isDark ? Colors.white54 : _metricSub),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(List<Map<String, dynamic>> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final s = stats[i];
        final accent = s['accent'] as Color;
        return _StatCard(
          icon: s['icon'] as IconData,
          value: s['value'] as String,
          label: s['label'] as String,
          accent: accent,
          isDark: _isDark,
        );
      },
    );
  }
}

// ── Export button ─────────────────────────────────────────────────────────────
class _ExportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ExportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.upload_outlined,
            size: 15, color: Color(0xFF4338CA)),
        label: const Text(
          'Export',
          style: TextStyle(
            color: Color(0xFF4338CA),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ── Styled bottom nav wrapper ─────────────────────────────────────────────────
class _StyledMarketingBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  const _StyledMarketingBottomNav(
      {required this.currentIndex, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // currentIndex here is 0=Dashboard,1=Data,2=Reports
    // MarketingBottomNav expects 0=Home,1=Dashboard,2=Data,3=Reports
    // so we shift by +1
    return MarketingBottomNav(currentIndex: currentIndex + 1, onTap: onTap);
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool isDark;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.accent,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : accent.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? accent.withValues(alpha: 0.18)
                          : accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(icon, size: 18, color: accent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : _metricInk,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : _metricSub,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Source gradient card ──────────────────────────────────────────────────────
class _SourceGradientCard extends StatelessWidget {
  final String title;
  final int value;
  final int rank;
  final bool isDark;
  const _SourceGradientCard(
      {required this.title,
      required this.value,
      required this.rank,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? [const Color(0xFF4338CA), const Color(0xFF2D2A5E)]
              : [_kGradientStart, _kGradientEnd],
        ),
        border: Border.all(
          color: isDark
              ? _kIndigoLight.withValues(alpha: 0.2)
              : _kIndigo.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : _metricInk,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: isDark ? Colors.white70 : _metricInk,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full page loader ──────────────────────────────────────────────────────────
class _FullPageLoader extends StatelessWidget {
  const _FullPageLoader();
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: _kIndigo,
          ),
        ),
      ),
    );
  }
}











// //import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:pokakbilling/views/Screens/marketing/dashboard/dataScreen.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/reports.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/bottom_nav/app_bottom_nav.dart';

// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';

// import 'package:pokakbilling/models/services/marketing_report_service.dart';
// import 'package:pokakbilling/models/services/marketing_source.dart';
// import 'package:pokakbilling/models/services/marketing_location.dart';

// import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart'
//     as MR;
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart'
//     as SModel;

// import 'package:pokakbilling/views/Screens/marketing/report/utils/marketing_pdf.dart';
// import 'package:pokakbilling/views/Screens/marketing/report/utils/pdf_previewscreen.dart';

// // ── Tap destinations ──────────────────────────────────────────────────────────
// import 'package:pokakbilling/views/Screens/leads/lead_screens/leadsnewscreen.dart';
// import 'package:pokakbilling/views/Screens/marketing/location/location_tab.dart';
// import 'package:pokakbilling/views/Screens/marketing/source/source_tab.dart';

// // ── Theme constants ───────────────────────────────────────────────────────────
// const _kIndigo = Color(0xFF6366F1);
// const _kIndigoLight = Color(0xFF818CF8);
// const _kIndigoDark = Color(0xFF4338CA);
// const _kSoftLilac = Color(0xFFF0EEFF);
// const _kGradientStart = Color(0xFF6366F1);
// const _kGradientEnd = Color(0xFFFFFFFF);
// const Color _metricInk = Color(0xFF1E1B4B);
// const Color _metricSub = Color(0xFF6B7280);

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   // 0=Dashboard, 1=Data, 2=Reports
//   int _selectedIndexBottomNav = 0;
//   int _selectedSegment = 2;

//   // Only calls count is derived from reports; everything else comes from VMs
//   int? _callsCount;
//   bool _isCallsLoading = false;

//   VoidCallback? _locationVmListener;
//   List<SModel.Source>? _sourcesCache;
//   List<MR.MarketingReport>? _reportsCache;

//   bool get _pageLoading => _isCallsLoading || _callsCount == null;
//   bool get _isDark => Theme.of(context).brightness == Brightness.dark;

//   @override
//   void initState() {
//     super.initState();
//     _initCallsAndReports();
//     _initLocationListener();
//   }

//   @override
//   void dispose() {
//     try {
//       final locVm = Provider.of<LocationViewmodel>(context, listen: false);
//       if (_locationVmListener != null) locVm.removeListener(_locationVmListener!);
//     } catch (_) {}
//     super.dispose();
//   }

//   void _initLocationListener() {
//     try {
//       final vm = Provider.of<LocationViewmodel>(context, listen: false);
//       _locationVmListener = () { if (mounted) setState(() {}); };
//       vm.addListener(_locationVmListener!);
//     } catch (_) {}
//   }

//   Future<void> _initCallsAndReports() async {
//     try {
//       final vm = Provider.of<MarketingReportViewmodel>(context, listen: false);

//       void applyReports(List<MR.MarketingReport> list) {
//         _reportsCache = list;
//         _callsCount = list.fold<int>(0, (sum, r) => sum + (r.calls ?? 0));
//         _isCallsLoading = false;
//       }

//       setState(() {
//         final list = _mapReports(vm.reports);
//         applyReports(list);
//         _isCallsLoading = vm.isLoading;
//       });

//       vm.addListener(() {
//         if (!mounted) return;
//         setState(() => applyReports(_mapReports(vm.reports)));
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
//           _callsCount = parsed.fold<int>(0, (sum, r) => sum + (r.calls ?? 0));
//           _isCallsLoading = false;
//         });
//       } catch (_) {
//         if (!mounted) return;
//         setState(() { _reportsCache = const []; _callsCount = 0; _isCallsLoading = false; });
//       }
//     }
//   }

//   List<MR.MarketingReport> _mapReports(List<dynamic> src) => src
//       .map((r) => MR.MarketingReport(
//             id: r.id, date: r.date,
//             salespersonId: r.salespersonId, salesperson: r.salesperson,
//             sourceId: r.sourceId, source: r.source,
//             locationId: r.locationId, location: r.location,
//             categoryId: r.categoryId, category: r.category,
//             calls: r.calls ?? 0, leads: r.leads ?? 0,
//           ))
//       .toList();

//   DateTimeRange _rangeForSegment(int segment) {
//     final now = DateTime.now();
//     if (segment == 0) {
//       final start = DateTime(now.year, now.month, now.day);
//       return DateTimeRange(start: start, end: DateTime(now.year, now.month, now.day, 23, 59, 59));
//     } else if (segment == 1) {
//       final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
//       return DateTimeRange(start: start, end: DateTime(start.year, start.month, start.day, 23, 59, 59).add(const Duration(days: 6)));
//     } else {
//       return DateTimeRange(
//           start: DateTime(now.year, now.month, 1),
//           end: DateTime(now.year, now.month + 1, 0, 23, 59, 59));
//     }
//   }

//   bool _isInRange(String dateStr, DateTimeRange r) {
//     try {
//       final dt = DateTime.tryParse(dateStr);
//       if (dt == null) return false;
//       return !dt.isBefore(r.start) && !dt.isAfter(r.end);
//     } catch (_) { return false; }
//   }

//   List<SModel.Source> _safeSources(BuildContext context) {
//     try { return Provider.of<SourceViewmodel>(context).sources; }
//     catch (_) { return _sourcesCache ?? const []; }
//   }

//   List<Map<String, dynamic>> _computeTopSources({
//     required List<SModel.Source> sources,
//     required List<MR.MarketingReport> reports,
//     required int segment,
//   }) {
//     final range = _rangeForSegment(segment);
//     final Map<String, int> counts = {};
//     final Map<int, String> idToName = {
//       for (final s in sources) if (s.name.trim().isNotEmpty) s.id: s.name.trim(),
//     };
//     for (final report in reports) {
//       if (!_isInRange(report.date, range)) continue;
//       final name = idToName[report.sourceId] ?? 'Source #${report.sourceId}';
//       counts[name] = (counts[name] ?? 0) + (report.leads ?? 0);
//     }
//     return (counts.entries.map((e) => {'label': e.key, 'value': e.value}).toList()
//       ..sort((a, b) => (b['value'] as int).compareTo(a['value'] as int)));
//   }

//   Future<void> _exportPdf(BuildContext context) async {
//     final reports = _reportsCache ?? [];
//     if (reports.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No reports available to export')));
//       return;
//     }
//     final bytes = await buildMarketingPdfSimple(reports: reports);
//     if (!mounted) return;
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (_) => PdfPreviewScreen(title: 'Marketing Report', pdfBytesBuilder: (_) async => bytes),
//     ));
//   }

//   PreferredSizeWidget _buildAppBar(String title) {
//     return AppBar(
//       backgroundColor: _isDark ? const Color(0xFF1A1730) : _kIndigo,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
//         onPressed: () => Navigator.of(context).pop(),
//       ),
//       titleSpacing: 0,
//       title: Padding(
//         padding: const EdgeInsets.only(right: 16),
//         child: Row(children: [
//           Expanded(
//             child: Text(title, overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
//           ),
//           if (_selectedIndexBottomNav == 2)
//             _ExportButton(onPressed: () => _exportPdf(context)),
//         ]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ── Live counts straight from their ViewModels ────────────────────────
//     final leadVm       = Provider.of<LeadViewmodel>(context);
//     final sourceVm     = Provider.of<SourceViewmodel>(context);
//     final locationVm   = Provider.of<LocationViewmodel>(context);

//     final int  leadCount        = leadVm.leadList.length;
//     final bool isLeadLoading    = leadVm.getLeadLoader;
//     final int  sourceCount      = sourceVm.sources.length;
//     final bool isSourceLoading  = sourceVm.isLoading;
//     final int  locationCount    = locationVm.locations.length;
//     final bool isLocationLoading = locationVm.isLoading;

//     final sources    = _safeSources(context);
//     final topSources = _computeTopSources(
//         sources: sources, reports: _reportsCache ?? [], segment: _selectedSegment);

//     // ── Stat cards with onTap destinations ───────────────────────────────
//     final statsLocal = [
//       {
//         'icon'  : Icons.trending_up_outlined,
//         'value' : isLeadLoading ? '…' : '$leadCount',
//         'label' : 'Leads Generated',
//         'accent': const Color(0xFF6366F1),
//         // Same list LeadScreen shows
//         'onTap' : () => Navigator.of(context).push(MaterialPageRoute(
//               builder: (_) => const LeadsNewScreen(showAllLeads: true))),
//       },
//       {
//         'icon'  : Icons.location_on_outlined,
//         'value' : isLocationLoading ? '…' : '$locationCount',
//         'label' : 'Locations',
//         'accent': const Color(0xFF06B6D4),
//         'onTap' : () => Navigator.of(context).push(MaterialPageRoute(
//               builder: (_) => const LocationTab())),
//       },
//       {
//         'icon'  : Icons.phone_outlined,
//         'value' : _isCallsLoading ? '…' : '${_callsCount ?? 0}',
//         'label' : 'Calls Made',
//         'accent': const Color(0xFF10B981),
//         // Switch to the Reports tab inside DashboardPage
//         'onTap' : () => setState(() => _selectedIndexBottomNav = 2),
//       },
//       {
//         'icon'  : Icons.share_outlined,
//         'value' : isSourceLoading ? '…' : '$sourceCount',
//         'label' : 'Total Sources',
//         'accent': const Color(0xFFF59E0B),
//         'onTap' : () => Navigator.of(context).push(MaterialPageRoute(
//               builder: (_) => const SourceTab())),
//       },
//     ];

//     final String appBarTitle = _selectedIndexBottomNav == 0
//         ? 'Marketing Dashboard'
//         : _selectedIndexBottomNav == 1
//             ? 'Marketing Data'
//             : 'Marketing Reports';

//     return Scaffold(
//       backgroundColor: _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
//       appBar: _buildAppBar(appBarTitle),
//       bottomNavigationBar: _StyledMarketingBottomNav(
//         currentIndex: _selectedIndexBottomNav,
//         isDark: _isDark,
//         onTap: (i) {
//           if (i == 0) {
//             Navigator.of(context).pop();
//           } else {
//             setState(() => _selectedIndexBottomNav = i - 1);
//           }
//         },
//       ),
//       body: _pageLoading
//           ? const _FullPageLoader()
//           : IndexedStack(
//               index: _selectedIndexBottomNav,
//               children: [
//                 // 0 — Dashboard
//                 SafeArea(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 14),
//                         child: _buildStatsGrid(statsLocal),
//                       ),
//                       const SizedBox(height: 20),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 14),
//                         child: _sectionLabel(
//                           _selectedSegment == 0 ? 'Top Sources — Today'
//                               : _selectedSegment == 1 ? 'Top Sources — This Week'
//                               : 'Top Sources — This Month',
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 14),
//                         child: _buildSegmentedControl(),
//                       ),
//                       const SizedBox(height: 12),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           child: (topSources.isEmpty || topSources.every((m) => (m['value'] as int) == 0))
//                               ? Center(
//                                   child: Column(mainAxisSize: MainAxisSize.min, children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(18),
//                                       decoration: BoxDecoration(
//                                           color: _isDark ? _kIndigo.withOpacity(0.15) : _kSoftLilac,
//                                           shape: BoxShape.circle),
//                                       child: Icon(Icons.bar_chart_rounded, size: 32,
//                                           color: _isDark ? _kIndigoLight : _kIndigoDark),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     Text('No leads generated',
//                                         style: TextStyle(
//                                             color: _isDark ? Colors.white70 : _metricInk,
//                                             fontSize: 15, fontWeight: FontWeight.w600)),
//                                   ]),
//                                 )
//                               : ListView.separated(
//                                   physics: const BouncingScrollPhysics(),
//                                   padding: const EdgeInsets.only(bottom: 24),
//                                   itemCount: topSources.length,
//                                   separatorBuilder: (_, __) => const SizedBox(height: 10),
//                                   itemBuilder: (context, i) {
//                                     final m = topSources[i];
//                                     return _SourceGradientCard(
//                                         title: m['label'] as String,
//                                         value: m['value'] as int,
//                                         rank: i + 1,
//                                         isDark: _isDark);
//                                   },
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // 1 — Data
//                 const DataScreen(),

//                 // 2 — Reports
//                 const ReportsScreen(),
//               ],
//             ),
//     );
//   }

//   Widget _sectionLabel(String text) => Row(children: [
//         Container(
//           width: 3, height: 14,
//           decoration: BoxDecoration(
//               color: _isDark ? _kIndigoLight : _kIndigo,
//               borderRadius: BorderRadius.circular(3)),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(text, overflow: TextOverflow.ellipsis,
//               style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5,
//                   color: _isDark ? Colors.white : _metricInk)),
//         ),
//       ]);

//   Widget _buildSegmentedControl() => Container(
//         decoration: BoxDecoration(
//           color: _isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(22),
//           border: Border.all(
//               color: _isDark ? Colors.white.withOpacity(0.1) : _kIndigo.withOpacity(0.15), width: 1),
//         ),
//         padding: const EdgeInsets.all(4),
//         child: Row(children: [_segBtn('Today', 0), _segBtn('This Week', 1), _segBtn('This Month', 2)]),
//       );

//   Widget _segBtn(String title, int index) {
//     final isSelected = _selectedSegment == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedSegment = index),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 9),
//           decoration: isSelected
//               ? BoxDecoration(
//                   color: _kIndigo, borderRadius: BorderRadius.circular(18),
//                   boxShadow: [BoxShadow(color: _kIndigo.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))])
//               : null,
//           child: Center(
//             child: Text(title, overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                     color: isSelected ? Colors.white : (_isDark ? Colors.white54 : _metricSub),
//                     fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                     fontSize: 12)),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid(List<Map<String, dynamic>> stats) => GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6),
//         itemCount: stats.length,
//         itemBuilder: (_, i) {
//           final s = stats[i];
//           return _StatCard(
//             icon: s['icon'] as IconData,
//             value: s['value'] as String,
//             label: s['label'] as String,
//             accent: s['accent'] as Color,
//             isDark: _isDark,
//             onTap: s['onTap'] as VoidCallback?,
//           );
//         },
//       );
// }

// // ── Export button ─────────────────────────────────────────────────────────────
// class _ExportButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   const _ExportButton({required this.onPressed});
//   @override
//   Widget build(BuildContext context) => SizedBox(
//         height: 30,
//         child: ElevatedButton.icon(
//           onPressed: onPressed,
//           icon: const Icon(Icons.upload_outlined, size: 15, color: Color(0xFF4338CA)),
//           label: const Text('Export',
//               style: TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.w700, fontSize: 12)),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.white, elevation: 0,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           ),
//         ),
//       );
// }

// // ── Styled bottom nav wrapper ─────────────────────────────────────────────────
// class _StyledMarketingBottomNav extends StatelessWidget {
//   final int currentIndex;
//   final bool isDark;
//   final ValueChanged<int> onTap;
//   const _StyledMarketingBottomNav(
//       {required this.currentIndex, required this.isDark, required this.onTap});
//   @override
//   Widget build(BuildContext context) =>
//       MarketingBottomNav(currentIndex: currentIndex + 1, onTap: onTap);
// }

// // ── Tappable stat card ────────────────────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   final String label;
//   final Color accent;
//   final bool isDark;
//   final VoidCallback? onTap;

//   const _StatCard({
//     required this.icon, required this.value, required this.label,
//     required this.accent, required this.isDark, this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//               color: isDark ? Colors.white.withOpacity(0.1) : accent.withOpacity(0.18), width: 1),
//           boxShadow: isDark
//               ? null
//               : [BoxShadow(color: accent.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
//         ),
//         child: LayoutBuilder(
//           builder: (context, constraints) => FittedBox(
//             fit: BoxFit.scaleDown,
//             alignment: Alignment.centerLeft,
//             child: SizedBox(
//               width: constraints.maxWidth,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: 36, height: 36,
//                         decoration: BoxDecoration(
//                             color: isDark ? accent.withOpacity(0.18) : accent.withOpacity(0.10),
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Center(child: Icon(icon, size: 18, color: accent)),
//                       ),
//                       if (onTap != null)
//                         Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accent.withOpacity(0.5)),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Text(value,
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
//                           color: isDark ? Colors.white : _metricInk)),
//                   const SizedBox(height: 2),
//                   Text(label, overflow: TextOverflow.ellipsis,
//                       style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
//                           color: isDark ? Colors.white54 : _metricSub)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Source gradient card ──────────────────────────────────────────────────────
// class _SourceGradientCard extends StatelessWidget {
//   final String title;
//   final int value;
//   final int rank;
//   final bool isDark;
//   const _SourceGradientCard(
//       {required this.title, required this.value, required this.rank, required this.isDark});

//   @override
//   Widget build(BuildContext context) => Container(
//         height: 62,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft, end: Alignment.centerRight,
//             colors: isDark
//                 ? [const Color(0xFF4338CA), const Color(0xFF2D2A5E)]
//                 : [_kGradientStart, _kGradientEnd],
//           ),
//           border: Border.all(
//               color: isDark ? _kIndigoLight.withOpacity(0.2) : _kIndigo.withOpacity(0.15), width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           child: Row(children: [
//             Container(
//               width: 26, height: 26,
//               decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(isDark ? 0.12 : 0.25), shape: BoxShape.circle),
//               child: Center(
//                 child: Text('$rank',
//                     style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
//             ),
//             Row(mainAxisSize: MainAxisSize.min, children: [
//               Text('$value',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
//                       color: isDark ? Colors.white : _metricInk)),
//               const SizedBox(width: 6),
//               Icon(Icons.trending_up, size: 16, color: isDark ? Colors.white70 : _metricInk),
//             ]),
//           ]),
//         ),
//       );
// }

// // ── Full page loader ──────────────────────────────────────────────────────────
// class _FullPageLoader extends StatelessWidget {
//   const _FullPageLoader();
//   @override
//   Widget build(BuildContext context) => const SafeArea(
//         child: Center(
//           child: SizedBox(
//             width: 44, height: 44,
//             child: CircularProgressIndicator(strokeWidth: 3, color: _kIndigo),
//           ),
//         ),
//       );
// }