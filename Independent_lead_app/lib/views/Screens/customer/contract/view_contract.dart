// import 'package:flutter/material.dart';
// import 'package:pokakbilling/core/navigations.dart';
// import 'package:pokakbilling/core/themes/app_colors.dart';
// import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
// import 'package:pokakbilling/views/Screens/customer/contract/contract_details.dart';
// import 'package:pokakbilling/views/Screens/customer/customer_main.dart';
// import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
// import 'package:provider/provider.dart';

// class ViewContractDetailsScreen extends StatefulWidget {
//   final int contractId;
//   final int customerId;

//   const ViewContractDetailsScreen({
//     super.key,
//     required this.contractId,
//     required this.customerId,
//   });

//   @override
//   State<ViewContractDetailsScreen> createState() =>
//       _ViewContractDetailsScreenState();
// }

// class _ViewContractDetailsScreenState extends State<ViewContractDetailsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ContractViewmodel>().getContractById(widget.contractId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.of(context).size.width;
//     final topPad = MediaQuery.of(context).padding.top;

//     return Consumer<ContractViewmodel>(
//       builder: (context, vm, _) {
//         final contract = vm.currentContract;

//         return Scaffold(
//           backgroundColor: AppColors.white,
//           body: SizedBox(
//             width: double.infinity,
//             height: double.infinity,
//             child: vm.detailsLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : contract == null
//                     ? const Center(child: Text("No contract found"))
//                     : Column(
//                         children: [
//                           _buildHeader(context, sw, topPad, contract),
//                           Expanded(child: _buildContractUI(contract)),
//                         ],
//                       ),
//           ),
//         );
//       },
//     );
//   }

//   // ───────────────── HEADER (MATCHED DESIGN) ─────────────────
//   Widget _buildHeader(
//       BuildContext context, double sw, double topPad, dynamic contract) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         top: topPad + 12,
//         bottom: 28,
//         left: sw * 0.03,
//         right: sw * 0.04,
//       ),
//       decoration: const BoxDecoration(
//         color: AppColors.white,
//         border: Border(
//           bottom: BorderSide(color: AppColors.cborder, width: 1.5),
//         ),
//       ),
//       child: Row(
//         children: [
//           // BACK BUTTON (same style)
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: AppColors.c3,
//                 size: 15,
//               ),
//             ),
//           ),

//           const SizedBox(width: 12),

//           // TITLE
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Contract Details",
//                   style: TextStyle(
//                     color: AppColors.cdark,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 Text(
//                   (contract.name ?? "")
//                       .split(' ')
//                       .map((word) => word.isNotEmpty
//                           ? word[0].toUpperCase() +
//                               word.substring(1).toLowerCase()
//                           : '')
//                       .join(' '),
//                   style: const TextStyle(
//                     color: AppColors.ctext,
//                     fontSize: 12,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),

//           // EDIT BUTTON (circle)
//           GestureDetector(
//             onTap: () {
//               final vm = context.read<ContractViewmodel>();
//               final contract = vm.currentContract;
//               if (contract == null) return;

//               showDialog(
//                 context: context,
//                 builder: (_) {
//                   return ChangeNotifierProvider.value(
//                     value: vm,
//                     child: ContractDetailsDialog(contract: contract),
//                   );
//                 },
//               );
//             },
//             child: Container(
//               width: 38,
//               height: 38,
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.cxl,
//                 shape: BoxShape.circle,
//                 border: Border.all(color: AppColors.cborder),
//               ),
//               child: const Icon(
//                 Icons.edit,
//                 color: AppColors.c3,
//                 size: 18,
//               ),
//             ),
//           ),

//           // DELETE BUTTON (circle)
//           GestureDetector(
//             onTap: () {
//               final vm = context.read<ContractViewmodel>();
//               final contract = vm.currentContract;
//               if (contract == null) return;

//               showDeleteDialog(
//                 context,
//                 "Contract",
//                 () async {
//                   final success = await vm.deleteContract(
//                     contract.id!,
//                     widget.customerId,
//                     context,
//                   );

//                   if (success && context.mounted) {
//                     Navigator.pop(context);
//                     pushNavigation(context, const CustomerMain());
//                   }
//                 },
//               );
//             },
//             child: Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: AppColors.red.withOpacity(0.15),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: AppColors.red.withOpacity(0.35),
//                 ),
//               ),
//               child: const Icon(
//                 Icons.delete_outline,
//                 color: AppColors.red,
//                 size: 18,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ───────────────── BODY ─────────────────
//   Widget _buildContractUI(contract) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: contract.sections.length,
//             itemBuilder: (context, index) {
//               final section = contract.sections[index];

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding:
//                             const EdgeInsets.all(1), // border thickness control
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: AppColors.cborder, // border color
//                         ),
//                         child: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: AppColors.c3,
//                           child: Text(
//                             "${section.order}",
//                             style: const TextStyle(
//                               color: AppColors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Text(
//                         section.title.toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w900,
//                           color: AppColors.cdark,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   ...section.points.map(
//                     (point) => Padding(
//                       padding: const EdgeInsets.only(left: 8, bottom: 4),
//                       child: Row(
//                         children: [
//                           const Text("• ",
//                               style:
//                                   TextStyle(fontSize: 20, color: AppColors.c2)),
//                           Expanded(
//                             child: Text(
//                               point.content
//                                   .split(' ')
//                                   .map((word) => word.isNotEmpty
//                                       ? word[0].toUpperCase() +
//                                           word.substring(1).toLowerCase()
//                                       : '')
//                                   .join(' '),
//                               style: const TextStyle(
//                                   color: AppColors.ctext,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pokakbilling/core/navigations.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/client_contract_viewmodel.dart';
import 'package:pokakbilling/views/Screens/customer/contract/contract_details.dart';
import 'package:pokakbilling/views/Screens/customer/customer_main.dart';
import 'package:pokakbilling/views/commonWidgets/popups/delete_popup.dart';
import 'package:provider/provider.dart';

