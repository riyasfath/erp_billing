// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/marketing/categoryList/editCategoryListScreen.dart';
// import 'package:pokakbilling/models/data-models/marketing_model/source.dart';

// // Lead dependencies for counting
// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:pokakbilling/models/services/lead_services.dart';
// import 'package:pokakbilling/models/data-models/lead_model.dart';

// class CategoryTab extends StatefulWidget {
//   const CategoryTab({super.key});

//   @override
//   State<CategoryTab> createState() => _CategoryTabState();
// }

// class _CategoryTabState extends State<CategoryTab> {
//   final TextEditingController _search = TextEditingController();

//   bool _sortDescending = false;

//   // Lead count map: categoryId -> count
//   final Map<int, int> _leadCountsByCategoryId = {};
//   VoidCallback? _leadVmListener;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _attachLeadProviderOrFetch();
//     });
//   }

//   @override
//   void dispose() {
//     _search.dispose();
//     try {
//       final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
//       if (_leadVmListener != null) leadVm.removeListener(_leadVmListener!);
//     } catch (_) {}
//     super.dispose();
//   }

//   Future<void> _attachLeadProviderOrFetch() async {
//     try {
//       final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
//       _recomputeFromLeads(leadVm.leadList);
//       if (mounted) setState(() {});
//       _leadVmListener = () {
//         _recomputeFromLeads(leadVm.leadList);
//         if (mounted) setState(() {});
//       };
//       leadVm.addListener(_leadVmListener!);
//       return;
//     } catch (_) {}

//     try {
//       final leads = await LeadServices.getLeads();
//       _recomputeFromLeads(leads);
//       if (mounted) setState(() {});
//     } catch (e) {
//       debugPrint('Failed to fetch leads for category counts: $e');
//     }
//   }

//   /// NOTE: LeadModel has no category field yet.
//   /// Once your backend adds it, add `final int? category;` to LeadModel
//   /// and uncomment the loop below with lead.category.
//   void _recomputeFromLeads(List<LeadModel> leads) {
//     _leadCountsByCategoryId.clear();
//     // TODO: uncomment once LeadModel has category field:
//     // for (final lead in leads) {
//     //   final categoryId = lead.category;
//     //   if (categoryId == null || categoryId == 0) continue;
//     //   _leadCountsByCategoryId.update(categoryId, (v) => v + 1, ifAbsent: () => 1);
//     // }
//   }

//   int _countForCategoryId(int id) => _leadCountsByCategoryId[id] ?? 0;

//   void _toggleSortOrder() => setState(() => _sortDescending = !_sortDescending);

//   /// Warning snackbar — category has linked leads, can't delete
//   void _showHasLeadsWarning(BuildContext context, String name, int leadCount) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: const Color(0xFFFFEDED),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 4),
//         content: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.only(top: 2),
//               child: Icon(Icons.warning_amber_rounded,
//                   color: Color(0xFFD32F2F), size: 20),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: RichText(
//                 text: TextSpan(
//                   style: const TextStyle(
//                     color: Color(0xFFD32F2F),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     height: 1.4,
//                   ),
//                   children: [
//                     const TextSpan(text: 'Cannot delete '),
//                     TextSpan(
//                       text: '"$name"',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     TextSpan(
//                       text:
//                           '. It has $leadCount linked lead${leadCount > 1 ? 's' : ''}.\nPlease delete the leads first.',
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

//   /// Custom menu with full control over each item's tap behaviour
//   void _showCategoryMenu({
//     required BuildContext context,
//     required CategoryMarketingViewmodel categoryVm,
//     required SourceViewmodel sourceVm,
//     required dynamic category,
//     required int leadCount,
//     required bool hasLeads,
//     required Offset tapPosition,
//   }) {
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;

//     showMenu<String>(
//       context: context,
//       position: RelativeRect.fromRect(
//         tapPosition & const Size(40, 40),
//         Offset.zero & overlay.size,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       items: [
//         // ── Edit ──
//         PopupMenuItem<String>(
//           value: 'edit',
//           child: Row(
//             children: const [
//               Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2C2A74)),
//               SizedBox(width: 10),
//               Text('Edit', style: TextStyle(color: Color(0xFF2C2A74))),
//             ],
//           ),
//         ),

