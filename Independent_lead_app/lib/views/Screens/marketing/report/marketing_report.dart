// lib/views/Screens/marketing/report/marketing_report_screen.dart
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokakbilling/views/Screens/marketing/report/addreport1.dart';
import 'package:pokakbilling/views/Screens/marketing/report/utils/marketing_pdf.dart';
import 'package:pokakbilling/views/Screens/marketing/report/utils/pdf_previewscreen.dart';
import 'package:pokakbilling/views/Screens/marketing/report/utils/pdf_print_screen.dart';
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

class MarketingReportScreen extends StatefulWidget {
  const MarketingReportScreen({super.key});

  @override
  State<MarketingReportScreen> createState() => _MarketingReportScreenState();
}

class _MarketingReportScreenState extends State<MarketingReportScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketingReportViewmodel()),
        ChangeNotifierProvider(create: (_) => SourceViewmodel()),
        ChangeNotifierProvider(create: (_) => CategoryMarketingViewmodel()),
        ChangeNotifierProvider(create: (_) => LocationViewmodel()),
        ChangeNotifierProvider(create: (_) => SalesPersonViewmodel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.violetblue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.arrow_left, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          titleSpacing: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              const Text(
                'Reports',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Builder(
                builder: (innerContext) {
                  return IconButton(
                    icon: const Icon(Icons.filter_alt_outlined,
                        color: AppColors.white, size: 16),
                    onPressed: () async {
                      final vm = innerContext.read<MarketingReportViewmodel>();
                      await showDialog<String>(
                        context: innerContext,
                        barrierDismissible: true,
                        barrierColor: Colors.black54,
                        builder: (dialogCtx) {
                          final screenSize = MediaQuery.of(dialogCtx).size;
                          const panelWidth = 320.0;
                          final panelHeight = screenSize.height * 0.60;
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: panelWidth,
                                height: panelHeight,
                                child: Material(
                                  elevation: 8,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        decoration: const BoxDecoration(
                                          color: AppColors.violetblue,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.filter_alt_outlined,
                                                color: Colors.white,
                                                size: 18),
                                            const SizedBox(width: 8),
                                            const Expanded(
                                              child: Text(
                                                'Filters',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  Navigator.of(dialogCtx)
                                                      .pop(null),
                                              child: const Icon(Icons.close,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: MultiProvider(
                                            providers: [
                                              ChangeNotifierProvider.value(
                                                  value: vm),
                                              ChangeNotifierProvider.value(
                                                  value: innerContext
                                                      .read<SourceViewmodel>()),
                                              ChangeNotifierProvider.value(
                                                  value: innerContext.read<
                                                      CategoryMarketingViewmodel>()),
                                              ChangeNotifierProvider.value(
                                                  value: innerContext.read<
                                                      LocationViewmodel>()),
                                              ChangeNotifierProvider.value(
                                                  value: innerContext.read<
                                                      SalesPersonViewmodel>()),
                                            ],
                                            child:
                                                const MarketingReportFilterPage(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                      // Filter page handles everything internally - no need to handle result
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              child: Consumer<MarketingReportViewmodel>(
                  builder: (context, vm, child) {
                return ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push<bool>(
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
                          child: const AddReportStep1(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 18),
                  label: const Text(
                    'New Report',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    minimumSize: const Size(0, 28),
                  ),
                );
              }),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: Consumer<MarketingReportViewmodel>(builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(child: Text('Error: ${vm.errorMessage}'));
          }
          if (vm.reports.isEmpty) {
            return const Center(child: Text('No reports available'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 32, 18, 24),
                  itemCount: vm.reports.length,
                  itemBuilder: (context, index) {
                    final report = vm.reports[index];
                    return ReportCard(report: report);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBottomButton('Export PDF', () async {
                      final vm = context.read<MarketingReportViewmodel>();
                      if (vm.reports.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No reports available to export')));
                        return;
                      }

                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfPreviewScreen(
                            title: 'Marketing Report',
                            pdfBytesBuilder: (format) async {
                              final Uint8List bytes =
                                  await buildMarketingPdfSimple(
                                      reports: vm.reports);
                              return bytes;
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildBottomButton('Print', () {
                      final vm = context.read<MarketingReportViewmodel>();
                      if (vm.reports.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No reports available to export')));
                        return;
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfPrintScreen(
                            title: 'Marketing Report',
                            pdfBytesBuilder: (format) async {
                              final Uint8List bytes =
                                  await buildMarketingPdfSimple(
                                      reports: vm.reports);
                              return bytes;
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildBottomButton('Export to Excel', () {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Export to Excel feature coming soon')));
                    }),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.violetblue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: AppColors.violetblue,
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final MarketingReport report;
  const ReportCard({required this.report, super.key});

  void _showDeleteConfirmation(
      BuildContext context, MarketingReportViewmodel vm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            TextButton(
              onPressed: vm.deleteReportLoading
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      vm.deleteReport(report.id, context);
                    },
              child: vm.deleteReportLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 353.0;
    const double cardHeight = 172.0;
    const double actionAreaWidth = 75.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 8,
                  right: 8,
                  child:
                      Container(height: 1.0, color: const Color(0xFF232792))),
              LayoutBuilder(builder: (context, constraints) {
                final leftWidth = (constraints.maxWidth - actionAreaWidth)
                    .clamp(0.0, constraints.maxWidth);

                return Row(
                  children: [
                    SizedBox(
                      width: leftWidth,
                      height: cardHeight,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                          topRight: Radius.circular(44),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF232792), Color(0xFF141BE4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 54,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('DATE',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(report.date,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                      const SizedBox(height: 10),
                                      const Text('SALES PERSON',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(report.salesperson,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                      const SizedBox(height: 10),
                                      const Text('CATEGORY',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(report.category,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 46,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('LOCATION',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(report.location,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white)),
                                      const SizedBox(height: 10),
                                      const Text('SOURCE',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      Text(report.source,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('CALLS',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white70,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(height: 4),
                                                Text('${report.calls}',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('LEADS',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white70,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(height: 4),
                                                Text('${report.leads}',
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white)),
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
                      ),
                    ),
                    Container(
                      width: actionAreaWidth,
                      height: cardHeight,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFF232792), width: 1.0),
                          right: BorderSide(color: Color(0xFF232792)),
                          bottom: BorderSide(color: Color(0xFF232792)),
                        ),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                      ),
                      child: Consumer<MarketingReportViewmodel>(
                          builder: (context, vm, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiProvider(
                                      providers: [
                                        ChangeNotifierProvider.value(value: vm),
                                        ChangeNotifierProvider.value(
                                            value: context
                                                .read<SourceViewmodel>()),
                                        ChangeNotifierProvider.value(
                                            value: context.read<
                                                CategoryMarketingViewmodel>()),
                                        ChangeNotifierProvider.value(
                                            value: context
                                                .read<LocationViewmodel>()),
                                        ChangeNotifierProvider.value(
                                            value: context
                                                .read<SalesPersonViewmodel>()),
                                      ],
                                      child: EditMarketingReportPage(
                                          report: report),
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(Icons.edit_outlined,
                                  size: 22, color: Colors.black54),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: vm.deleteReportLoading
                                  ? null
                                  : () => _showDeleteConfirmation(context, vm),
                              child: const Icon(Icons.delete_outline,
                                  size: 22, color: Colors.black54),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
