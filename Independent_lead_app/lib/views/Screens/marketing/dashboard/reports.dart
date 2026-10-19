// lib/views/Screens/marketing/report/marketing_report_screen.dart

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

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _MarketingReportScreenState();
}

class _MarketingReportScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFFA4A0A0),
                      size: 14, // reduced size
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search Reports',
                          hintStyle: TextStyle(
                            color: Color(0xFFA4A0A0),
                            fontSize: 12, // smaller hint text
                            fontWeight: FontWeight.w400, // 400 weight
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          const SizedBox(width: 10),
          InkWell(
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
            child: const SizedBox(
              height: 42,
              width: 42,
              child: Icon(Icons.filter_alt_outlined, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, MarketingReport report) {
    const double cardHeight = 210.0;

    const labelStyle = TextStyle(
      fontSize: 11,
      color: AppColors.violetblue,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
    const valueStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
    const smallValueStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E9FF),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 54,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DATE', style: labelStyle),
                          const SizedBox(height: 6),
                          Text(report.date, style: valueStyle),
                          const SizedBox(height: 28),
                          const Text('SALES PERSON', style: labelStyle),
                          const SizedBox(height: 6),
                          Text(report.salesperson,
                              style: smallValueStyle,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 28),
                          const Text('CATEGORY', style: labelStyle),
                          const SizedBox(height: 6),
                          Text(report.category,
                              style: smallValueStyle,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 46,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LOCATION', style: labelStyle),
                          const SizedBox(height: 6),
                          Text(report.location,
                              style: valueStyle,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 28),
                          const Text('SOURCE', style: labelStyle),
                          const SizedBox(height: 6),
                          Text(report.source,
                              style: smallValueStyle,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('CALLS', style: labelStyle),
                                    const SizedBox(height: 6),
                                    Text('${report.calls}',
                                        style: smallValueStyle),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('LEADS', style: labelStyle),
                                    const SizedBox(height: 6),
                                    Text('${report.leads}',
                                        style: smallValueStyle),
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
            ),
            Positioned(
              top: 2,
              right: -10,
              child: PopupMenuButton<int>(
                padding: const EdgeInsets.all(4),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                icon: const Icon(Icons.more_vert,
                    color: Color(0xFF2C2A74), size: 20),
                onSelected: (value) async {
                  final vm = context.read<MarketingReportViewmodel>();
                  if (value == 1) {
                    await Navigator.push(
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
                  } else if (value == 2) {
                    if (vm.deleteReportLoading) return;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        title: const Text('Delete Report'),
                        content: const Text(
                            'Are you sure you want to delete this report?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(true),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red))),
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
                  const PopupMenuItem(value: 1, child: Text('Edit')),
                  const PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          backgroundColor: AppColors.violetblue, // full violet background
          body: Consumer<MarketingReportViewmodel>(builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null) {
              return Center(child: Text('Error: ${vm.errorMessage}'));
            }
            final reports = vm.reports;

            return Column(
              children: [
                const SizedBox(height: 8),
                _buildSearchBar(innerContext),
                const SizedBox(height: 6),
                Expanded(
                  child: reports.isEmpty
                      ? const Center(child: Text('No reports available'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 90),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final r = reports[index];
                            return _buildReportCard(context, r);
                          },
                        ),
                ),
              ],
            );
          }),

          // ✅ FAB: white background, black + icon
          floatingActionButton: SizedBox(
            width: 75,
            height: 73,
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: Colors.white, // white background
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

                if (created == true) {
                  // ignore: use_build_context_synchronously
                  await innerContext
                      .read<MarketingReportViewmodel>()
                      .fetchReports();
                  if (mounted) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(innerContext).showSnackBar(
                      const SnackBar(
                          content: Text('Report added — list refreshed')),
                    );
                  }
                }
              },
              child: const Icon(Icons.add, color: Colors.black, size: 32),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      }),
    );
  }
}
