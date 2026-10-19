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
