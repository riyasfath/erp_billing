// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/bottom_nav/addBottomshet.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/tabs/categoryList.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/tabs/location_tab.dart';
// import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/tabs/source_tab.dart';

// class DataScreen extends StatefulWidget {
//   const DataScreen({super.key});

//   @override
//   State<DataScreen> createState() => _DataScreenState();
// }

// class _DataScreenState extends State<DataScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _showAddLocationSheet(BuildContext context, LocationViewmodel locVm) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//         child: ChangeNotifierProvider.value(
//           value: locVm,
//           child: const AddLocationBottomSheet(),
//         ),
//       ),
//     );
//   }

//   void _showAddSourceSheet(BuildContext context, SourceViewmodel sourceVm) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//         child: ChangeNotifierProvider.value(
//           value: sourceVm,
//           child: const AddSourceBottomSheet(),
//         ),
//       ),
//     );
//   }

//   void _showAddCategorySheet(BuildContext context, SourceViewmodel sourceVm,
//       CategoryMarketingViewmodel categoryVm) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Padding(
//         padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//         child: MultiProvider(
//           providers: [
//             ChangeNotifierProvider.value(value: sourceVm),
//             ChangeNotifierProvider.value(value: categoryVm),
//           ],
//           child: const AddCategoryBottomSheet(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//             create: (_) => LocationViewmodel()..fetchLocations()),
//         ChangeNotifierProvider(
//             create: (_) => SourceViewmodel()..fetchSources()),
//         ChangeNotifierProvider(
//             create: (_) => CategoryMarketingViewmodel()..fetchCategories()),
//       ],
//       child: Builder(builder: (innerContext) {
//         final locationVm =
//             Provider.of<LocationViewmodel>(innerContext, listen: false);
//         final sourceVm =
//             Provider.of<SourceViewmodel>(innerContext, listen: false);
//         final categoryVm = Provider.of<CategoryMarketingViewmodel>(innerContext,
//             listen: false);

//         return Scaffold(
//           backgroundColor: AppColors.violetblue,
//           body: SafeArea(
//             child: Column(
//               children: [
//                 // ✅ TabBar with extra padding left & right
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.white.withOpacity(0.25),
//                           width: 0.5, // thin base line under tabs
//                         ),
//                       ),
//                     ),
//                     child: TabBar(
//                       controller: _tabController,
//                       labelColor: Colors.white,
//                       unselectedLabelColor: Colors.white.withOpacity(0.75),

//                       // ✅ Updated font sizes and weights
//                       labelStyle: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700, // selected
//                       ),
//                       unselectedLabelStyle: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400, // unselected
//                       ),

//                       dividerColor: Colors.transparent, // hide default divider

//                       // ✅ Underline with padding and nice spacing
//                       indicatorSize: TabBarIndicatorSize.tab,
//                       indicator: const UnderlineTabIndicator(
//                         borderSide: BorderSide(width: 1.1, color: Colors.white),
//                         insets: EdgeInsets.symmetric(
//                             horizontal:
//                                 1), // keeps line shorter than full width
//                       ),

//                       tabs: const [
//                         Tab(text: 'Location'),
//                         Tab(text: 'Source'),
//                         Tab(text: 'Category'),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 // ✅ Tab Views
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: const [
//                       LocationTab(),
//                       SourceTab(),
//                       CategoryTab(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ✅ Floating Action Button (black +)
//           floatingActionButton: SizedBox(
//             height: 73,
//             width: 75,
//             child: FloatingActionButton(
//               shape: const CircleBorder(),
//               backgroundColor: const Color(0xFFD2D4FF),
//               onPressed: () {
//                 switch (_tabController.index) {
//                   case 0:
//                     _showAddLocationSheet(innerContext, locationVm);
//                     break;
//                   case 1:
//                     _showAddSourceSheet(innerContext, sourceVm);
//                     break;
//                   case 2:
//                     _showAddCategorySheet(innerContext, sourceVm, categoryVm);
//                     break;
//                 }
//               },
//               child: const Icon(Icons.add, color: Colors.black, size: 32),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/bottom_nav/addBottomshet.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/tabs/categoryList.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/tabs/location_tab.dart';
import 'package:pokakbilling/views/Screens/marketing/dashboard/utils/tabs/source_tab.dart';

// ── Theme constants matching DashboardPage ────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const Color _metricInk = Color(0xFF1E1B4B);
const Color _metricSub = Color(0xFF6B7280);

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddLocationSheet(BuildContext context, LocationViewmodel locVm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ChangeNotifierProvider.value(
          value: locVm,
          child: const AddLocationBottomSheet(),
        ),
      ),
    );
  }

  void _showAddSourceSheet(BuildContext context, SourceViewmodel sourceVm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ChangeNotifierProvider.value(
          value: sourceVm,
          child: const AddSourceBottomSheet(),
        ),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, SourceViewmodel sourceVm,
      CategoryMarketingViewmodel categoryVm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: sourceVm),
            ChangeNotifierProvider.value(value: categoryVm),
          ],
          child: const AddCategoryBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => LocationViewmodel()..fetchLocations()),
        ChangeNotifierProvider(
            create: (_) => SourceViewmodel()..fetchSources()),
        ChangeNotifierProvider(
            create: (_) => CategoryMarketingViewmodel()..fetchCategories()),
      ],
      child: Builder(builder: (innerContext) {
        final locationVm =
            Provider.of<LocationViewmodel>(innerContext, listen: false);
        final sourceVm =
            Provider.of<SourceViewmodel>(innerContext, listen: false);
        final categoryVm = Provider.of<CategoryMarketingViewmodel>(innerContext,
            listen: false);

        return Scaffold(
          // ── Matches DashboardPage background ──────────────────────────────
          backgroundColor:
              _isDark ? const Color(0xFF0F0D1E) : const Color(0xFFF5F4FF),
          body: SafeArea(
            child: Column(
              children: [
                // ── Tab bar styled to match light/dark theme ───────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : _kIndigo.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: _isDark
                          ? null
                          : [
                              BoxShadow(
                                color: _kIndigo.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      // ── Pill indicator matching segmented control style ──
                      indicator: BoxDecoration(
                        color: _kIndigo,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _kIndigo.withValues(alpha: 0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          _isDark ? Colors.white54 : _metricSub,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(text: 'Location'),
                        Tab(text: 'Source'),
                        Tab(text: 'Category'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tab Views ─────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      LocationTab(),
                      SourceTab(),
                      CategoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── FAB styled to match dashboard accent ──────────────────────────
          floatingActionButton: SizedBox(
            height: 56,
            width: 56,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: _kIndigo,
              elevation: 4,
              onPressed: () {
                switch (_tabController.index) {
                  case 0:
                    _showAddLocationSheet(innerContext, locationVm);
                    break;
                  case 1:
                    _showAddSourceSheet(innerContext, sourceVm);
                    break;
                  case 2:
                    _showAddCategorySheet(innerContext, sourceVm, categoryVm);
                    break;
                }
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        );
      }),
    );
  }
}
