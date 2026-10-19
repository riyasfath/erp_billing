import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/views/Screens/marketing/location/editLocationScreen.dart';

import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/services/lead_services.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kMetricInk = Color(0xFF1E1B4B);

class LocationTab extends StatefulWidget {
  const LocationTab({super.key});
  @override
  State<LocationTab> createState() => _LocationTabState();
}

class _LocationTabState extends State<LocationTab> {
  final TextEditingController _search = TextEditingController();
  final Map<int, int> _leadsByLocationId = {};
  VoidCallback? _leadVmListener;
  bool _sortDescending = true;

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
      setState(() {});
      _leadVmListener = () {
        _recomputeFromLeads(leadVm.leadList);
        if (mounted) setState(() {});
      };
      leadVm.addListener(_leadVmListener!);
    } catch (_) {
      try {
        final leads = await LeadServices.getLeads();
        _recomputeFromLeads(leads);
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Failed to fetch leads for location counts: $e');
      }
    }
  }

  void _recomputeFromLeads(List<LeadModel> leads) {
    _leadsByLocationId.clear();
    for (final l in leads) {
      final locationId = l.location;
      if (locationId == null || locationId == 0) continue;
      _leadsByLocationId.update(locationId, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  int _countForLocationId(int id) => _leadsByLocationId[id] ?? 0;
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

  void _showLocationMenu({
    required BuildContext context,
    required LocationViewmodel vm,
    required dynamic location,
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
                _showHasLeadsWarning(context, location.name, leadCount);
              } else {
                _confirmAndDeleteLocation(
                    context, vm, location.id, location.name);
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
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: EditLocationPage(location: location),
            ),
          ),
        );
        await vm.fetchLocations();
      }
    });
  }

  Future<void> _confirmAndDeleteLocation(
      BuildContext context, LocationViewmodel vm, int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Consumer<LocationViewmodel>(
        builder: (dialogCtx, vm2, _) => AlertDialog(
          backgroundColor: _isDark ? const Color(0xFF2A2750) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Delete Location',
              style: TextStyle(
                  color: _isDark ? Colors.white : _kMetricInk,
                  fontWeight: FontWeight.w700)),
          content: Text('Are you sure you want to delete "$name"?',
              style:
                  TextStyle(color: _isDark ? Colors.white70 : Colors.black87)),
          actions: [
            TextButton(
              onPressed: vm2.deleteLocationLoading
                  ? null
                  : () => Navigator.of(dialogCtx).pop(false),
              child: Text('Cancel',
                  style:
                      TextStyle(color: _isDark ? Colors.white54 : Colors.grey)),
            ),
            TextButton(
              onPressed: vm2.deleteLocationLoading
                  ? null
                  : () => Navigator.of(dialogCtx).pop(true),
              child: vm2.deleteLocationLoading
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
    );

    if (confirmed == true) {
      await vm.deleteLocation(id, context);
      await vm.fetchLocations();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location deleted successfully'),
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
    return Consumer<LocationViewmodel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: _kIndigo));
        }
        if (vm.errorMessage != null) {
          return Center(child: Text('Error: ${vm.errorMessage}'));
        }

        final q = _search.text.trim().toLowerCase();
        final items = vm.locations
            .where((e) => e.name.toLowerCase().contains(q))
            .toList();

        items.sort((a, b) {
          final countA = _countForLocationId(a.id);
          final countB = _countForLocationId(b.id);
          return _sortDescending
              ? countB.compareTo(countA)
              : countA.compareTo(countB);
        });

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
                    hintText: 'Search locations…',
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
              child: items.isEmpty
                  ? Center(
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
                            child: Icon(Icons.location_off_outlined,
                                size: 28,
                                color: _isDark ? _kIndigoLight : _kIndigoDark),
                          ),
                          const SizedBox(height: 10),
                          Text('No locations found',
                              style: TextStyle(
                                  color: _isDark ? Colors.white60 : _kMetricInk,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 120),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final location = items[index];
                        final leadCount = _countForLocationId(location.id);
                        final hasLeads = leadCount > 0;

                        return _LocationCard(
                          location: location,
                          leadCount: leadCount,
                          hasLeads: hasLeads,
                          isDark: _isDark,
                          onMenuTap: (details) {
                            _showLocationMenu(
                              context: context,
                              vm: vm,
                              location: location,
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

// ── Location card ─────────────────────────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  final dynamic location;
  final int leadCount;
  final bool hasLeads;
  final bool isDark;
  final void Function(TapDownDetails) onMenuTap;

  const _LocationCard({
    required this.location,
    required this.leadCount,
    required this.hasLeads,
    required this.isDark,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
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
            // Icon container
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
                child: Icon(Icons.location_on_outlined,
                    color: isDark ? _kIndigoLight : _kIndigoDark, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
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
                      Icon(Icons.people_outline_rounded,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 4),
                      Text(
                        '$leadCount ${leadCount == 1 ? 'Lead' : 'Leads'}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Three-dot menu
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