//         // ── Delete — InkWell handles tap, shows warning if hasLeads ──
//         PopupMenuItem<String>(
//           enabled: true,
//           padding: EdgeInsets.zero,
//           child: InkWell(
//             onTap: () {
//               Navigator.of(context).pop(); // close menu first
//               if (hasLeads) {
//                 _showHasLeadsWarning(context, category.name, leadCount);
//               } else {
//                 _confirmAndDeleteCategory(context, categoryVm, category.id);
//               }
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   Icon(
//                     hasLeads ? Icons.lock_outline : Icons.delete_outline,
//                     size: 18,
//                     color: hasLeads
//                         ? Colors.grey.shade400
//                         : const Color(0xFFD32F2F),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     'Delete',
//                     style: TextStyle(
//                       color: hasLeads
//                           ? Colors.grey.shade400
//                           : const Color(0xFFD32F2F),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   if (hasLeads) ...[
//                     const SizedBox(width: 6),
//                     Text(
//                       '($leadCount leads)',
//                       style:
//                           TextStyle(fontSize: 11, color: Colors.grey.shade400),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     ).then((value) async {
//       if (value == 'edit') {
//         await Navigator.push<bool?>(
//           context,
//           MaterialPageRoute(
//             builder: (_) => MultiProvider(
//               providers: [
//                 ChangeNotifierProvider.value(value: categoryVm),
//                 ChangeNotifierProvider.value(value: sourceVm),
//               ],
//               child: EditCategoryMarketingPage(category: category),
//             ),
//           ),
//         );
//         await categoryVm.fetchCategories();
//       }
//     });
//   }

//   Future<void> _confirmAndDeleteCategory(
//     BuildContext context,
//     CategoryMarketingViewmodel categoryVm,
//     int id,
//   ) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) =>
//           ChangeNotifierProvider<CategoryMarketingViewmodel>.value(
//         value: categoryVm,
//         child: Consumer<CategoryMarketingViewmodel>(
//           builder: (dialogCtx, vm, _) => AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             title: const Text('Delete Category'),
//             content:
//                 const Text('Are you sure you want to delete this category?'),
//             actions: [
//               TextButton(
//                 onPressed: vm.deleteCategoryLoading
//                     ? null
//                     : () => Navigator.of(dialogCtx).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: vm.deleteCategoryLoading
//                     ? null
//                     : () => Navigator.of(dialogCtx).pop(true),
//                 child: vm.deleteCategoryLoading
//                     ? const SizedBox(
//                         width: 16,
//                         height: 16,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text('Delete',
//                         style: TextStyle(color: AppColors.red)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     if (confirmed == true) {
//       await categoryVm.deleteCategory(id, context);
//       await categoryVm.fetchCategories();
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Category deleted successfully')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<CategoryMarketingViewmodel, SourceViewmodel>(
//       builder: (context, categoryVm, sourceVm, _) {
//         if (categoryVm.isLoading || sourceVm.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (categoryVm.errorMessage != null) {
//           return Center(child: Text('Error: ${categoryVm.errorMessage}'));
//         }
//         if (categoryVm.categories.isEmpty) {
//           return const Center(child: Text('No categories found'));
//         }

//         final sources = sourceVm.sources;
//         final q = _search.text.trim().toLowerCase();
//         final items = categoryVm.categories
//             .where((c) => c.name.toLowerCase().contains(q))
//             .toList();

//         // Sort alphabetically
//         items.sort((a, b) => _sortDescending
//             ? b.name.toLowerCase().compareTo(a.name.toLowerCase())
//             : a.name.toLowerCase().compareTo(b.name.toLowerCase()));

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search bar
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
//               child: SizedBox(
//                 height: 42,
//                 child: TextField(
//                   controller: _search,
//                   onChanged: (_) => setState(() {}),
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.black,
//                   ),
//                   decoration: InputDecoration(
//                     hintText: 'Search Category.',
//                     hintStyle: const TextStyle(
//                       color: Color(0xFFA9A0A0),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     suffixIcon:
//                         const Icon(Icons.search, color: Color(0xFF37343C)),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 10),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(17),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Sort header
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18.0),
//               child: InkWell(
//                 onTap: _toggleSortOrder,
//                 child: Row(
//                   children: [
//                     const Text('Top',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14)),
//                     const SizedBox(width: 3),
//                     Icon(
//                       _sortDescending
//                           ? Icons.arrow_downward
//                           : Icons.arrow_upward,
//                       size: 16,
//                       color: const Color(0xFF13C313),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),

//             Expanded(
//               child: ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
//                 itemCount: items.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final category = items[index];
//                   final leadCount = _countForCategoryId(category.id);
//                   final hasLeads = leadCount > 0;

//                   final sourceObj = sources.firstWhere(
//                     (s) => s.id == category.source,
//                     orElse: () => Source(id: 0, name: '-', categories: []),
//                   );

//                   return Container(
//                     height: 72,
//                     decoration: BoxDecoration(
//                       gradient: AppColors.listCardGradient,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const SizedBox(
//                                       width: 28,
//                                       child: Icon(Icons.local_offer,
//                                           color: AppColors.violetblue,
//                                           size: 22),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Flexible(
//                                       child: Text(
//                                         category.name,
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: const TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w600,
//                                           color: Color(0xFF2C2A74),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     const SizedBox(width: 36),
//                                     Flexible(
//                                       child: RichText(
//                                         overflow: TextOverflow.ellipsis,
//                                         text: TextSpan(
//                                           text: 'Source: ',
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                             color: Colors.black,
//                                           ),
//                                           children: [
//                                             TextSpan(
//                                               text: sourceObj.name,
//                                               style: const TextStyle(
//                                                 fontSize: 12,
//                                                 color: AppColors.violetblue,
//                                                 fontWeight: FontWeight.w400,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),

