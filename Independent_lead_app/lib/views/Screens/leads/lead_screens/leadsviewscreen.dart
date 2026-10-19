import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pokakbilling/core/api/api_constants.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/followupListScreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/follow_up_sheet.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/meeting_sheet.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/reminder_sheet.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/meetingsListScreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/remindersListScreen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/core/api/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

const List<String> _kKnownStatuses = [
  'New',
  'Contacted',
  'Qualified',
  'Converted',
  'Lost',
];

class LeadsViewScreen extends StatefulWidget {
  final dynamic lead;
  const LeadsViewScreen({super.key, required this.lead});

  @override
  State<LeadsViewScreen> createState() => _LeadsViewScreenState();
}

class _LeadsViewScreenState extends State<LeadsViewScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _bodyCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;

  String _dropdownValue = 'New';
  late TextEditingController _customReasonCtrl;
  bool _isUserSelectedOther = false;
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _bodyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _bodyFade = CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut);
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeOut));

    _headerCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 200), () => _bodyCtrl.forward());

    _resolveInitialStatus();

    final initialReason = _dropdownValue == 'Other'
        ? (_safeString(widget.lead, 'reason').trim())
        : '';
    _customReasonCtrl = TextEditingController(text: initialReason);
  }

  void _resolveInitialStatus() {
    final rawKey = _safeString(widget.lead, 'status').toUpperCase();
    switch (rawKey) {
      case 'NEW':
        _dropdownValue = 'New';
        break;
      case 'CONTACTED':
        _dropdownValue = 'Contacted';
        break;
      case 'QUALIFIED':
        _dropdownValue = 'Qualified';
        break;
      case 'CONVERTED':
        _dropdownValue = 'Converted';
        break;
      case 'LOST':
        _dropdownValue = 'Lost';
        break;
      default:
        _dropdownValue = 'Other';
        _isUserSelectedOther = false;
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _bodyCtrl.dispose();
    _customReasonCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _labelToStatusKey(String label) {
    switch (label) {
      case 'New':
        return 'NEW';
      case 'Contacted':
        return 'CONTACTED';
      case 'Qualified':
        return 'QUALIFIED';
      case 'Converted':
        return 'CONVERTED';
      case 'Lost':
        return 'LOST';
      default:
        return 'OTHER';
    }
  }

  bool _isLeadModel(dynamic obj) => obj is LeadModel;
  bool _isMap(dynamic obj) => obj is Map<String, dynamic>;

  dynamic _safeGet(dynamic obj, String fieldSnake, {String? fieldCamel}) {
    if (obj == null) return null;
    if (_isLeadModel(obj)) {
      final LeadModel lm = obj as LeadModel;
      switch (fieldSnake) {
        case 'id':
          return lm.id;
        case 'leadId':
          return lm.leadId;
        case 'name':
          return lm.name;
        case 'phone':
          return lm.phone;
        case 'email':
        case 'emailId':
          return lm.email;
        case 'created_at':
        case 'createdAt':
        case 'date':
          return lm.createdAt;
        case 'enquiry':
          return lm.enquiry;
        case 'company':
          return lm.company;
        case 'address':
          return lm.address;
        case 'location':
          return lm.location;
        case 'status':
          return lm.status;
        case 'status_display':
          return lm.statusDisplay;
        case 'reason':
          return lm.reason;
        case 'source':
        case 'lead_source':
          return lm.source;
        case 'assigned_to_name':
        case 'salesperson':
          return lm.assignedToName;
        case 'project_requirements':
          return lm.projectRequirements;
        case 'additional_notes':
        case 'notes':
          return lm.additionalNotes;
        default:
          return null;
      }
    }
    if (_isMap(obj)) {
      final m = obj as Map<String, dynamic>;
      if (m.containsKey(fieldSnake)) return m[fieldSnake];
      if (fieldCamel != null && m.containsKey(fieldCamel)) return m[fieldCamel];
      return m[fieldSnake] ?? m[fieldCamel];
    }
    return null;
  }

  String _safeString(dynamic obj, String field) {
    final val = _safeGet(obj, field, fieldCamel: _snakeToCamel(field));
    if (val == null) return '';
    return val.toString().trim();
  }

  int? _safeInt(dynamic obj, String field) {
    final val = _safeGet(obj, field, fieldCamel: _snakeToCamel(field));
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString());
  }

  String _snakeToCamel(String s) {
    final parts = s.split('_');
    if (parts.length == 1) return s;
    return parts.first +
        parts
            .sublist(1)
            .map((p) => p.substring(0, 1).toUpperCase() + p.substring(1))
            .join();
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  void _navigateToEdit() {
    final LeadModel? model =
        widget.lead is LeadModel ? widget.lead as LeadModel : null;
    if (model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead data unavailable for editing')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateLead(isEdit: true, lead: model)),
    );
  }

  Future<void> _showScheduleFollowupSheet({int? leadId}) async {
    final int resolvedLeadId = leadId ??
        _safeInt(widget.lead, 'id') ??
        _safeInt(widget.lead, 'leadId') ??
        0;
    if (resolvedLeadId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine lead for follow-up')),
      );
      return;
    }
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          FollowupSheet(preselectType: 'Phone Call', leadId: resolvedLeadId),
    );
  }

  Future<void> _showScheduleMeetingSheet() async {
    final int resolvedLeadId =
        _safeInt(widget.lead, 'id') ?? _safeInt(widget.lead, 'leadId') ?? 0;
    if (resolvedLeadId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to determine lead for meeting')),
        );
      }
      return;
    }
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MeetingSheet(
        leadName: _safeString(widget.lead, 'name'),
        leadId: resolvedLeadId,
      ),
    );
    if (res == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Meeting scheduled')));
    }
  }

  Future<void> _showSetReminderSheet() async {
    final int resolvedLeadId =
        _safeInt(widget.lead, 'id') ?? _safeInt(widget.lead, 'leadId') ?? 0;
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReminderSheet(
        leadId: resolvedLeadId == 0 ? null : resolvedLeadId,
        leadName: _safeString(widget.lead, 'name').isEmpty
            ? null
            : _safeString(widget.lead, 'name'),
      ),
    );
    if (res == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reminder scheduled')));
    }
  }

  Future<void> _logActivity({
    required int leadId,
    required String activityType,
    required String action,
  }) async {
    try {
      final dio = await DioClient().getAuthorizedDio();
      await dio.post(ApiConstants.leadActivityManualEndpoint, data: {
        'lead': leadId,
        'activity_type': activityType,
        'action': action,
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Activity logged')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    try {
      await launchUrl(Uri.parse('https://wa.me/$cleaned'),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _launchCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    try {
      await launchUrl(Uri(scheme: 'tel', path: cleaned),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) return;
    try {
      await launchUrl(Uri(scheme: 'mailto', path: email.trim()),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // ─── PATCH status ─────────────────────────────────────────────────────────
  // FIX: after a successful patch, call getAllLeads + getAssignedLeads
  // so the list screen reflects the new status immediately on back-navigation.

  Future<void> _patchStatus(int leadId) async {
    if (_updating) return;
    if (_dropdownValue == 'Other' && _customReasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason')),
      );
      return;
    }
    setState(() => _updating = true);
    try {
      final dio = await DioClient().getAuthorizedDio();
      final Map<String, dynamic> payload = {
        'status': _labelToStatusKey(_dropdownValue),
        'reason':
            _dropdownValue == 'Other' ? _customReasonCtrl.text.trim() : '',
      };
      await dio.patch('${ApiConstants.leadsEndpoint}$leadId/', data: payload);

      if (mounted) {
        // ── FIX: Refresh the ViewModel so the list is up-to-date ──────────
        final vm = Provider.of<LeadViewmodel>(context, listen: false);
        vm.getAllLeads();
        vm.getAssignedLeads();
        // ─────────────────────────────────────────────────────────────────

        final snackLabel = _dropdownValue == 'Other'
            ? _customReasonCtrl.text.trim()
            : _dropdownValue;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('Status updated to "$snackLabel"'),
            ]),
            backgroundColor: AppColors.c1,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        if (_dropdownValue == 'Other') {
          setState(() => _isUserSelectedOther = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadViewmodel>(
      builder: (context, vm, _) {
        final sw = MediaQuery.of(context).size.width;
        final topPad = MediaQuery.of(context).padding.top;

        final int leadId =
            _safeInt(widget.lead, 'id') ?? _safeInt(widget.lead, 'leadId') ?? 0;
        final String leadName = _safeString(widget.lead, 'name');
        final String phone = _safeString(widget.lead, 'phone');
        final String email = _safeString(widget.lead, 'email');
        final String company = _safeString(widget.lead, 'company');
        final String source = _safeString(widget.lead, 'source').isNotEmpty
            ? _safeString(widget.lead, 'source')
            : 'No source';
        final String location = _safeString(widget.lead, 'location').isNotEmpty
            ? _safeString(widget.lead, 'location')
            : _safeString(widget.lead, 'address').isNotEmpty
                ? _safeString(widget.lead, 'address')
                : 'No location';
        final String createdAt =
            _formatDate(_safeString(widget.lead, 'createdAt'));
        final String enquiry = _safeString(widget.lead, 'enquiry');
        final String projectReq =
            _safeString(widget.lead, 'project_requirements');
        final String notes = _safeString(widget.lead, 'additional_notes');
        final String initials =
            leadName.isNotEmpty ? leadName[0].toUpperCase() : 'L';
        final bool isConverted = _dropdownValue.toUpperCase() == 'CONVERTED';

        final String headerBadgeLabel = _dropdownValue == 'Other'
            ? (_customReasonCtrl.text.trim().isNotEmpty
                ? _customReasonCtrl.text.trim()
                : _safeString(widget.lead, 'reason').trim().isNotEmpty
                    ? _safeString(widget.lead, 'reason').trim()
                    : 'Other')
            : _dropdownValue;

        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: const LeadsBottomBar(index: 2),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                FadeTransition(
                  opacity: _headerFade,
                  child: SlideTransition(
                    position: _headerSlide,
                    child: _buildHeader(
                      context,
                      topPad,
                      sw,
                      leadName,
                      company,
                      source,
                      initials,
                      isConverted,
                      createdAt,
                      phone,
                      email,
                      leadId,
                      headerBadgeLabel,
                    ),
                  ),
                ),
                Expanded(
                  child: FadeTransition(
                    opacity: _bodyFade,
                    child: SlideTransition(
                      position: _bodySlide,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                margin:
                                    const EdgeInsets.only(top: 12, bottom: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.c1.withOpacity(0.40),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 32),
                                  child: Column(
                                    children: [
                                      _buildInfoCard(
                                          email, phone, location, enquiry),
                                      const SizedBox(height: 14),
                                      _buildStatusCard(leadId),
                                      const SizedBox(height: 14),
                                      _buildQuickActionsCard(leadId, leadName),
                                      if (projectReq.isNotEmpty ||
                                          notes.isNotEmpty) ...[
                                        const SizedBox(height: 14),
                                        _buildNotesCard(projectReq, notes),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    double topPad,
    double sw,
    String leadName,
    String company,
    String source,
    String initials,
    bool isConverted,
    String createdAt,
    String phone,
    String email,
    int leadId,
    String headerBadgeLabel,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPad + 14,
        bottom: 24,
        left: sw * 0.05,
        right: sw * 0.05,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.cborder, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
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
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.c3, size: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lead Details',
                      style: TextStyle(
                          color: AppColors.cdark,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Created $createdAt',
                      style: const TextStyle(
                          color: AppColors.ctext, fontSize: 12)),
                ],
              ),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.c1.withOpacity(0.35)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isConverted
                        ? Icons.check_circle_rounded
                        : Icons.flag_rounded,
                    color: AppColors.c1,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 90),
                    child: Text(
                      headerBadgeLabel,
                      style: TextStyle(
                          color: AppColors.c1,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _navigateToEdit,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.c1.withOpacity(0.25)),
                  ),
                  child:
                      Icon(Icons.edit_rounded, color: AppColors.c1, size: 16),
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.18),
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppColors.c1.withOpacity(0.40), width: 2),
              ),
              child: Center(
                child: Text(initials,
                    style: TextStyle(
                        color: isConverted ? AppColors.c1 : AppColors.ctext,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(leadName.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.cdark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (company.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(children: [
                      Icon(Icons.business_outlined,
                          size: 12, color: AppColors.ctext.withOpacity(0.55)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(company,
                            style: TextStyle(
                                color: AppColors.ctext.withOpacity(0.70),
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.public_rounded,
                        size: 12, color: AppColors.ctext.withOpacity(0.45)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(source,
                          style: TextStyle(
                              color: AppColors.ctext.withOpacity(0.55),
                              fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: _ContactChip(
                svgIcon: _kWhatsAppSvg,
                label: 'WhatsApp',
                onTap: () {
                  _launchWhatsApp(phone);
                  _logActivity(
                      leadId: leadId,
                      activityType: 'message',
                      action: 'Sent a WhatsApp message');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ContactChip(
                icon: Icons.call_rounded,
                label: 'Call',
                onTap: () {
                  _launchCall(phone);
                  _logActivity(
                      leadId: leadId,
                      activityType: 'call',
                      action: 'Called the customer');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ContactChip(
                icon: Icons.email_rounded,
                label: 'Email',
                onTap: () {
                  _launchEmail(email);
                  _logActivity(
                      leadId: leadId,
                      activityType: 'email',
                      action: 'Sent email to customer');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ContactChip(
                icon: Icons.receipt_long_rounded,
                label: 'Quotation',
                onTap: () => _logActivity(
                    leadId: leadId,
                    activityType: 'quotation',
                    action: 'Sent quotation to customer'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(
      String email, String phone, String location, String enquiry) {
    final rows = <_InfoRow>[
      _InfoRow(Icons.email_outlined, 'Email', email),
      _InfoRow(Icons.phone_outlined, 'Phone', phone),
      _InfoRow(Icons.location_on_outlined, 'Location', location),
      if (enquiry.isNotEmpty)
        _InfoRow(Icons.help_outline_rounded, 'Enquiry', enquiry),
    ];

    return _SectionCard(
      icon: Icons.info_outline_rounded,
      title: 'Lead Information',
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final row = e.value;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.c1.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(row.icon,
                      size: 15, color: AppColors.c1.withOpacity(0.70)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.label,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.ctext.withOpacity(0.55),
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(row.value.isEmpty ? '—' : row.value,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.cdark,
                                fontWeight: FontWeight.w600)),
                      ]),
                ),
              ]),
            ),
            if (i < rows.length - 1)
              Divider(
                  height: 1, color: AppColors.c1.withOpacity(0.10), indent: 44),
          ]);
        }).toList(),
      ),
    );
  }

  // ─── Status card ───────────────────────────────────────────────────────────

  Widget _buildStatusCard(int leadId) {
    final List<String> dropdownItems = [..._kKnownStatuses, 'Other'];

    final String currentBadgeLabel = _dropdownValue == 'Other'
        ? (_customReasonCtrl.text.trim().isNotEmpty
            ? _customReasonCtrl.text.trim()
            : _safeString(widget.lead, 'reason').trim().isNotEmpty
                ? _safeString(widget.lead, 'reason').trim()
                : 'Other')
        : _dropdownValue;

    final bool showReason = _dropdownValue == 'Other';
    final bool reasonEditable = _isUserSelectedOther;

    return _SectionCard(
      icon: Icons.flag_outlined,
      title: 'Lead Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Current:',
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.ctext.withOpacity(0.55),
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.c1.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.c1.withOpacity(0.35)),
              ),
              child: Text(
                currentBadgeLabel,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.c1),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _dropdownValue,
            isExpanded: true,
            dropdownColor: AppColors.white,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.c1, size: 20),
            style: const TextStyle(
                fontSize: 14,
                color: AppColors.cdark,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Change Status',
              labelStyle: TextStyle(
                  fontSize: 13, color: AppColors.ctext.withOpacity(0.75)),
              floatingLabelStyle: TextStyle(fontSize: 13, color: AppColors.c1),
              prefixIcon: const Icon(Icons.flag_outlined,
                  size: 18, color: AppColors.c1),
              filled: true,
              fillColor: AppColors.cxl,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.cborder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.c1, width: 1.5),
              ),
            ),
            items: dropdownItems.map((s) {
              final isOther = s == 'Other';
              return DropdownMenuItem<String>(
                value: s,
                child: Text(s,
                    style: TextStyle(
                        color: isOther ? AppColors.c1 : AppColors.cdark,
                        fontSize: 14,
                        fontWeight:
                            isOther ? FontWeight.w600 : FontWeight.w400)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                final wasOther = _dropdownValue == 'Other';
                _dropdownValue = value;

                if (value == 'Other') {
                  _isUserSelectedOther = true;
                  if (!wasOther) _customReasonCtrl.clear();
                } else {
                  _isUserSelectedOther = false;
                  _customReasonCtrl.clear();
                }
              });
            },
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: showReason
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Stack(
                      children: [
                        TextField(
                          controller: _customReasonCtrl,
                          readOnly: !reasonEditable,
                          cursorColor: AppColors.c1,
                          onChanged:
                              reasonEditable ? (_) => setState(() {}) : null,
                          style: TextStyle(
                              fontSize: 14,
                              color: reasonEditable
                                  ? AppColors.cdark
                                  : AppColors.ctext.withOpacity(0.55),
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            labelText: 'Reason',
                            labelStyle: TextStyle(
                                fontSize: 13,
                                color: AppColors.ctext.withOpacity(0.75)),
                            floatingLabelStyle:
                                TextStyle(fontSize: 13, color: AppColors.c1),
                            hintText: reasonEditable
                                ? 'e.g. Internship, Budget issues…'
                                : null,
                            hintStyle: TextStyle(
                                fontSize: 12,
                                color: AppColors.ctext.withOpacity(0.45)),
                            prefixIcon: Icon(
                              reasonEditable
                                  ? Icons.edit_note_rounded
                                  : Icons.lock_outline_rounded,
                              size: 18,
                              color: reasonEditable
                                  ? AppColors.c1
                                  : AppColors.ctext.withOpacity(0.40),
                            ),
                            filled: true,
                            fillColor: reasonEditable
                                ? AppColors.cxl
                                : AppColors.cxl.withOpacity(0.60),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: AppColors.cborder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: reasonEditable
                                    ? AppColors.cborder
                                    : AppColors.cborder.withOpacity(0.50),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: reasonEditable
                                      ? AppColors.c1
                                      : AppColors.cborder.withOpacity(0.50),
                                  width: 1.5),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppColors.cborder.withOpacity(0.50)),
                            ),
                          ),
                        ),
                        if (!reasonEditable)
                          Positioned(
                            top: 8,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.ctext.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Read only',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.ctext.withOpacity(0.45),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _updating ? null : () => _patchStatus(leadId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.c1,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.c1.withOpacity(0.50),
                elevation: 0,
                shadowColor: AppColors.c1.withOpacity(0.30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23)),
              ),
              child: _updating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded,
                            color: AppColors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Update Status',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick actions card ────────────────────────────────────────────────────

  Widget _buildQuickActionsCard(int leadId, String leadName) {
    return _SectionCard(
      icon: Icons.flash_on_rounded,
      title: 'Quick Actions',
      child: Column(children: [
        Row(children: [
          Expanded(
            child: _QuickActionBtn(
              icon: Icons.calendar_today_rounded,
              label: 'Schedule Meeting',
              onTap: _showScheduleMeetingSheet,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionBtn(
              icon: Icons.alarm_rounded,
              label: 'Set Reminder',
              onTap: _showSetReminderSheet,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _QuickActionBtn(
              icon: Icons.video_call_rounded,
              label: 'View Meetings',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MeetingsListScreen(
                          leadId: leadId, leadName: leadName))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickActionBtn(
              icon: Icons.notifications_outlined,
              label: 'View Reminders',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RemindersListScreen(
                          leadId: leadId, leadName: leadName))),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Divider(height: 1, color: AppColors.c1.withOpacity(0.12)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Follow-ups',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cdark)),
            GestureDetector(
              onTap: () => _showScheduleFollowupSheet(leadId: leadId),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.c1.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.c1.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, color: AppColors.c1, size: 14),
                  const SizedBox(width: 4),
                  Text('Schedule',
                      style: TextStyle(
                          color: AppColors.c1,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FollowupsListScreen(
                        leadId: leadId, leadName: leadName))),
            style: OutlinedButton.styleFrom(
              side:
                  BorderSide(color: AppColors.c1.withOpacity(0.30), width: 1.5),
              foregroundColor: AppColors.c1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21)),
            ),
            icon: Icon(Icons.list_alt_rounded, color: AppColors.c1, size: 16),
            label: Text('View All Follow-ups',
                style: TextStyle(
                    color: AppColors.c1,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  // ─── Notes card ────────────────────────────────────────────────────────────

  Widget _buildNotesCard(String projectReq, String notes) {
    return _SectionCard(
      icon: Icons.notes_rounded,
      title: 'Notes & Requirements',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (projectReq.isNotEmpty) ...[
          Text('Project Requirements',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ctext.withOpacity(0.55),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.c1.withOpacity(0.12)),
            ),
            child: Text(projectReq,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.cdark, height: 1.5)),
          ),
        ],
        if (projectReq.isNotEmpty && notes.isNotEmpty)
          const SizedBox(height: 12),
        if (notes.isNotEmpty) ...[
          Text('Additional Notes',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ctext.withOpacity(0.55),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cxl,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.c1.withOpacity(0.12)),
            ),
            child: Text(notes,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.cdark, height: 1.5)),
          ),
        ],
      ]),
    );
  }
}

// ─── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.c1.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: AppColors.c1.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.c1,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.c1, size: 16),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cdark)),
        ]),
        Divider(
            height: 18, thickness: 1, color: AppColors.c1.withOpacity(0.10)),
        child,
      ]),
    );
  }
}

// ─── Contact chip ──────────────────────────────────────────────────────────────

class _ContactChip extends StatefulWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final VoidCallback onTap;
  const _ContactChip(
      {this.icon, this.svgIcon, required this.label, required this.onTap})
      : assert(icon != null || svgIcon != null);

  @override
  State<_ContactChip> createState() => _ContactChipState();
}

class _ContactChipState extends State<_ContactChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90),
        lowerBound: 0,
        upperBound: 1);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.c1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.c1.withOpacity(0.30), width: 1),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (widget.svgIcon != null)
                SvgPicture.string(widget.svgIcon!,
                    width: 18,
                    height: 18,
                    colorFilter:
                        const ColorFilter.mode(AppColors.c1, BlendMode.srcIn))
              else
                Icon(widget.icon, color: AppColors.c1, size: 18),
              const SizedBox(height: 4),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.c1)),
            ]),
          ),
        ),
      );
}

// ─── Quick action button ───────────────────────────────────────────────────────

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.c1.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.c1.withOpacity(0.18)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: AppColors.c1, size: 20),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.c1)),
          ]),
        ),
      );
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);
}
