import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/models/call_activity/call_lead_model.dart';
import 'package:pokakbilling/viewmodels/call_activity/dashboard_viewmodel.dart';
import 'package:pokakbilling/views/call_activity/active_call_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// SELECT LEAD FOR CALL — full page
/// Replaces the "Start New Call" popup from the web version. Lists leads
/// from GET /call-activity/start-new_call/, with a search box and, per row,
/// a phone icon (→ Active Call page).
/// ─────────────────────────────────────────────────────────────────────────
class SelectLeadForCallScreen extends StatefulWidget {
  const SelectLeadForCallScreen({super.key});

  @override
  State<SelectLeadForCallScreen> createState() =>
      _SelectLeadForCallScreenState();
}

class _SelectLeadForCallScreenState extends State<SelectLeadForCallScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallActivityViewmodel>().getCallableLeads();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() => _query = v);
    context.read<CallActivityViewmodel>().getCallableLeads(
          search: v.trim().isEmpty ? null : v.trim(),
        );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _callLead(CallLeadModel lead) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveCallScreen(lead: lead)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cxl,
      body: Column(
        children: [
          _header(context),
          _searchBar(),
          Expanded(
            child: Consumer<CallActivityViewmodel>(
              builder: (context, vm, _) {
                if (vm.getCallableLeadsLoader &&
                    vm.callableLeads.results.isEmpty) {
                  return const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: AppColors.c1,
                        strokeWidth: 3,
                      ),
                    ),
                  );
                }

                final leads = vm.callableLeads.results;
                if (leads.isEmpty) {
                  return _emptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            '${leads.length} ${leads.length == 1 ? 'Lead' : 'Leads'}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ctext.withOpacity(0.55),
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (_query.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              'for "$_query"',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.c1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _leadCard(leads[index], index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _leadCard(CallLeadModel lead, int index) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _callLead(lead),
        splashColor: AppColors.c1.withOpacity(0.06),
        highlightColor: AppColors.c1.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cborder),
            boxShadow: [
              BoxShadow(
                color: AppColors.cdark.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.c1.withOpacity(0.18),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(lead.name),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.c1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            lead.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cdark,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cxl,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cborder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            lead.status,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cdark,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_iphone_rounded,
                            size: 12.5,
                            color: AppColors.ctext.withOpacity(0.5)),
                        const SizedBox(width: 4),
                        Text(
                          lead.phone,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ctext.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (lead.source != null && lead.source!.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.c3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: AppColors.c3.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 11, color: AppColors.c3),
                      const SizedBox(width: 3),
                      Text(
                        lead.source!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.c3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
              ],
              GestureDetector(
                onTap: () => _callLead(lead),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.c1.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call_rounded,
                      size: 17, color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocus.hasFocus
                ? AppColors.c1.withOpacity(0.45)
                : AppColors.cborder,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cdark.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(Icons.search_rounded,
                size: 19, color: AppColors.ctext.withOpacity(0.55)),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                onChanged: _onSearchChanged,
                onTapOutside: (_) => _searchFocus.unfocus(),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cdark,
                ),
                decoration: InputDecoration(
                  hintText: 'Search leads by name or phone…',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ctext.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  _onSearchChanged('');
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: AppColors.c1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _query.isEmpty
                    ? Icons.people_outline_rounded
                    : Icons.search_off_rounded,
                size: 34,
                color: AppColors.c1.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _query.isEmpty ? 'No leads found' : 'No matches found',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.cdark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _query.isEmpty
                  ? 'Callable leads will show up here once available.'
                  : 'Try a different name or phone number.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ctext.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
            bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cdark.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.cxl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cborder),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.c1, size: 18),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start New Call',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cdark,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pick a lead to begin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ctext.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_rounded,
                color: AppColors.c1, size: 19),
          ),
        ],
      ),
    );
  }
}