//                           // ── GestureDetector captures exact tap position ──
//                           GestureDetector(
//                             onTapDown: (details) {
//                               _showCategoryMenu(
//                                 context: context,
//                                 categoryVm: categoryVm,
//                                 sourceVm: sourceVm,
//                                 category: category,
//                                 leadCount: leadCount,
//                                 hasLeads: hasLeads,
//                                 tapPosition: details.globalPosition,
//                               );
//                             },
//                             child: const Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: Icon(Icons.more_vert,
//                                   color: Colors.white, size: 22),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/categoryList/editCategoryListScreen.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';

import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/services/lead_services.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kMetricInk = Color(0xFF1E1B4B);

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});
  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  final TextEditingController _search = TextEditingController();
  bool _sortDescending = false;

  final Map<int, int> _leadCountsByCategoryId = {};
  VoidCallback? _leadVmListener;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachLeadProviderOrFetch();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    try {
      final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
      if (_leadVmListener != null) leadVm.removeListener(_leadVmListener!);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _attachLeadProviderOrFetch() async {
    try {
      final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
      _recomputeFromLeads(leadVm.leadList);
      if (mounted) setState(() {});
      _leadVmListener = () {
        _recomputeFromLeads(leadVm.leadList);
        if (mounted) setState(() {});
      };
      leadVm.addListener(_leadVmListener!);
      return;
    } catch (_) {}
    try {
      final leads = await LeadServices.getLeads();
      _recomputeFromLeads(leads);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed to fetch leads for category counts: $e');
    }
  }

  void _recomputeFromLeads(List<LeadModel> leads) {
    _leadCountsByCategoryId.clear();
    // TODO: uncomment once LeadModel has category field:
    // for (final lead in leads) {
    //   final categoryId = lead.category;
    //   if (categoryId == null || categoryId == 0) continue;
    //   _leadCountsByCategoryId.update(categoryId, (v) => v + 1, ifAbsent: () => 1);
    // }
  }

  int _countForCategoryId(int id) => _leadCountsByCategoryId[id] ?? 0;
  void _toggleSortOrder() => setState(() => _sortDescending = !_sortDescending);

  void _showHasLeadsWarning(BuildContext context, String name, int leadCount) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFFEDED),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD32F2F), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4),
                  children: [
                    const TextSpan(text: 'Cannot delete '),
                    TextSpan(
                        text: '"$name"',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '. It has $leadCount linked lead${leadCount > 1 ? 's' : ''}.\nPlease delete the leads first.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryMenu({
    required BuildContext context,
    required CategoryMarketingViewmodel categoryVm,
    required SourceViewmodel sourceVm,
    required dynamic category,
    required int leadCount,
    required bool hasLeads,
    required Offset tapPosition,
  }) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _isDark ? const Color(0xFF2A2750) : Colors.white,
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined,
                size: 18, color: _isDark ? _kIndigoLight : _kIndigoDark),
            const SizedBox(width: 10),
            Text('Edit',
                style: TextStyle(
                    color: _isDark ? _kIndigoLight : _kIndigoDark,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        PopupMenuItem<String>(
          enabled: true,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
              if (hasLeads) {
                _showHasLeadsWarning(context, category.name, leadCount);
              } else {
                _confirmAndDeleteCategory(context, categoryVm, category.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    hasLeads ? Icons.lock_outline : Icons.delete_outline,
                    size: 18,
                    color: hasLeads
                        ? Colors.grey.shade400
                        : const Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 10),
                  Text('Delete',
                      style: TextStyle(
                        color: hasLeads
                            ? Colors.grey.shade400
                            : const Color(0xFFD32F2F),
                        fontWeight: FontWeight.w500,
                      )),
                  if (hasLeads) ...[
                    const SizedBox(width: 6),
                    Text('($leadCount leads)',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'edit') {
        await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: categoryVm),
                ChangeNotifierProvider.value(value: sourceVm),
              ],
              child: EditCategoryMarketingPage(category: category),
            ),
          ),
        );
        await categoryVm.fetchCategories();
      }
    });
  }

  Future<void> _confirmAndDeleteCategory(
    BuildContext context,
    CategoryMarketingViewmodel categoryVm,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          ChangeNotifierProvider<CategoryMarketingViewmodel>.value(
        value: categoryVm,
        child: Consumer<CategoryMarketingViewmodel>(
          builder: (dialogCtx, vm, _) => AlertDialog(
            backgroundColor: _isDark ? const Color(0xFF2A2750) : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text('Delete Category',
                style: TextStyle(
                    color: _isDark ? Colors.white : _kMetricInk,
                    fontWeight: FontWeight.w700)),
            content: Text('Are you sure you want to delete this category?',
                style: TextStyle(
                    color: _isDark ? Colors.white70 : Colors.black87)),
            actions: [
              TextButton(
                onPressed: vm.deleteCategoryLoading
                    ? null
                    : () => Navigator.of(dialogCtx).pop(false),
                child: Text('Cancel',
                    style: TextStyle(
                        color: _isDark ? Colors.white54 : Colors.grey)),
              ),
              TextButton(
                onPressed: vm.deleteCategoryLoading
                    ? null
                    : () => Navigator.of(dialogCtx).pop(true),
                child: vm.deleteCategoryLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Delete',
                        style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await categoryVm.deleteCategory(id, context);
      await categoryVm.fetchCategories();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Category deleted successfully'),
            backgroundColor: _kIndigo,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryMarketingViewmodel, SourceViewmodel>(
      builder: (context, categoryVm, sourceVm, _) {
        if (categoryVm.isLoading || sourceVm.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: _kIndigo));
        }
        if (categoryVm.errorMessage != null) {
          return Center(child: Text('Error: ${categoryVm.errorMessage}'));
        }
        if (categoryVm.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDark
                        ? _kIndigo.withValues(alpha: 0.15)
                        : const Color(0xFFEEEDFE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_offer_outlined,
                      size: 28, color: _isDark ? _kIndigoLight : _kIndigoDark),
                ),
                const SizedBox(height: 10),
                Text('No categories found',
                    style: TextStyle(
                        color: _isDark ? Colors.white60 : _kMetricInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }

        final sources = sourceVm.sources;
        final q = _search.text.trim().toLowerCase();
        final items = categoryVm.categories
            .where((c) => c.name.toLowerCase().contains(q))
            .toList();

        items.sort((a, b) => _sortDescending
            ? b.name.toLowerCase().compareTo(a.name.toLowerCase())
            : a.name.toLowerCase().compareTo(b.name.toLowerCase()));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                      fontSize: 14,
                      color: _isDark ? Colors.white : _kMetricInk),
                  decoration: InputDecoration(
                    hintText: 'Search categories…',
                    hintStyle: TextStyle(
                        color: _isDark ? Colors.white38 : Colors.black38,
                        fontSize: 13.5),
                    filled: true,
                    fillColor:
                        _isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                    prefixIcon: Icon(Icons.search,
                        color: _isDark ? _kIndigoLight : _kIndigo, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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

            // ── Sort header ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: _toggleSortOrder,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 3,
                        height: 13,
                        decoration: BoxDecoration(
                            color: _isDark ? _kIndigoLight : _kIndigo,
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(width: 7),
                      Text('Sort',
                          style: TextStyle(
                              color: _isDark ? Colors.white : _kMetricInk,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      const SizedBox(width: 4),
                      Icon(
                        _sortDescending
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        size: 14,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ── List ────────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = items[index];
                  final leadCount = _countForCategoryId(category.id);
                  final hasLeads = leadCount > 0;

                  final sourceObj = sources.firstWhere(
                    (s) => s.id == category.source,
                    orElse: () => Source(id: 0, name: '-', categories: []),
                  );

                  return _CategoryCard(
                    category: category,
                    sourceName: sourceObj.name,
                    leadCount: leadCount,
                    hasLeads: hasLeads,
                    isDark: _isDark,
                    onMenuTap: (details) {
                      _showCategoryMenu(
                        context: context,
                        categoryVm: categoryVm,
                        sourceVm: sourceVm,
                        category: category,
                        leadCount: leadCount,
                        hasLeads: hasLeads,
                        tapPosition: details.globalPosition,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final dynamic category;
  final String sourceName;
  final int leadCount;
  final bool hasLeads;
  final bool isDark;
  final void Function(TapDownDetails) onMenuTap;

  const _CategoryCard({
    required this.category,
    required this.sourceName,
    required this.leadCount,
    required this.hasLeads,
    required this.isDark,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : _kIndigo.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _kIndigo.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? _kIndigo.withValues(alpha: 0.18)
                    : _kIndigo.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.local_offer_rounded,
                    color: isDark ? _kIndigoLight : _kIndigoDark, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : _kMetricInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.share_outlined,
                          size: 11, color: isDark ? _kIndigoLight : _kIndigo),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          sourceName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? _kIndigoLight : _kIndigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTapDown: onMenuTap,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : _kIndigo.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert_rounded,
                    color: isDark ? _kIndigoLight : _kIndigoDark, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
