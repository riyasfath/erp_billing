import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/viewmodels/access_viewmodel.dart';
import 'package:pokakbilling/viewmodels/admin/lead_viewmodelAdmin.dart';
import 'package:pokakbilling/viewmodels/course_viewmodel.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/create_lead.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/followupListScreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomBar.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/follow_up_sheet.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/meeting_sheet.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/leads_bottomsheets/reminder_sheet.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/meetingsListScreen.dart';
import 'package:pokakbilling/views/Screens/leads/lead_screens/remindersListScreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Colour scheme (same as Academy dashboard / ERP home)
// ═════════════════════════════════════════════════════════════════════════════
const Color _kPageBg = Color(0xFFF0FAFD);
const Color _kInk = Color(0xFF0F172A);
const Color _kSlate = Color(0xFF64748B);
const Color _kLine = Color(0xFFD9ECF2);

const Color _kCyan = Color(0xFF06B6D4);
const Color _kCyanLight = Color(0xFF67E8F9);
const Color _kCyanDeep = Color(0xFF0E7490);
const Color _kBlue = Color(0xFF3B82F6);
const Color _kOrange = Color(0xFFF97316);
const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreen = Color(0xFF16A34A);
const Color _kPink = Color(0xFFEC4899);
const Color _kAmber = Color(0xFFF59E0B);
const Color _kRed = Color(0xFFEF4444);
const Color _kWhatsApp = Color(0xFF25D366);

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

const List<Color> _kAvatarColors = [
  _kCyan, _kViolet, _kPink, _kGreen, _kAmber, _kBlue, _kOrange
];

Color _statusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('convert') || s.contains('won')) return _kGreen;
  if (s.contains('lost') || s.contains('closed') || s.contains('reject')) {
    return _kRed;
  }
  if (s.contains('other')) return _kSlate;
  if (s.contains('qualif')) return _kViolet;
  if (s.contains('contact')) return _kBlue;
  if (s.contains('follow') || s.contains('pending')) return _kOrange;
  if (s.contains('new')) return _kCyan;
  return _kAmber;
}

// ── WhatsApp SVG ──────────────────────────────────────────────────────────────
const String _kWhatsAppSvg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
  <path d="M12 0C5.373 0 0 5.373 0 12c0 2.125.558 4.122 1.528 5.855L.057 23.885a.5.5 0 00.611.611l6.101-1.459A11.945 11.945 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.012-1.378l-.36-.214-3.724.89.908-3.64-.235-.374A9.818 9.818 0 0112 2.182c5.428 0 9.818 4.39 9.818 9.818 0 5.429-4.39 9.818-9.818 9.818z"/>
