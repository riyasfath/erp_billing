// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/marketing/source/editSourceScreen.dart';

// // NEW: pull leads from provider or fallback to services
// import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
// import 'package:pokakbilling/models/services/lead_services.dart';
// import 'package:pokakbilling/models/data-models/lead_model.dart';

// class SourceTab extends StatefulWidget {
//   const SourceTab({super.key});

//   @override
//   State<SourceTab> createState() => _SourceTabState();
// }

// class _SourceTabState extends State<SourceTab> {
//   final TextEditingController _search = TextEditingController();

//   // live map of sourceName(lower) -> count
//   final Map<String, int> _leadCountsBySourceName = {};
//   VoidCallback? _leadVmListener;

//   @override
//   void initState() {
//     super.initState();
//     // defer provider wiring
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _attachLeadProviderOrFetch();
//     });
//   }

//   @override
//   void dispose() {
//     _search.dispose();
//     try {
//       final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
//       _leadVmListener != null ? leadVm.removeListener(_leadVmListener!) : null;
//     } catch (_) {}
//     super.dispose();
//   }

//   Future<void> _attachLeadProviderOrFetch() async {
//     // Try provider first
//     try {
//       final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
//       _recomputeFromLeads(leadVm.leadList);
//       setState(() {});

//       _leadVmListener = () {
//         _recomputeFromLeads(leadVm.leadList);
//         if (mounted) setState(() {});
//       };
//       leadVm.addListener(_leadVmListener!);
//       return;
//     } catch (_) {
//       // Provider not found — fallback to service call
//     }

//     try {
//       final leads = await LeadServices.getLeads();
//       _recomputeFromLeads(leads);
//       if (mounted) setState(() {});
//     } catch (e) {
//       // ignore; counts stay zero
//     }
//   }

//   void _recomputeFromLeads(List<LeadModel> leads) {
//     _leadCountsBySourceName.clear();
//     for (final l in leads) {
//       // final key = (l.leadSource).toString().trim().toLowerCase();
//       final key = (l.source ?? '').trim().toLowerCase();

//       if (key.isEmpty) continue;
//       _leadCountsBySourceName.update(key, (v) => v + 1, ifAbsent: () => 1);
//     }
//   }

//   int _countForSourceName(String sourceName) {
//     final key = sourceName.trim().toLowerCase();
//     return _leadCountsBySourceName[key] ?? 0;
//   }

//   Future<void> _confirmAndDeleteSource(
//       BuildContext context, SourceViewmodel vm, int id) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => ChangeNotifierProvider<SourceViewmodel>.value(
//         value: vm,
//         child: Consumer<SourceViewmodel>(builder: (dialogCtx, vm2, _) {
//           return AlertDialog(
//             title: const Text('Delete source'),
//             content: const Text('Are you sure you want to delete this source?'),
//             actions: [
//               TextButton(
//                   onPressed: vm2.deleteSourceLoading
//                       ? null
//                       : () => Navigator.of(dialogCtx).pop(false),
//                   child: const Text('Cancel')),
//               TextButton(
//                   onPressed: vm2.deleteSourceLoading
//                       ? null
//                       : () => Navigator.of(dialogCtx).pop(true),
//                   child: vm2.deleteSourceLoading
//                       ? const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Delete',
//                           style: TextStyle(color: Colors.red))),
//             ],
//           );
//         }),
//       ),
//     );

//     if (confirmed == true) {
//       await vm.deleteSource(id, context);
//       await vm.fetchSources();
//       if (context.mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Source deleted')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<SourceViewmodel>(
//       builder: (context, vm, _) {
//         if (vm.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (vm.errorMessage != null) {
//           return Center(child: Text('Error: ${vm.errorMessage}'));
//         }

//         final q = _search.text.trim().toLowerCase();
//         final items =
//             vm.sources.where((e) => e.name.toLowerCase().contains(q)).toList();

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Search
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
//                     hintText: 'Search Source.',
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

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 18.0),
//               child: Row(
//                 children: [
//                   Text('Top',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14)),
//                   SizedBox(width: 3),
//                   Icon(Icons.arrow_upward, size: 16, color: Color(0xFF13C313)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 6),

//             Expanded(
//               child: ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
//                 itemCount: items.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final source = items[index];
//                   final leadCount = _countForSourceName(source.name);

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
//                           // Two aligned rows: icon gutter = 28 for both
//                           Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   const SizedBox(
//                                     width: 28,
//                                     child: Icon(Icons.share_outlined,
//                                         color: AppColors.violetblue, size: 22),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     source.name,
//                                     style: const TextStyle(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: Color(0xFF2C2A74),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 28,
//                                     child: Center(
//                                       child: Image.asset(
//                                         'assets/images/lead_small.png',
//                                         width: 15,
//                                         height: 16,
//                                         fit: BoxFit.contain,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     '$leadCount Leads',
//                                     style: const TextStyle(
//                                       fontSize: 12, // 12 px
//                                       fontWeight: FontWeight.w500, // 500
//                                       color: Colors.black, // black
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           PopupMenuButton<String>(
//                             icon: const Icon(Icons.more_vert,
//                                 color: Colors.white, size: 22), // white dots
//                             onSelected: (value) async {
//                               if (value == 'edit') {
//                                 await Navigator.push<bool?>(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) =>
//                                         ChangeNotifierProvider.value(
//                                       value: vm,
//                                       child: EditSourcePage(source: source),
//                                     ),
//                                   ),
//                                 );
//                                 await vm.fetchSources();
//                               } else if (value == 'delete') {
//                                 await _confirmAndDeleteSource(
//                                     context, vm, source.id);
//                               }
//                             },
//                             itemBuilder: (_) => const [
//                               PopupMenuItem(value: 'edit', child: Text('Edit')),
//                               PopupMenuItem(
//                                   value: 'delete', child: Text('Delete')),
//                             ],
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
