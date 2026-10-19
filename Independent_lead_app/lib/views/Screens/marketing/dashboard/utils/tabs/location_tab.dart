import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/location/editLocationScreen.dart';

// NEW: for live/fallback leads-per-location via reports
import 'package:pokakbilling/viewmodels/setup/marketing_report_viewmodel.dart';
import 'package:pokakbilling/models/services/marketing_report_service.dart';
import 'package:pokakbilling/models/data-models/marketing_model/marketing_report.dart'
    as MR;

class LocationTab extends StatefulWidget {
  const LocationTab({super.key});

  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  final TextEditingController _search = TextEditingController();

  // live map of locationId -> leads count
  final Map<int, int> _leadsByLocationId = {};
  // fallback map of locationName(lower) -> leads count (if ids not present)
  final Map<String, int> _leadsByLocationName = {};

  VoidCallback? _reportsListener;

  @override
  void initState() {
    super.initState();
    // defer provider attachment until first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attachReportsProviderOrFetch();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    // detach listener if attached
    try {
      final repVm =
          Provider.of<MarketingReportViewmodel>(context, listen: false);
      _reportsListener != null ? repVm.removeListener(_reportsListener!) : null;
    } catch (_) {}
    super.dispose();
  }

  /// Try to consume MarketingReportViewmodel for live counts; if not available, fallback to service.
  Future<void> _attachReportsProviderOrFetch() async {
    try {
      final repVm =
          Provider.of<MarketingReportViewmodel>(context, listen: false);

      // seed from current data
      _recomputeFromReports(repVm.reports);
      setState(() {});

      // listen for changes
      _reportsListener = () {
        _recomputeFromReports(repVm.reports);
        if (mounted) setState(() {});
      };
      repVm.addListener(_reportsListener!);
    } catch (_) {
      // Provider not found — fallback to direct fetch
      try {
        final raw = await MarketingReportService.getReports();
        final parsed = raw
            .map((e) => MR.MarketingReport.fromJson(e as Map<String, dynamic>))
            .toList();
        _recomputeFromReports(parsed);
        if (mounted) setState(() {});
      } catch (e) {
        // ignore, counts remain zero
      }
    }
  }

  void _recomputeFromReports(List<MR.MarketingReport> reports) {
    _leadsByLocationId.clear();
    _leadsByLocationName.clear();

    for (final r in reports) {
      final leads = r.leads ?? 0;
      if (leads <= 0) continue;

      if (r.locationId != 0) {
        _leadsByLocationId.update(r.locationId, (v) => v + leads,
            ifAbsent: () => leads);
      } else {
        final key = (r.location ?? '').trim().toLowerCase();
        if (key.isNotEmpty) {
          _leadsByLocationName.update(key, (v) => v + leads,
              ifAbsent: () => leads);
        }
      }
    }
  }

  int _countForLocation({required int id, required String name}) {
    if (_leadsByLocationId.containsKey(id)) return _leadsByLocationId[id] ?? 0;
    final key = name.trim().toLowerCase();
    return _leadsByLocationName[key] ?? 0;
  }

  Future<void> _confirmAndDeleteLocation(
      BuildContext context, LocationViewmodel vm, int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Consumer<LocationViewmodel>(
        builder: (dialogCtx, vm2, _) => AlertDialog(
          title: const Text('Delete Location'),
          content: Text('Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: vm2.deleteLocationLoading
                  ? null
                  : () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: vm2.deleteLocationLoading
                  ? null
                  : () => Navigator.of(dialogCtx).pop(true),
              child: vm2.deleteLocationLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete',
                      style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await vm.deleteLocation(id, context);
      await vm.fetchLocations();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationViewmodel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage != null) {
          return Center(child: Text('Error: ${vm.errorMessage}'));
        }

        final q = _search.text.trim().toLowerCase();
        final items = vm.locations
            .where((e) => e.name.toLowerCase().contains(q))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Location.',
                    hintStyle: const TextStyle(
                      color: Color(0xFFA9A0A0),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon:
                        const Icon(Icons.search, color: Color(0xFF37343C)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Text('Top',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_upward, size: 16, color: Color(0xFF13C313)),
                ],
              ),
            ),
            const SizedBox(height: 6),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final location = items[index];
                  final leadCount = _countForLocation(
                    id: location.id,
                    name: location.name,
                  );

                  return Container(
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.listCardGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 28,
                                    child: Icon(Icons.location_on_outlined,
                                        color: AppColors.violetblue, size: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    location.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2C2A74),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/lead_small.png',
                                        width: 15,
                                        height: 16,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$leadCount Leads',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white, size: 22),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await Navigator.push<bool?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: vm,
                                      child:
                                          EditLocationPage(location: location),
                                    ),
                                  ),
                                );
                                await vm.fetchLocations();
                              } else if (value == 'delete') {
                                await _confirmAndDeleteLocation(
                                    context, vm, location.id, location.name);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ),
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