</svg>
''';

// ─────────────────────────────────────────────────────────────────────────────
class LeadsViewScreen extends StatefulWidget {
  final dynamic lead;
  const LeadsViewScreen({super.key, required this.lead});

  @override
  State<LeadsViewScreen> createState() => _LeadsViewScreenState();
}

class _LeadsViewScreenState extends State<LeadsViewScreen> {
  late String _selectedStatusLabel;
  late String _savedStatusLabel;
  bool _updating = false;

  // ── Status notes: lost → reason_note, other → other_note ──────────────────
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _otherCtrl = TextEditingController();
  String? _noteErr;

  bool _isLostLabel(String s) => s.trim().toLowerCase() == 'lost';
  bool _isOtherLabel(String s) => s.trim().toLowerCase() == 'other';

  @override
  void initState() {
    super.initState();

    final label = _safeString(widget.lead, 'lead_status_display').isNotEmpty
        ? _safeString(widget.lead, 'lead_status_display')
        : _safeString(widget.lead, 'leadStatusDisplay');
    _selectedStatusLabel = label.isNotEmpty ? label : 'New';
    _savedStatusLabel = _selectedStatusLabel;

    // Pre-fill existing notes
    _reasonCtrl.text = _safeString(widget.lead, 'reason_note');
    _otherCtrl.text = _safeString(widget.lead, 'other_note');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final locationVm = Provider.of<LocationViewmodel>(context, listen: false);
      if (locationVm.locations.isEmpty) {
        locationVm.fetchLocations().then((_) {
          if (mounted) setState(() {});
        });
      }
      final sourceVm = Provider.of<SourceViewmodel>(context, listen: false);
      if (sourceVm.sources.isEmpty) {
        sourceVm.fetchSources().then((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  // ── Safe accessors (ERP LeadModel fields) ─────────────────────────────────
  bool _isLeadModel(dynamic obj) => obj is LeadModel;
  bool _isMap(dynamic obj) => obj is Map<String, dynamic>;

  dynamic _safeGet(dynamic obj, String fieldSnake, {String? fieldCamel}) {
    if (obj == null) return null;
    if (_isLeadModel(obj)) {
      final LeadModel lm = obj as LeadModel;
      switch (fieldSnake) {
        case 'id':
        case 'leadId':
          return lm.leadId;
        case 'lead_status_display':
        case 'leadStatusDisplay':
          return lm.leadStatusDisplay;
        case 'salesperson_first_name':
          return lm.salespersonFirstName;
        case 'salesperson_last_name':
          return lm.salespersonLastName;
        case 'lead_type':
          return lm.leadType;
        case 'name':
          return lm.name;
        case 'email':
        case 'emailId':
          return lm.emailId;
        case 'phone':
          return lm.phone;
        case 'enquiry':
          return lm.enquiry;
        case 'project_requirement':
          return lm.projectRequirement;
        case 'company':
          return lm.company;
        case 'address':
          return lm.address;
        case 'lead_number':
          return lm.leadNumber;
        case 'lead_status':
          return lm.leadStatus;
        case 'notes':
          return lm.notes;
        case 'created_at':
          return lm.createdAt;
        case 'date':
          return lm.date.isNotEmpty ? lm.date : lm.createdAt;
        case 'CustomUser':
        case 'customUser':
          return lm.customUser;
        case 'location':
          return lm.location;
        case 'lead_source':
          return lm.leadSource;
        case 'salesperson':
          return lm.salesperson;
        case 'course':
          return lm.course;
        case 'lead_category':
          return lm.leadCategory;
        case 'reason_note': // ← NEW
          return lm.reasonNote;
        case 'other_note': // ← NEW
          return lm.otherNote;
        default:
          return null;
      }
    }
    if (_isMap(obj)) {
      final m = obj as Map<String, dynamic>;
      if (m.containsKey(fieldSnake)) return m[fieldSnake];
      if (fieldCamel != null && m.containsKey(fieldCamel)) return m[fieldCamel];
      if (m.containsKey('id') && (fieldSnake == 'leadId' || fieldSnake == 'id')) {
        return m['id'];
      }
      if (m.containsKey('lead_status_display') &&
          (fieldSnake == 'leadStatusDisplay' ||
              fieldSnake == 'lead_status_display')) {
        return m['lead_status_display'];
      }
      if (m.containsKey('email') &&
          (fieldSnake == 'email' || fieldSnake == 'emailId')) {
        return m['email'];
      }
      if (m.containsKey('created_at') &&
          (fieldSnake == 'created_at' || fieldSnake == 'date')) {
        return m['created_at'];
      }
      return m[fieldSnake] ?? m[fieldCamel];
    }
    return null;
  }

  String _safeString(dynamic obj, String field) {
    final val = _safeGet(obj, field, fieldCamel: _snakeToCamel(field));
    return val?.toString() ?? '';
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
    return parts[0] +
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

  String _formatLeadType(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  void _toast(String msg, {Color color = _kCyanDeep, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon ?? Icons.check_circle_rounded,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  // ── Navigation / Sheets ───────────────────────────────────────────────────
  Future<void> _openEditScreen(bool isAdmin) async {
    LeadModel? leadModel;
    if (widget.lead is LeadModel) {
      leadModel = widget.lead as LeadModel;
    } else if (widget.lead is Map<String, dynamic>) {
      try {
        leadModel = LeadModel.fromJson(widget.lead as Map<String, dynamic>);
      } catch (_) {}
    }
    if (leadModel == null) return;

    final result = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateLead(isEdit: true, lead: leadModel),
      ),
    );

    if (result == true && mounted) {
      final accessVm = Provider.of<AccessViewModel>(context, listen: false);
      if (accessVm.isAdmin) {
        Provider.of<AdminLeadViewmodel>(context, listen: false).getAllLeads();
      } else {
        Provider.of<LeadViewmodel>(context, listen: false).getAllLeads();
      }
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _showScheduleFollowupSheet({int? leadId}) async {
    final int resolvedLeadId = leadId ??
        _safeInt(widget.lead, 'id') ??
        _safeInt(widget.lead, 'leadId') ??
        0;
    if (resolvedLeadId == 0) {
      _toast('Unable to determine lead for follow-up',
          color: _kRed, icon: Icons.error_outline_rounded);
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
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MeetingSheet(
          leadName: _safeString(widget.lead, 'name'),
          leadId: _safeInt(widget.lead, 'id') ?? 0),
    );
    if (res == true && mounted) _toast('Meeting scheduled');
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
    if (res == true && mounted) _toast('Reminder scheduled');
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email.trim());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final accessVm = Provider.of<AccessViewModel>(context);
    final isAdmin = accessVm.isAdmin;

    LeadViewmodel? staffVm;
    AdminLeadViewmodel? adminVm;
    List<String> statusOptions;

    if (isAdmin) {
      adminVm = Provider.of<AdminLeadViewmodel>(context, listen: false);
      statusOptions = adminVm.leadStatusList;
    } else {
      try {
        staffVm = Provider.of<LeadViewmodel>(context, listen: false);
      } catch (_) {}
      statusOptions = staffVm?.leadStatusList ??
          ['New', 'Contacted', 'Qualified', 'Converted'];
    }

    final sourceVm = Provider.of<SourceViewmodel>(context);
    final locationVm = Provider.of<LocationViewmodel>(context);
    final salesPersonVm = Provider.of<SalesPersonViewmodel>(context);
    final courseVm = Provider.of<CourseViewmodel?>(context);

    final Map<int, String> sourceMap = {
      for (var s in sourceVm.sources) s.id: s.name
    };
    final Map<int, String> locationMap = {
      for (var l in locationVm.locations) l.id: l.name
    };
    final Map<int, String> salespersonMap = {
      for (var sp in salesPersonVm.salesPersonList)
        sp.salesPersonId: sp.fullName
    };
    final Map<int, String> courseMap = {
      if (courseVm != null)
        for (var c in courseVm.courses) c.id: c.title
    };

    final int leadId =
        _safeInt(widget.lead, 'id') ?? _safeInt(widget.lead, 'leadId') ?? 0;
    final String leadName = _safeString(widget.lead, 'name');
    final String phone = _safeString(widget.lead, 'phone');
    final String email = _safeString(widget.lead, 'email').isNotEmpty
        ? _safeString(widget.lead, 'email')
        : _safeString(widget.lead, 'emailId');
    final int? leadSourceId = _safeInt(widget.lead, 'lead_source');
    final String leadSourceDisplay = leadSourceId != null
        ? (sourceMap[leadSourceId] ?? leadSourceId.toString())
        : _safeString(widget.lead, 'lead_source');
    final int? locationId = _safeInt(widget.lead, 'location');
    final String locationDisplay = locationId != null
        ? (locationMap[locationId] ??
            (locationVm.locations.isEmpty
                ? 'Loading...'
                : locationId.toString()))
        : (_safeString(widget.lead, 'address').isNotEmpty
            ? _safeString(widget.lead, 'address')
            : '');

    final int? courseId = _safeInt(widget.lead, 'course');
    final String courseDisplay = courseId != null
        ? (courseMap[courseId] ??
            (courseMap.isEmpty ? 'Loading...' : courseId.toString()))
        : '';

    final String leadType = _safeString(widget.lead, 'lead_type');
    final String leadNumber = _safeString(widget.lead, 'lead_number');
    final String leadCategory = _safeString(widget.lead, 'lead_category');
    final int? currentSpId = _safeInt(widget.lead, 'salesperson');
    final String spFirstName =
        _safeString(widget.lead, 'salesperson_first_name');
    final String spLastName = _safeString(widget.lead, 'salesperson_last_name');
    final String currentSpName =
        currentSpId != null && salespersonMap.containsKey(currentSpId)
            ? salespersonMap[currentSpId]!
            : '$spFirstName $spLastName'.trim();
    final String company = _safeString(widget.lead, 'company');
    final String enquiry = _safeString(widget.lead, 'enquiry');
    final String projectReq = _safeString(widget.lead, 'project_requirement');
    final String notes = _safeString(widget.lead, 'notes');
    final String dateRaw = _safeString(widget.lead, 'date').isNotEmpty
        ? _safeString(widget.lead, 'date')
        : _safeString(widget.lead, 'created_at');
    final String createdAt = _formatDate(dateRaw);
    final String initials =
        leadName.isNotEmpty ? leadName[0].toUpperCase() : 'L';

    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _kPageBg,
      bottomNavigationBar: const LeadsBottomBar(index: 2),
      body: Column(
        children: [
          _buildHeader(
            context: context,
            leadName: leadName,
            company: company,
            source: leadSourceDisplay,
            course: courseDisplay,
            leadNumber: leadNumber,
            initials: initials,
            createdAt: createdAt,
            phone: phone,
            email: email,
            isAdmin: isAdmin,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(sw * .04, 20, sw * .04, 32),
              children: [
                if (isAdmin)
                  _FadeIn(
                    index: 0,
                    child: _buildAdminCard(
                      leadType: leadType,
                      leadCategory: leadCategory,
                      currentSpName: currentSpName,
                      currentSpId: currentSpId,
                      leadId: leadId,
                      salespersonMap: salespersonMap,
                      adminVm: adminVm!,
                      salesPersonVm: salesPersonVm,
                    ),
                  ),
                _FadeIn(
                  index: 1,
                  child: _buildInfoCard(
                    email: email,
                    phone: phone,
                    location: locationDisplay,
                    course: courseDisplay,
                    enquiry: enquiry,
                    leadNumber: leadNumber,
                  ),
                ),
                _FadeIn(
                  index: 2,
                  child: _buildStatusCard(
                    staffVm: staffVm,
                    adminVm: adminVm,
                    statusOptions: statusOptions,
                    isAdmin: isAdmin,
                  ),
                ),
                _FadeIn(
                  index: 3,
                  child: _buildQuickActionsCard(leadId, leadName),
                ),
                if (projectReq.isNotEmpty || notes.isNotEmpty)
                  _FadeIn(
                    index: 4,
                    child: _buildNotesCard(projectReq, notes),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader({
    required BuildContext context,
    required String leadName,
    required String company,
    required String source,
    required String course,
    required String leadNumber,
    required String initials,
    required String createdAt,
    required String phone,
    required String email,
    required bool isAdmin,
  }) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sColor = _statusColor(_savedStatusLabel);
    final aColor = leadName.isEmpty
        ? _kCyan
        : _kAvatarColors[leadName.codeUnits.fold<int>(0, (a, b) => a + b) %
            _kAvatarColors.length];

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: _kHeaderGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(children: [
        Positioned(
          right: -34,
          top: -44,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -26,
          bottom: -34,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              top: mq.padding.top + 10,
              bottom: 20,
              left: sw * .045,
              right: sw * .045),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(children: [
                _Pressable(
                  onTap: () => Navigator.pop(context),
                  child: const _GlassCircle(
                      icon: Icons.arrow_back_ios_new_rounded, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Flexible(
                          child: Text('Lead Details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900)),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('ADMIN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 2),
                      Text('Created $createdAt',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _Pressable(
                  onTap: () => _openEditScreen(isAdmin),
                  child: const _GlassCircle(icon: Icons.edit_rounded, size: 19),
                ),
              ]),
              const SizedBox(height: 18),

              // Profile glass card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.30)),
                ),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kCyanDeep.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(initials,
                            style: TextStyle(
                                color: aColor,
                                fontSize: 26,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(leadName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900)),
                          if (company.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(company,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13.5)),
                          ],
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    color: sColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 140),
                                child: Text(_savedStatusLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: _shade(sColor, 0.1),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  if (source.isNotEmpty ||
                      course.isNotEmpty ||
                      leadNumber.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (leadNumber.isNotEmpty)
                          _GlassTag(icon: Icons.tag_rounded, text: leadNumber),
                        if (source.isNotEmpty)
                          _GlassTag(
                              icon: Icons.alt_route_rounded, text: source),
                        if (course.isNotEmpty)
                          _GlassTag(
                              icon: Icons.menu_book_rounded, text: course),
                      ],
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 14),

              // Contact buttons
              Row(children: [
                Expanded(
                  child: _ContactButton(
                    svgIcon: _kWhatsAppSvg,
                    label: 'WhatsApp',
                    color: _kWhatsApp,
                    onTap: () => _launchWhatsApp(phone),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.call_rounded,
                    label: 'Call',
                    color: _kCyanDeep,
                    onTap: () => _launchCall(phone),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    color: _kViolet,
                    onTap: () => _launchEmail(email),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  // ── ADMIN CARD ────────────────────────────────────────────────────────────
  Widget _buildAdminCard({
    required String leadType,
    required String leadCategory,
    required String currentSpName,
    required int? currentSpId,
    required int leadId,
    required Map<int, String> salespersonMap,
    required AdminLeadViewmodel adminVm,
    required SalesPersonViewmodel salesPersonVm,
  }) {
    return _SectionCard(
      icon: Icons.admin_panel_settings_rounded,
      title: 'Admin Controls',
      subtitle: 'Assignment & lead management',
      color: _kRed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: _miniTile(
                icon: Icons.category_rounded,
                label: 'Lead Type',
                value: _formatLeadType(
                    leadType.isNotEmpty ? leadType : leadCategory),
                color: _kPink,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _miniTile(
                icon: Icons.label_rounded,
                label: 'Category',
                value: leadCategory.isNotEmpty
                    ? _formatLeadType(leadCategory)
                    : '—',
                color: _kAmber,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPageBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kLine),
            ),
            child: Row(children: [
              const _GradientTile(
                  icon: Icons.support_agent_rounded, color: _kCyan, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assigned Salesperson',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: _kSlate,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 1),
                    Text(
                      currentSpName.isNotEmpty ? currentSpName : 'Unassigned',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14.5,
                          color: currentSpName.isNotEmpty ? _kInk : _kRed,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              _Pressable(
                onTap: () => _showReassignSheet(
                  context: context,
                  leadId: leadId,
                  currentSpId: currentSpId,
                  adminVm: adminVm,
                  salesPersonVm: salesPersonVm,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(colors: [_kCyanDeep, _kCyan]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _kCyan.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.swap_horiz_rounded,
                        color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text('Reassign',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          _Pressable(
            onTap: () => _showDeleteConfirmDialog(context, leadId),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kRed.withValues(alpha: 0.30)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_forever_rounded, color: _kRed, size: 18),
                  SizedBox(width: 7),
                  Text('Delete This Lead',
                      style: TextStyle(
                          color: _kRed,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: _shade(color, 0.1),
                        fontWeight: FontWeight.w700)),
                Text(value.isEmpty ? '—' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5,
                        color: _kInk,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ]),
      );

  void _showReassignSheet({
    required BuildContext context,
    required int leadId,
    required int? currentSpId,
    required AdminLeadViewmodel adminVm,
    required SalesPersonViewmodel salesPersonVm,
  }) {
    int? tempSelected = currentSpId;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: _kLine, borderRadius: BorderRadius.circular(3)),
                  ),
                  const Row(children: [
                    _GradientTile(
                        icon: Icons.swap_horiz_rounded,
                        color: _kCyan,
                        size: 42),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reassign Salesperson',
                              style: TextStyle(
                                  color: _kInk,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17)),
                          Text('Pick who should own this lead',
                              style:
                                  TextStyle(color: _kSlate, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: salesPersonVm.salesPersonList.length,
                      itemBuilder: (_, i) {
                        final sp = salesPersonVm.salesPersonList[i];
                        final isSelected = tempSelected == sp.salesPersonId;
                        final c = _kAvatarColors[i % _kAvatarColors.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _Pressable(
                            onTap: () => setSheetState(
                                () => tempSelected = sp.salesPersonId),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kCyan.withValues(alpha: 0.08)
                                    : _kPageBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: isSelected ? _kCyan : _kLine,
                                    width: isSelected ? 1.5 : 1),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [_tint(c, 0.22), c],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      sp.firstName.isNotEmpty
                                          ? sp.firstName[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(sp.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isSelected
                                              ? _kCyanDeep
                                              : _kInk,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          fontSize: 14.5)),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [_kCyanDeep, _kCyan]),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded,
                                        color: Colors.white, size: 15),
                                  ),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _Pressable(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kLine, width: 1.5),
                          ),
                          child: const Center(
                            child: Text('Cancel',
                                style: TextStyle(
                                    color: _kSlate,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Pressable(
                        onTap: tempSelected == null
                            ? () {}
                            : () {
                                Navigator.pop(ctx);
                                adminVm.assignSalesperson(
                                  leadId: leadId,
                                  salespersonId: tempSelected!,
                                  context: context,
                                );
                              },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: tempSelected != null
                                ? _kHeaderGradient
                                : null,
                            color: tempSelected != null ? null : _kPageBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: tempSelected != null
                                ? [
                                    BoxShadow(
                                      color: _kCyan.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Center(
                            child: Text('Assign',
                                style: TextStyle(
                                    color: tempSelected != null
                                        ? Colors.white
                                        : _kSlate,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5)),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int leadId) {
    final leadName = _safeString(widget.lead, 'name');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_tint(_kRed, 0.25), _kRed],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _kRed.withValues(alpha: 0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.delete_forever_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          const Text('Delete Lead',
              style: TextStyle(
                  color: _kInk, fontWeight: FontWeight.w900, fontSize: 19)),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style:
                  const TextStyle(color: _kSlate, fontSize: 13.5, height: 1.5),
              children: [
                const TextSpan(text: 'Permanently delete '),
                TextSpan(
                    text: leadName,
                    style: const TextStyle(
                        color: _kInk, fontWeight: FontWeight.w800)),
                const TextSpan(text: '? This cannot be undone.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
              child: _Pressable(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kLine, width: 1.5),
                  ),
                  child: const Center(
                    child: Text('Cancel',
                        style: TextStyle(
                            color: _kSlate,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Pressable(
                onTap: () {
                  Navigator.pop(ctx);
                  final adminVm =
                      Provider.of<AdminLeadViewmodel>(context, listen: false);
                  adminVm.deleteLead(leadId, context);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [_tint(_kRed, 0.15), _kRed]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kRed.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Delete',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14)),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  // ── INFO CARD ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required String email,
    required String phone,
    required String location,
    required String course,
    required String enquiry,
    required String leadNumber,
  }) {
    final rows = <_InfoRow>[
      _InfoRow(Icons.phone_rounded, 'Phone', phone, _kCyan),
      _InfoRow(Icons.email_rounded, 'Email', email, _kViolet),
      if (location.isNotEmpty)
        _InfoRow(Icons.place_rounded, 'Location', location, _kPink),
      if (course.isNotEmpty)
        _InfoRow(Icons.menu_book_rounded, 'Assigned Course', course, _kGreen),
      if (enquiry.isNotEmpty)
        _InfoRow(Icons.help_rounded, 'Enquiry', enquiry, _kAmber),
      if (leadNumber.isNotEmpty)
        _InfoRow(Icons.tag_rounded, 'Lead Number', leadNumber, _kBlue),
    ];

    return _SectionCard(
      icon: Icons.person_rounded,
      title: 'Lead Information',
      subtitle: 'Contact & enquiry details',
      color: _kCyan,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: rows[i].color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(rows[i].icon,
                      size: 18, color: _shade(rows[i].color, 0.05)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].label,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: _kSlate,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(rows[i].value.isEmpty ? '—' : rows[i].value,
                            style: const TextStyle(
                                fontSize: 14.5,
                                color: _kInk,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ]),
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, color: _kLine, indent: 50),
          ],
        ],
      ),
    );
  }

  // ── Status note field (same look as the rest of the app's inputs) ─────────
  Widget _noteField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    final hasError = _noteErr != null;
    final accent = hasError ? _kRed : color;

    OutlineInputBorder border(Color c, {double w = 1}) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          cursorColor: _kCyan,
          minLines: 1,
          maxLines: 3,
          textAlignVertical: TextAlignVertical.center,
          onChanged: (_) {
            if (_noteErr != null) setState(() => _noteErr = null);
          },
          style: const TextStyle(
              fontSize: 14.5, color: _kInk, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: hasError ? _kRed : _kSlate),
            floatingLabelStyle: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: hasError ? _kRed : _shade(color, 0.15)),
            hintText: hint,
            hintStyle: TextStyle(
                fontSize: 13, color: _kSlate.withValues(alpha: 0.55)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 8),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: _shade(accent, 0.1)),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 30),
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.circle, size: 7, color: _kRed),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            filled: true,
            fillColor: hasError ? _kRed.withValues(alpha: 0.04) : _kPageBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: border(hasError ? _kRed.withValues(alpha: 0.6) : _kLine),
            enabledBorder:
                border(hasError ? _kRed.withValues(alpha: 0.6) : _kLine),
            focusedBorder: border(hasError ? _kRed : color, w: 1.6),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: _kRed),
              const SizedBox(width: 4),
              Flexible(
                child: Text(_noteErr!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kRed)),
              ),
            ]),
          ),
      ],
    );
  }

  // ── Status update (sends reason_note / other_note when needed) ────────────
  Future<void> _submitStatus({
    required LeadViewmodel? staffVm,
    required AdminLeadViewmodel? adminVm,
    required bool isAdmin,
  }) async {
    final isLost = _isLostLabel(_selectedStatusLabel);
    final isOther = _isOtherLabel(_selectedStatusLabel);
    final note = isLost
        ? _reasonCtrl.text.trim()
        : (isOther ? _otherCtrl.text.trim() : '');

    if ((isLost || isOther) && note.isEmpty) {
      setState(() => _noteErr =
          isLost ? 'Reason note is required' : 'Other note is required');
      return;
    }

    setState(() => _updating = true);
    try {
      final lid =
          _safeInt(widget.lead, 'id') ?? _safeInt(widget.lead, 'leadId') ?? 0;

      if (isAdmin && adminVm != null) {
        // NOTE: the admin view model / service still need reason_note and
        // other_note support (send me lead_viewmodelAdmin.dart to add it).
        adminVm.selectLeadStatus(_selectedStatusLabel);
        await adminVm.editLead(
          leadId: lid,
          name: _safeString(widget.lead, 'name'),
          company: _safeString(widget.lead, 'company'),
          email: _safeString(widget.lead, 'email').isNotEmpty
              ? _safeString(widget.lead, 'email')
              : _safeString(widget.lead, 'emailId'),
          phone: _safeString(widget.lead, 'phone'),
          notes: _safeString(widget.lead, 'notes'),
          leadStatus: adminVm.selectedLeadStatusKey,
          leadSource: _safeInt(widget.lead, 'lead_source'),
          enquiry: _safeString(widget.lead, 'enquiry'),
          location: _safeInt(widget.lead, 'location'),
          salesperson: _safeInt(widget.lead, 'salesperson'),
          context: context,
        );
      } else if (staffVm != null) {
        staffVm.selectLeadStatus(_selectedStatusLabel);
        await staffVm.editLead(
          lid,
          _safeString(widget.lead, 'name'),
          _safeString(widget.lead, 'company'),
          _safeString(widget.lead, 'email').isNotEmpty
              ? _safeString(widget.lead, 'email')
              : _safeString(widget.lead, 'emailId'),
          _safeString(widget.lead, 'phone'),
          _safeString(widget.lead, 'notes'),
          staffVm.selectedLeadStatusKey,
          _safeInt(widget.lead, 'lead_source'),
          _safeString(widget.lead, 'enquiry'),
          context,
          location: _safeInt(widget.lead, 'location'),
          course: _safeInt(widget.lead, 'course'),
          reasonNote: isLost ? note : null,
          otherNote: isOther ? note : null,
        );
      }
      if (mounted) {
        setState(() => _savedStatusLabel = _selectedStatusLabel);
        _toast('Status updated to "$_selectedStatusLabel"');
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  // ── STATUS CARD ───────────────────────────────────────────────────────────
  Widget _buildStatusCard({
    required LeadViewmodel? staffVm,
    required AdminLeadViewmodel? adminVm,
    required List<String> statusOptions,
    required bool isAdmin,
  }) {
    final changed = _selectedStatusLabel != _savedStatusLabel;
    final isLost = _isLostLabel(_selectedStatusLabel);
    final isOther = _isOtherLabel(_selectedStatusLabel);
    final needsNote = isLost || isOther;

    return _SectionCard(
      icon: Icons.flag_rounded,
      title: 'Lead Status',
      subtitle: 'Tap a status, then update',
      color: _kViolet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusOptions.map((s) {
              final selected = s == _selectedStatusLabel;
              final c = _statusColor(s);
              return _Pressable(
                onTap: () => setState(() {
                  _selectedStatusLabel = s;
                  _noteErr = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? LinearGradient(colors: [_tint(c, 0.15), c])
                        : null,
                    color: selected ? null : c.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : c.withValues(alpha: 0.25)),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: c.withValues(alpha: 0.32),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : const [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 14,
                        color: selected ? Colors.white : c),
                    const SizedBox(width: 5),
                    Text(s,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : _shade(c, 0.1))),
                  ]),
                ),
              );
            }).toList(),
          ),

          // ── Lost → Reason Note  /  Other → Other Note ──────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: needsNote
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: isLost
                        ? _noteField(
                            controller: _reasonCtrl,
                            label: 'Reason Note',
                            hint: 'Why was this lead lost?',
                            icon: Icons.sentiment_dissatisfied_rounded,
                            color: _kRed,
                          )
                        : _noteField(
                            controller: _otherCtrl,
                            label: 'Other Note',
                            hint: 'Enter additional details...',
                            icon: Icons.edit_note_rounded,
                            color: _kSlate,
                          ),
                  )
                : const SizedBox(width: double.infinity),
          ),

          const SizedBox(height: 16),
          _Pressable(
            onTap: (_updating || !(changed || needsNote))
                ? () {}
                : () => _submitStatus(
                    staffVm: staffVm, adminVm: adminVm, isAdmin: isAdmin),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: ((changed || needsNote) || _updating) ? 1 : 0.5,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_tint(_kViolet, 0.15), _kViolet],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: (changed || needsNote)
                      ? [
                          BoxShadow(
                            color: _kViolet.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : const [],
                ),
                child: Center(
                  child: _updating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                                changed
                                    ? 'Update to "$_selectedStatusLabel"'
                                    : 'Update Status',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900)),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS CARD ────────────────────────────────────────────────────
  Widget _buildQuickActionsCard(int leadId, String leadName) {
    return _SectionCard(
      icon: Icons.bolt_rounded,
      title: 'Quick Actions',
      subtitle: 'Meetings, reminders & follow-ups',
      color: _kOrange,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.video_camera_front_rounded,
              label: 'Schedule\nMeeting',
              color: _kBlue,
              onTap: _showScheduleMeetingSheet,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionTile(
              icon: Icons.alarm_add_rounded,
              label: 'Set\nReminder',
              color: _kAmber,
              onTap: _showSetReminderSheet,
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: _ActionTile(
              icon: Icons.event_note_rounded,
              label: 'View\nMeetings',
              color: _kViolet,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MeetingsListScreen(
                          leadId: leadId, leadName: leadName))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionTile(
              icon: Icons.notifications_active_rounded,
              label: 'View\nReminders',
              color: _kPink,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RemindersListScreen(
                          leadId: leadId, leadName: leadName))),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _kOrange.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kOrange.withValues(alpha: 0.22)),
          ),
          child: Column(children: [
            Row(children: [
              const _GradientTile(
                  icon: Icons.event_repeat_rounded, color: _kOrange, size: 38),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Follow-ups',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kInk)),
              ),
              _Pressable(
                onTap: () => _showScheduleFollowupSheet(leadId: leadId),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_tint(_kOrange, 0.15), _kOrange]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _kOrange.withValues(alpha: 0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 3),
                    Text('Schedule',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            _Pressable(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => FollowupsListScreen(
                          leadId: leadId, leadName: leadName))),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kOrange.withValues(alpha: 0.30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt_rounded,
                        color: _shade(_kOrange, 0.1), size: 17),
                    const SizedBox(width: 6),
                    Text('View All Follow-ups',
                        style: TextStyle(
                            color: _shade(_kOrange, 0.1),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── NOTES CARD ────────────────────────────────────────────────────────────
  Widget _buildNotesCard(String projectReq, String notes) {
    Widget block(String label, String text, IconData icon) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 15, color: _kGreen),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: _kSlate,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kGreen.withValues(alpha: 0.18)),
              ),
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, color: _kInk, height: 1.55)),
            ),
          ],
        );

    return _SectionCard(
      icon: Icons.sticky_note_2_rounded,
      title: 'Notes & Requirements',
      subtitle: 'What this lead needs',
      color: _kGreen,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (projectReq.isNotEmpty)
          block('Project Requirements', projectReq, Icons.checklist_rounded),
        if (projectReq.isNotEmpty && notes.isNotEmpty)
          const SizedBox(height: 14),
        if (notes.isNotEmpty) block('Notes', notes, Icons.notes_rounded),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section card (Academy style: gradient top bar + gradient icon tile)
// ═════════════════════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget child;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kLine),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_tint(color, 0.25), color]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              _GradientTile(icon: icon, color: color, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _kInk)),
                      const SizedBox(height: 1),
                      Text(subtitle,
                          style:
                              const TextStyle(fontSize: 12.5, color: _kSlate)),
                    ]),
              ),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 26, color: _kLine),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ]),
      ),
    );
  }
}

// ─── Header glass tag ─────────────────────────────────────────────────────────
class _GlassTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _GlassTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.55),
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ]),
      );
}

// ─── Contact button (white on gradient header) ────────────────────────────────
class _ContactButton extends StatelessWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ContactButton({
    this.icon,
    this.svgIcon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : assert(icon != null || svgIcon != null);

  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kCyanDeep.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: svgIcon != null
                    ? SvgPicture.string(svgIcon!,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn))
                    : Icon(icon, color: color, size: 18),
              ),
            ),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _shade(color, 0.1))),
          ]),
        ),
      );
}

// ─── Quick action tile ────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.22)),
          ),
          child: Row(children: [
            _GradientTile(icon: icon, color: color, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                      color: _shade(color, 0.2))),
            ),
          ]),
        ),
      );
}

// ─── Small shared widgets ─────────────────────────────────────────────────────
class _GradientTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _GradientTile(
      {required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_tint(color, 0.22), color],
          ),
          borderRadius: BorderRadius.circular(size * 0.32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      );
}

class _GlassCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  const _GlassCircle({required this.icon, this.size = 20});

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      );
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final int index;
  const _FadeIn({required this.child, required this.index});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 + widget.index * 70), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child));
}

// ─── Info row model ───────────────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow(this.icon, this.label, this.value, this.color);
}