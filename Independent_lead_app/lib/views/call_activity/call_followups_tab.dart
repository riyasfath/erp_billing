import 'package:flutter/material.dart';
import 'package:pokakbilling/views/call_activity/call_activity_helpers.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/dashboard_model.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';
import 'package:pokakbilling/views/call_activity/active_call_screen.dart';

/// "Follow-ups" tab — split out of CallActivityScreen without changes.
class FollowUpsTab extends StatelessWidget {
  /// Called after returning from a call — mirrors the parent's
  /// `_resetFilters(refresh: true)` call from the original file.
  final VoidCallback onAfterCall;

  const FollowUpsTab({super.key, required this.onAfterCall});

  CallLeadModel _leadFromFollowUp(CallFollowUpModel f) => CallLeadModel(
        leadId: f.id ?? 0,
        name: f.name,
        phone: f.phone,
        status: f.status,
        source: f.source,
      );

  Future<void> _startCallWithLead(
      BuildContext context, CallLeadModel lead) async {
    if (lead.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this lead')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveCallScreen(lead: lead)),
    );
    onAfterCall();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallActivityViewmodel>(
      builder: (context, vm, _) {
        if (vm.getFollowUpsLoader && !vm.followUpsLoaded) {
          return callActivityLoadingState();
        }

        final items = vm.followUpsData.results;
        if (items.isEmpty) {
          return callActivityEmptyState(
            icon: Icons.event_repeat_rounded,
            title: 'No follow-ups scheduled',
            subtitle: 'Upcoming follow-up calls will appear here.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionLabelWithBadge('FOLLOW-UPS', vm.followUpsData.count,
                AppColors.c3, Icons.event_repeat_rounded),
            const SizedBox(height: 10),
            ...items.map((f) => _followUpCard(context, f)),
          ],
        );
      },
    );
  }

  Widget _followUpCard(BuildContext context, CallFollowUpModel f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.c1.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 14, 13, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name + phone row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child:
                      Icon(Icons.call_rounded, size: 17, color: AppColors.c1),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cdark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        f.phone,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ctext.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Large Call Now button
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _startCallWithLead(context, _leadFromFollowUp(f)),
                child: Ink(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.c1,
                        AppColors.c1.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c1.withOpacity(0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_rounded,
                          size: 18, color: AppColors.white),
                      SizedBox(width: 8),
                      Text(
                        'Call Now',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