class ViewContractDetailsScreen extends StatefulWidget {
  final int contractId;
  final int customerId;

  const ViewContractDetailsScreen({
    super.key,
    required this.contractId,
    required this.customerId,
  });

  @override
  State<ViewContractDetailsScreen> createState() =>
      _ViewContractDetailsScreenState();
}

class _ViewContractDetailsScreenState extends State<ViewContractDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<ContractViewmodel>()
          .getContractById(widget.contractId);
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Navigate to edit page ─────────────────────────────────────────────────
  void _openEditPage(BuildContext context, ContractViewmodel vm) {
    final contract = vm.currentContract;
    if (contract == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: ContractDetailsPage(contract: contract),
        ),
      ),
    );
  }

  // ── Delete handler ────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, ContractViewmodel vm) {
    final contract = vm.currentContract;
    if (contract == null) return;

    showDeleteDialog(
      context,
      'Contract',
      () async {
        final success = await vm.deleteContract(
          contract.id!,
          widget.customerId,
          context,
        );
        if (success && context.mounted) {
          Navigator.pop(context);
          pushNavigation(context, const CustomerMain());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final topPad = MediaQuery.of(context).padding.top;

    return Consumer<ContractViewmodel>(
      builder: (context, vm, _) {
        final contract = vm.currentContract;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: vm.detailsLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.c1,
                      strokeWidth: 2,
                    ),
                  )
                : contract == null
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          _buildHeader(context, sw, topPad, vm, contract),
                          Expanded(
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: SlideTransition(
                                position: _slideAnim,
                                child: _buildBody(contract),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cxl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cborder),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.c1,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No contract found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.cdark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'This contract may have been removed',
            style: TextStyle(fontSize: 13, color: AppColors.ctext),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    double sw,
    double topPad,
    ContractViewmodel vm,
    dynamic contract,
  ) {
    final contractName = (contract.name ?? '')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
            : '')
        .join(' ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 12,
        bottom: 28,
        left: sw * 0.03,
        right: sw * 0.04,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cborder, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.c3,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contract Details',
                  style: TextStyle(
                    color: AppColors.cdark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  contractName,
                  style: const TextStyle(
                    color: AppColors.ctext,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Edit button — now navigates to ContractDetailsPage (full page)
          GestureDetector(
            onTap: () => _openEditPage(context, vm),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: AppColors.c3,
                size: 17,
              ),
            ),
          ),

          // Delete button
          GestureDetector(
            onTap: () => _confirmDelete(context, vm),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.red.withOpacity(0.30),
                ),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.red,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody(dynamic contract) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Contract name card ─────────────────────────────────────────
          _buildContractNameCard(contract),
          const SizedBox(height: 16),

          // ── Sections ──────────────────────────────────────────────────
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: contract.sections.length,
            itemBuilder: (context, index) =>
                _buildSectionCard(contract.sections[index], index),
          ),
        ],
      ),
    );
  }

  // ── Contract name summary card ────────────────────────────────────────────
  Widget _buildContractNameCard(dynamic contract) {
    final sectionCount = contract.sections.length as int;
    final pointCount = (contract.sections as List)
        .fold<int>(0, (sum, s) => sum + (s.points as List).length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.c1.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.c1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Name + stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (contract.name ?? '')
                      .split(' ')
                      .map((w) => w.isNotEmpty
                          ? w[0].toUpperCase() + w.substring(1).toLowerCase()
                          : '')
                      .join(' '),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _statChip(
                        Icons.view_list_rounded, '$sectionCount Sections'),
                    const SizedBox(width: 8),
                    _statChip(Icons.circle, '$pointCount Points', small: true),
                  ],
                ),
              ],
            ),
          ),

          // Active badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 12, color: Color(0xFF16A34A)),
                SizedBox(width: 4),
                Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, {bool small = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cborder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 7 : 12, color: AppColors.c1),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.ctext,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSectionCard(dynamic section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cborder),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.cborder),
              ),
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${section.order}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cdark,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                // Point count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cborder),
                  ),
                  child: Text(
                    '${(section.points as List).length} pts',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ctext,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Points list ──────────────────────────────────────────────
          if ((section.points as List).isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Text(
                'No points added for this section.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.ctext,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children: List.generate(
                  (section.points as List).length,
                  (i) {
                    final point = section.points[i];
                    final content = point.content
                        .split(' ')
                        .map((w) => w.isNotEmpty
                            ? w[0].toUpperCase() + w.substring(1).toLowerCase()
                            : '')
                        .join(' ');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bullet with point number
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: AppColors.c1.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.c1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              content,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ctext,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
