import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokakbilling/viewmodels/course_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:pokakbilling/viewmodels/lead_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/sales_person_viewmodel.dart';
import 'package:pokakbilling/models/data-models/lead_model.dart';
import 'package:pokakbilling/models/data-models/marketing_model/location.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';
import 'package:pokakbilling/models/data-models/salesperson_model.dart';
import 'package:pokakbilling/models/services/marketing_location.dart';
import 'package:pokakbilling/views/Screens/marketing/source/addSourceScreen.dart';

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

const LinearGradient _kHeaderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_kCyanDeep, _kCyan, _kCyanLight],
);

Color _shade(Color c, double amt) => Color.lerp(c, Colors.black, amt)!;
Color _tint(Color c, double amt) => Color.lerp(c, Colors.white, amt)!;

/// Default lead status applied when the user does not pick one.
const String _kDefaultLeadStatus = 'New';

// ═════════════════════════════════════════════════════════════════════════════
// Shared form styling
// ═════════════════════════════════════════════════════════════════════════════
OutlineInputBorder _border(Color c, {double width = 1.0}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: width),
    );

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  String? hint,
  bool hasError = false,
  bool showRequiredDot = false,
  Widget? suffix,
}) {
  final accent = hasError ? _kRed : _kCyan;
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: hasError ? _kRed : _kSlate,
    ),
    floatingLabelStyle: TextStyle(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      color: hasError ? _kRed : _kCyanDeep,
    ),
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 13,
      color: hasError
          ? _kRed.withValues(alpha: 0.6)
          : _kSlate.withValues(alpha: 0.55),
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 10, right: 8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: hasError ? _kRed : _kCyanDeep),
      ),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 30),
    suffixIcon: suffix != null
        ? Padding(padding: const EdgeInsets.only(right: 8), child: suffix)
        : (showRequiredDot
            ? const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.circle, size: 7, color: _kRed),
              )
            : null),
    suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    filled: true,
    fillColor: hasError ? _kRed.withValues(alpha: 0.04) : _kPageBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: _border(hasError ? _kRed.withValues(alpha: 0.6) : _kLine),
    enabledBorder: _border(hasError ? _kRed.withValues(alpha: 0.6) : _kLine),
    focusedBorder: _border(hasError ? _kRed : _kCyan, width: 1.6),
  );
}

class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, size: 14, color: _kRed),
          const SizedBox(width: 4),
          Flexible(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kRed,
                    height: 1.4)),
          ),
        ]),
      );
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();

  @override
  Widget build(BuildContext context) => Container(
        height: 54,
        decoration: BoxDecoration(
          color: _kPageBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kLine),
        ),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(color: _kCyan, strokeWidth: 2),
          ),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared gradient header
// ═════════════════════════════════════════════════════════════════════════════
class _GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData watermark;
  final Widget? trailing;
  final Widget? bottom;
  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.watermark,
    this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
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
          right: 64,
          top: mq.padding.top + 2,
          child: Transform.rotate(
            angle: -0.25,
            child: Icon(watermark,
                size: 90, color: Colors.white.withValues(alpha: 0.12)),
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
              bottom: 22,
              left: sw * .045,
              right: sw * .045),
          child: Column(children: [
            Row(children: [
              _Pressable(
                onTap: () => Navigator.of(context).pop(),
                child: _GlassCircle(
                    icon: Icons.arrow_back_ios_new_rounded, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 14)),
                    ]),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ]),
            if (bottom != null) ...[
              const SizedBox(height: 16),
              bottom!,
            ],
          ]),
        ),
      ]),
    );
  }
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

class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _GradientFab({required this.onTap, this.icon = Icons.add_rounded});

  @override
  Widget build(BuildContext context) => _Pressable(
        onTap: onTap,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: _kHeaderGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kCyan.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// SELECT SOURCE PAGE
// ════════════════════════════════════════════════════════════════════════════
class SelectSourcePage extends StatefulWidget {
  const SelectSourcePage({super.key});

  @override
  State<SelectSourcePage> createState() => _SelectSourcePageState();
}

class _SelectSourcePageState extends State<SelectSourcePage> {
  String _query = '';

  static const List<Color> _rowColors = [
    _kCyan, _kViolet, _kPink, _kGreen, _kAmber, _kBlue, _kOrange
  ];

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SourceViewmodel>(context);
    final sw = MediaQuery.of(context).size.width;

    final filtered = _query.isEmpty
        ? vm.sources
        : vm.sources
            .where((s) =>
                s.name.toLowerCase().contains(_query.trim().toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: _kPageBg,
      floatingActionButton: _GradientFab(onTap: () => _goAddSource(context, vm)),
      body: Column(
        children: [
          // ── Header with search ─────────────────────────────────────────
          _GradientHeader(
            title: 'Select Source',
            subtitle: '${vm.sources.length} lead sources',
            watermark: Icons.alt_route_rounded,
            trailing: vm.isLoading
                ? const SizedBox(
                    width: 42,
                    height: 42,
                    child: Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                  )
                : _Pressable(
                    onTap: () =>
                        Provider.of<SourceViewmodel>(context, listen: false)
                            .fetchSources(),
                    child: const _GlassCircle(icon: Icons.refresh_rounded),
                  ),
            bottom: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _kCyanDeep.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(children: [
                const Icon(Icons.search_rounded, color: _kCyan, size: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    cursorColor: _kCyan,
                    style: const TextStyle(
                        fontSize: 14.5,
                        color: _kInk,
                        fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Search sources…',
                      hintStyle: TextStyle(fontSize: 14, color: _kSlate),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                if (_query.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${filtered.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _kCyanDeep)),
                  ),
              ]),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: vm.isLoading && vm.sources.isEmpty
                ? const Center(child: CircularProgressIndicator(color: _kCyan))
                : filtered.isEmpty
                    ? _buildEmptyState(context, vm)
                    : ListView.separated(
                        padding:
                            EdgeInsets.fromLTRB(sw * .04, 18, sw * .04, 96),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final s = filtered[i];
                          final c = _rowColors[i % _rowColors.length];
                          return _FadeIn(
                            index: i < 10 ? i : 10,
                            child: _Pressable(
                              onTap: () =>
                                  Navigator.of(context).pop<Source?>(s),
                              child: _sourceRow(s, c),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _sourceRow(Source s, Color c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kLine),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_tint(c, 0.25), c],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_tint(c, 0.22), c],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: c.withValues(alpha: 0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.alt_route_rounded,
                        color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _kInk,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 19, color: _shade(c, 0.1)),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, SourceViewmodel vm) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kCyan.withValues(alpha: 0.10),
                    _kCyan.withValues(alpha: 0.22),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: _kCyan.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.label_off_rounded,
                  color: _kCyanDeep, size: 36),
            ),
            const SizedBox(height: 16),
            Text(_query.isEmpty ? 'No sources yet' : 'No matching sources',
                style: const TextStyle(
                    color: _kInk, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Add a source to tag where leads come from',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kSlate, fontSize: 13.5)),
            const SizedBox(height: 18),
            _Pressable(
              onTap: () => _goAddSource(context, vm),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: [_kCyanDeep, _kCyan]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _kCyan.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text('Add Source',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ]),
        ),
      );

  Future<void> _goAddSource(BuildContext context, SourceViewmodel vm) async {
    final bool? didAdd = await Navigator.push<bool?>(
      context,
      MaterialPageRoute<bool?>(
        builder: (_) => ChangeNotifierProvider.value(
            value: vm, child: const AddSourcePage()),
      ),
    );
    if (didAdd == true && mounted) await vm.fetchSources();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// CREATE / EDIT LEAD
// ════════════════════════════════════════════════════════════════════════════
class CreateLead extends StatefulWidget {
  final bool isEdit;
  final LeadModel? lead;

  const CreateLead({super.key, required this.isEdit, this.lead});

  @override
  State<CreateLead> createState() => _CreateLeadState();
}

class _CreateLeadState extends State<CreateLead> {
  // ── Controllers ───────────────────────────────────────────────────────────
  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController notesController;
  late TextEditingController enquiryController;
  late TextEditingController addressController;
  late TextEditingController projectRequirementController;
  late TextEditingController otherCategoryController;
  late TextEditingController leadSourceController;
  late TextEditingController dateController;

  // ── State ─────────────────────────────────────────────────────────────────
  List<Location> _locations = [];
  bool _loadingLocations = false;
  int? _selectedLocationId;
  int? _selectedLeadSourceId;
  bool _sourceNameResolved = false;
  String? _selectedLeadCategory;
  int? _selectedCourseId;
  int? _selectedSalesPersonId;
  DateTime? _selectedDate;

  // ── Field errors ──────────────────────────────────────────────────────────
  String? _errName;
  String? _errPhone;
  String? _errSource;
  String? _errDate;
  String? _errReasonNote; // lead_status == lost
  String? _errOtherNote; // lead_status == other

  // ── Status-specific notes ─────────────────────────────────────────────────
  // lost  → reason_note
  // other → other_note
  final TextEditingController _reasonNoteController = TextEditingController();
  final TextEditingController _otherNoteController = TextEditingController();

  // Status keys the backend treats specially
  static const String _kLostKey = 'lost';
  static const String _kOtherKey = 'other';

  @override
  void initState() {
    super.initState();

    final l = widget.lead;
    nameController = TextEditingController(text: l?.name ?? '');
    companyController = TextEditingController(text: l?.company ?? '');
    emailController = TextEditingController(text: l?.emailId ?? '');
    phoneController = TextEditingController(text: l?.phone ?? '');
    notesController = TextEditingController(text: l?.notes ?? '');
    enquiryController = TextEditingController(text: l?.enquiry ?? '');
    addressController = TextEditingController(text: l?.address ?? '');
    projectRequirementController =
        TextEditingController(text: l?.projectRequirement ?? '');
    otherCategoryController =
        TextEditingController(text: l?.otherCategoryDetail ?? '');
    leadSourceController = TextEditingController();
    dateController = TextEditingController(
      text: l?.date != null ? _apiDateToDisplay(l!.date) : '',
    );

    // Pre-fill status notes when editing
    _reasonNoteController.text = l?.reasonNote ?? '';
    _otherNoteController.text = l?.otherNote ?? '';

    if (l?.leadSource != null) _selectedLeadSourceId = l!.leadSource;
    if (l?.location != null) _selectedLocationId = l!.location;
    if (l?.leadCategory != null) _selectedLeadCategory = l!.leadCategory;
    if (l?.course != null) _selectedCourseId = l!.course;
    if (l?.salesperson != null) _selectedSalesPersonId = l!.salesperson;

    if (l?.date != null && l!.date.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(l.date);
      } catch (_) {}
    }

    _fetchLocations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final leadVm = Provider.of<LeadViewmodel>(context, listen: false);
      final existingStatus = (l?.leadStatusDisplay ?? '').trim();

      if (widget.isEdit && existingStatus.isNotEmpty) {
        // Editing: keep the lead's current status
        leadVm.selectLeadStatus(existingStatus);
      } else {
        // Creating (or editing a lead with no status): default to "New".
        // This also clears any status left over from a previous form.
        _applyDefaultStatus(leadVm);
      }
    });
  }

  // ── Default status helper ─────────────────────────────────────────────────
  /// Selects "New" in the view model, matching the exact spelling used in
  /// leadStatusList (e.g. "New" / "new" / "NEW").
  void _applyDefaultStatus(LeadViewmodel vm) {
    final match = vm.leadStatusList.firstWhere(
      (s) => s.trim().toLowerCase() == _kDefaultLeadStatus.toLowerCase(),
      orElse: () => '',
    );
    if (match.isNotEmpty) {
      vm.selectLeadStatus(match);
    } else {
      debugPrint(
          'CreateLead: "$_kDefaultLeadStatus" not found in leadStatusList');
    }
  }

  // ── Date helpers ──────────────────────────────────────────────────────────
  String _apiDateToDisplay(String apiDate) {
    if (apiDate.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(apiDate.trim());
      return _formatDate(dt);
    } catch (_) {
      return apiDate;
    }
  }

  String? _displayDateToApi(String displayDate) {
    if (displayDate.trim().isEmpty) return null;
    try {
      final parts = displayDate.trim().split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
      }
    } catch (_) {}
    return null;
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kCyan,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kInk,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            headerBackgroundColor: _kCyanDeep,
            headerForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text = _formatDate(picked);
        _errDate = null;
      });
    }
  }

  Future<void> _fetchLocations() async {
    setState(() => _loadingLocations = true);
    try {
      final fetched = await LocationServices.getLocations();
      if (mounted) setState(() => _locations = fetched);
    } catch (e) {
      debugPrint('Failed to load locations: $e');
    } finally {
      if (mounted) setState(() => _loadingLocations = false);
    }
  }

  void _resolveSourceNameIfNeeded(SourceViewmodel? vm) {
    if (_sourceNameResolved) return;
    if (_selectedLeadSourceId == null) {
      _sourceNameResolved = true;
      return;
    }
    if (vm == null) return;
    final found = vm.sources.firstWhere(
      (s) => s.id == _selectedLeadSourceId,
      orElse: () => Source(id: 0, name: '', locations: [], categories: []),
    );
    if (found.id != 0) {
      setState(() => leadSourceController.text = found.name);
    }
    _sourceNameResolved = true;
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    notesController.dispose();
    enquiryController.dispose();
    addressController.dispose();
    projectRequirementController.dispose();
    otherCategoryController.dispose();
    leadSourceController.dispose();
    dateController.dispose();
    _reasonNoteController.dispose();
    _otherNoteController.dispose();
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────
  String? _validateName(String v) {
    if (v.trim().isEmpty) return 'Name is required';
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(v.trim())) {
      return 'Name should contain only letters';
    }
    return null;
  }

  String? _validatePhone(String v) {
    if (v.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // ── Source selector ───────────────────────────────────────────────────────
  Future<void> _openSourceSelector(SourceViewmodel parentVm) async {
    final Source? selected = await Navigator.push<Source?>(
      context,
      MaterialPageRoute<Source?>(
        builder: (_) => ChangeNotifierProvider.value(
            value: parentVm, child: const SelectSourcePage()),
      ),
    );
    if (!mounted) return;
    await parentVm.fetchSources();
    if (selected != null) {
      setState(() {
        _selectedLeadSourceId = selected.id;
        leadSourceController.text = selected.name;
        _errSource = null;
      });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _handleSubmit(BuildContext context) {
    final leadVm = Provider.of<LeadViewmodel>(context, listen: false);

    // Status is optional — fall back to "New" if nothing is selected.
    if (leadVm.selectedLeadStatus.isEmpty) _applyDefaultStatus(leadVm);

    final rawKey = leadVm.selectedLeadStatusKey.trim().toLowerCase();
    final rawLabel = leadVm.selectedLeadStatus.trim().toLowerCase();
    final isLost = rawKey == _kLostKey || rawLabel == 'lost';
    final isOtherStatus = rawKey == _kOtherKey || rawLabel == 'other';

    // Always send the exact key the backend expects
    final statusKey = isLost
        ? _kLostKey
        : (isOtherStatus ? _kOtherKey : leadVm.selectedLeadStatusKey);
    final isStudentCategory = _selectedLeadCategory == 'intern';

    // Validate: full name, phone number, and the status-specific note
    final nameErr = _validateName(nameController.text);
    final phoneErr = _validatePhone(phoneController.text);
    final reasonErr = isLost && _reasonNoteController.text.trim().isEmpty
        ? 'Reason note is required'
        : null;
    final otherErr = isOtherStatus && _otherNoteController.text.trim().isEmpty
        ? 'Other note is required'
        : null;

    setState(() {
      _errName = nameErr;
      _errPhone = phoneErr;
      _errSource = null;
      _errDate = null;
      _errReasonNote = reasonErr;
      _errOtherNote = otherErr;
    });

    if (nameErr != null ||
        phoneErr != null ||
        reasonErr != null ||
        otherErr != null) {
      HapticFeedback.mediumImpact();
      return;
    }

    final String? apiDate = _displayDateToApi(dateController.text);
    final String? otherDetail = _selectedLeadCategory == 'other'
        ? otherCategoryController.text.trim()
        : null;
    final int? courseValue = isStudentCategory ? _selectedCourseId : null;

    // Only send the note that matches the selected status
    final String? reasonNote =
        isLost ? _reasonNoteController.text.trim() : null;
    final String? otherNote =
        isOtherStatus ? _otherNoteController.text.trim() : null;

    if (widget.isEdit && widget.lead != null) {
      leadVm.editLead(
        widget.lead!.leadId,
        nameController.text.trim(),
        companyController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        notesController.text.trim(),
        statusKey,
        _selectedLeadSourceId,
        enquiryController.text.trim(),
        context,
        location: _selectedLocationId,
        date: apiDate,
        leadCategory: _selectedLeadCategory,
        otherCategoryDetail: otherDetail,
        course: courseValue,
        salesperson: _selectedSalesPersonId,
        reasonNote: reasonNote,
        otherNote: otherNote,
      );
    } else {
      leadVm.createLead(
        nameController.text.trim(),
        companyController.text.trim(),
        emailController.text.trim(),
        phoneController.text.trim(),
        notesController.text.trim(),
        statusKey,
        _selectedLeadSourceId,
        enquiryController.text.trim(),
        context,
        location: _selectedLocationId,
        date: apiDate,
        leadCategory: _selectedLeadCategory,
        otherCategoryDetail: otherDetail,
        course: courseValue,
        salesperson: _selectedSalesPersonId,
        reasonNote: reasonNote,
        otherNote: otherNote,
      );
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sourceVm = Provider.of<SourceViewmodel?>(context);
    final sw = MediaQuery.of(context).size.width;

    if (!_sourceNameResolved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resolveSourceNameIfNeeded(sourceVm);
      });
    }

    return Scaffold(
      backgroundColor: _kPageBg,
      body: Column(
        children: [
          _GradientHeader(
            title: widget.isEdit ? 'Edit Lead' : 'Create Lead',
            subtitle: widget.isEdit
                ? 'Update lead details'
                : 'Fill in the details below',
            watermark: widget.isEdit
                ? Icons.edit_note_rounded
                : Icons.person_add_alt_1_rounded,
            trailing: _GlassCircle(
              icon: widget.isEdit
                  ? Icons.edit_rounded
                  : Icons.person_add_alt_1_rounded,
            ),
            bottom: _buildProgressStrip(),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(sw * .04, 20, sw * .04,
                    MediaQuery.of(context).padding.bottom + 28),
                children: [
                  // ── Lead Identity ────────────────────────────────────
                  _FadeIn(
                    index: 0,
                    child: _Section(
                      icon: Icons.badge_rounded,
                      title: 'Lead Identity',
                      subtitle: 'Who is this lead?',
                      color: _kCyan,
                      children: [
                        _field(
                          controller: nameController,
                          label: 'Full Name',
                          icon: Icons.person_rounded,
                          hint: 'Enter full name',
                          isRequired: true,
                          error: _errName,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r"[a-zA-Z\s\-']")),
                          ],
                          onChanged: (_) {
                            if (_errName != null) {
                              setState(() => _errName = null);
                            }
                            setState(() {});
                          },
                        ),
                        _field(
                          controller: companyController,
                          label: 'Company Name',
                          icon: Icons.business_rounded,
                          hint: 'Enter company name',
                        ),
                      ],
                    ),
                  ),

                  // ── Contact Details ──────────────────────────────────
                  _FadeIn(
                    index: 1,
                    child: _Section(
                      icon: Icons.contact_phone_rounded,
                      title: 'Contact Details',
                      subtitle: 'How to reach them',
                      color: _kViolet,
                      children: [
                        _field(
                          controller: phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_rounded,
                          hint: '10-digit phone number',
                          isRequired: true,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          error: _errPhone,
                          onChanged: (_) {
                            if (_errPhone != null) {
                              setState(() => _errPhone = null);
                            }
                            setState(() {});
                          },
                        ),
                        _field(
                          controller: emailController,
                          label: 'Email Address',
                          icon: Icons.email_rounded,
                          hint: 'email@example.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _field(
                          controller: addressController,
                          label: 'Address',
                          icon: Icons.home_rounded,
                          hint: 'Street address',
                        ),
                      ],
                    ),
                  ),

                  // ── Lead Information ─────────────────────────────────
                  _FadeIn(
                    index: 2,
                    child: _Section(
                      icon: Icons.insights_rounded,
                      title: 'Lead Information',
                      subtitle: 'Status, source & assignment',
                      color: _kPink,
                      children: [
                        _buildStatusDropdown(),
                        _buildSourceTile(sourceVm),
                        _buildSalesPersonDropdown(),
                        _buildDatePickerField(),
                        _field(
                          controller: enquiryController,
                          label: 'Enquiry',
                          icon: Icons.help_rounded,
                          hint: 'What are they interested in?',
                        ),
                        _buildLocationDropdown(),
                        _buildLeadCategoryDropdown(),
                        _buildCourseDropdown(),
                      ],
                    ),
                  ),

                  // ── Notes & Requirements ─────────────────────────────
                  _FadeIn(
                    index: 3,
                    child: _Section(
                      icon: Icons.sticky_note_2_rounded,
                      title: 'Notes & Requirements',
                      subtitle: 'Anything worth remembering',
                      color: _kGreen,
                      children: [
                        _field(
                          controller: projectRequirementController,
                          label: 'Project Requirements',
                          icon: Icons.checklist_rounded,
                          hint: 'Describe project needs',
                          maxLines: 3,
                        ),
                        _field(
                          controller: notesController,
                          label: 'Additional Notes',
                          icon: Icons.notes_rounded,
                          hint: 'Any other notes',
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FadeIn(index: 4, child: _buildActionButtons()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Required-fields progress strip (inside header) ────────────────────────
  Widget _buildProgressStrip() {
    // Only Name and Phone are required now (Status defaults to "New").
    final done = [
      nameController.text.trim().isNotEmpty,
      phoneController.text.trim().length == 10,
    ].where((b) => b).length;
    const total = 2;
    final ratio = done / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Column(children: [
        Row(children: [
          Icon(
            done == total ? Icons.verified_rounded : Icons.checklist_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              done == total
                  ? 'All required fields filled'
                  : 'Required: Name, Phone',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Text('$done/$total',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 7,
            color: Colors.white.withValues(alpha: 0.25),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: ratio),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                widthFactor: v == 0 ? 0.02 : v,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    Widget? suffix,
    int maxLines = 1,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            cursorColor: _kCyan,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            // Every field starts at the SAME single-line height and grows
            // only if the user types more lines (up to maxLines).
            minLines: 1,
            maxLines: maxLines,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
                fontSize: 14.5, color: _kInk, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(
              label: label,
              icon: icon,
              hint: hint,
              hasError: hasError,
              showRequiredDot: isRequired && !readOnly,
              suffix: suffix,
            ),
          ),
          if (hasError) _ErrorText(error),
        ],
      ),
    );
  }

  // ── Status dropdown (defaults to "New") + Lost / Other note fields ────────
  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Consumer<LeadViewmodel>(
        builder: (context, provider, _) {
          final key = provider.selectedLeadStatusKey.trim().toLowerCase();
          final label = provider.selectedLeadStatus.trim().toLowerCase();
          final isLost = key == _kLostKey || label == 'lost';
          final isOtherStatus = key == _kOtherKey || label == 'other';

          // Only pass a value that exists in the items list, otherwise
          // DropdownButtonFormField throws an assertion.
          final current = provider.leadStatusList
                  .contains(provider.selectedLeadStatus)
              ? provider.selectedLeadStatus
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                // Key forces the field to rebuild when the default ("New")
                // is applied after the first frame — initialValue is only
                // read once otherwise.
                key: ValueKey('lead_status_${current ?? ''}'),
                initialValue: current,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: _kCyan, size: 22),
                style: const TextStyle(
                    fontSize: 14.5, color: _kInk, fontWeight: FontWeight.w600),
                hint: Text('$_kDefaultLeadStatus (default)',
                    style: TextStyle(
                        fontSize: 13.5,
                        color: _kSlate.withValues(alpha: 0.7))),
                decoration: _inputDecoration(
                  label: 'Status',
                  icon: Icons.flag_rounded,
                ),
                items: provider.leadStatusList
                    .map((s) => DropdownMenuItem<String>(
                          value: s,
                          child: Text(s,
                              style: const TextStyle(
                                  color: _kInk, fontSize: 14.5)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  provider.selectLeadStatus(value);
                  setState(() {
                    _errReasonNote = null;
                    _errOtherNote = null;
                  });
                },
              ),

              // ── Lost → Reason Note ──
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isLost
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _field(
                          controller: _reasonNoteController,
                          label: 'Reason Note',
                          icon: Icons.sentiment_dissatisfied_rounded,
                          hint: 'Why was this lead lost?',
                          isRequired: true,
                          maxLines: 3,
                          error: _errReasonNote,
                          onChanged: (_) {
                            if (_errReasonNote != null) {
                              setState(() => _errReasonNote = null);
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // ── Other → Other Note ──
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: isOtherStatus
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _field(
                          controller: _otherNoteController,
                          label: 'Other Note',
                          icon: Icons.edit_note_rounded,
                          hint: 'Enter additional details...',
                          isRequired: true,
                          maxLines: 3,
                          error: _errOtherNote,
                          onChanged: (_) {
                            if (_errOtherNote != null) {
                              setState(() => _errOtherNote = null);
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Tappable picker tile (source / date) ──────────────────────────────────
  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String placeholder,
    required String? value,
    required IconData setIcon,
    required VoidCallback onTap,
    String? error,
  }) {
    final hasError = error != null && error.isNotEmpty;
    final isSet = value != null && value.isNotEmpty;
    final accent = hasError ? _kRed : _kCyan;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Pressable(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: hasError
                    ? _kRed.withValues(alpha: 0.04)
                    : (isSet ? _kCyan.withValues(alpha: 0.06) : _kPageBg),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasError
                      ? _kRed.withValues(alpha: 0.6)
                      : (isSet ? _kCyan : _kLine),
                  width: hasError || isSet ? 1.5 : 1.0,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon,
                      size: 16, color: hasError ? _kRed : _kCyanDeep),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: hasError
                                  ? _kRed
                                  : (isSet ? _kCyanDeep : _kSlate))),
                      const SizedBox(height: 1),
                      Text(
                        isSet ? value : placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight:
                              isSet ? FontWeight.w700 : FontWeight.w500,
                          color: isSet
                              ? _kInk
                              : _kSlate.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: isSet
                        ? const LinearGradient(colors: [_kCyanDeep, _kCyan])
                        : null,
                    color: isSet ? null : _kCyan.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isSet ? setIcon : Icons.chevron_right_rounded,
                      size: isSet ? 15 : 19,
                      color: isSet ? Colors.white : _kCyanDeep),
                ),
              ]),
            ),
          ),
          if (hasError) _ErrorText(error),
        ],
      ),
    );
  }

  Widget _buildSourceTile(SourceViewmodel? sourceVm) {
    return _pickerTile(
      icon: Icons.alt_route_rounded,
      label: 'Lead Source',
      placeholder: 'Tap to select a source…',
      value: _selectedLeadSourceId != null ? leadSourceController.text : null,
      setIcon: Icons.edit_rounded,
      error: _errSource,
      onTap: () {
        if (sourceVm == null) return;
        _openSourceSelector(sourceVm);
      },
    );
  }

  Widget _buildDatePickerField() {
    return _pickerTile(
      icon: Icons.calendar_month_rounded,
      label: 'Lead Date',
      placeholder: 'Select lead date',
      value: _selectedDate != null ? _formatDate(_selectedDate!) : null,
      setIcon: Icons.check_rounded,
      error: _errDate,
      onTap: _pickDate,
    );
  }

  // ── Assign Salesperson dropdown ───────────────────────────────────────────
  Widget _buildSalesPersonDropdown() {
    return Consumer<SalesPersonViewmodel?>(
      builder: (context, spVm, _) {
        if (spVm == null) return const SizedBox.shrink();

        if (spVm.getSalesPersonLoading) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: _LoadingBox(),
          );
        }

        final validIds =
            spVm.salesPersonList.map((p) => p.salesPersonId).toSet();
        final dropdownValue = validIds.contains(_selectedSalesPersonId)
            ? _selectedSalesPersonId
            : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<int>(
            initialValue: dropdownValue,
            isExpanded: true,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: _kCyan, size: 22),
            style: const TextStyle(
                fontSize: 14.5, color: _kInk, fontWeight: FontWeight.w600),
            hint: Text('Select salesperson',
                style: TextStyle(
                    fontSize: 13.5, color: _kSlate.withValues(alpha: 0.7))),
            decoration: _inputDecoration(
              label: 'Assign Salesperson',
              icon: Icons.support_agent_rounded,
            ),
            items: spVm.salesPersonList
                .map((SalesPersonModel p) => DropdownMenuItem<int>(
                      value: p.salesPersonId,
                      child: Text(p.fullName,
                          style: const TextStyle(
                              color: _kInk, fontSize: 14.5)),
                    ))
                .toList(),
            onChanged: (int? newId) =>
                setState(() => _selectedSalesPersonId = newId),
          ),
        );
      },
    );
  }

  // ── Location dropdown ─────────────────────────────────────────────────────
  Widget _buildLocationDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _loadingLocations
          ? const _LoadingBox()
          : DropdownButtonFormField<int>(
              initialValue: _selectedLocationId,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: _kCyan, size: 22),
              style: const TextStyle(
                  fontSize: 14.5, color: _kInk, fontWeight: FontWeight.w600),
              hint: Text('Select location',
                  style: TextStyle(
                      fontSize: 13.5, color: _kSlate.withValues(alpha: 0.7))),
              decoration: _inputDecoration(
                label: 'Location',
                icon: Icons.place_rounded,
              ),
              items: _locations
                  .map((loc) => DropdownMenuItem<int>(
                        value: loc.id,
                        child: Text(loc.name,
                            style: const TextStyle(
                                color: _kInk, fontSize: 14.5)),
                      ))
                  .toList(),
              onChanged: (int? newId) =>
                  setState(() => _selectedLocationId = newId),
            ),
    );
  }

  // ── Lead Category (chip selector) ─────────────────────────────────────────
  Widget _buildLeadCategoryDropdown() {
    final bool showOther = _selectedLeadCategory == 'other';
    const options = [
      ('client', 'Client', Icons.business_center_rounded, _kBlue),
      ('intern', 'Student', Icons.school_rounded, _kViolet),
      ('other', 'Other', Icons.more_horiz_rounded, _kAmber),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 8),
        child: Text('Lead Category',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _kSlate)),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _categoryChip(options[i])),
            ],
          ],
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: showOther
            ? _field(
                controller: otherCategoryController,
                label: 'Specify Category',
                icon: Icons.edit_note_rounded,
                hint: 'e.g. Freelancer, Vendor, Partner…',
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }

  Widget _categoryChip((String, String, IconData, Color) opt) {
    final (value, label, icon, color) = opt;
    final selected = _selectedLeadCategory == value;

    return _Pressable(
      onTap: () => setState(() {
        // Tap again to clear, like picking "no category"
        final v = selected ? null : value;
        _selectedLeadCategory = v;
        if (v != 'other') otherCategoryController.clear();
        if (v != 'intern') _selectedCourseId = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_tint(color, 0.22), color],
                )
              : null,
          color: selected ? null : _kPageBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? Colors.transparent : _kLine, width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: selected ? Colors.white : color),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : _shade(color, 0.1))),
        ]),
      ),
    );
  }

  // ── Course dropdown — only when Lead Category == Student (intern) ─────────
  Widget _buildCourseDropdown() {
    final bool show = _selectedLeadCategory == 'intern';

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: !show
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Consumer<CourseViewmodel?>(
                builder: (context, courseVm, _) {
                  if (courseVm == null) return const SizedBox.shrink();
                  if (courseVm.isLoading) return const _LoadingBox();

                  final validIds = courseVm.courses.map((c) => c.id).toSet();
                  final dropdownValue = validIds.contains(_selectedCourseId)
                      ? _selectedCourseId
                      : null;

                  return DropdownButtonFormField<int>(
                    initialValue: dropdownValue,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _kCyan, size: 22),
                    style: const TextStyle(
                        fontSize: 14.5,
                        color: _kInk,
                        fontWeight: FontWeight.w600),
                    hint: Text('Select course',
                        style: TextStyle(
                            fontSize: 13.5,
                            color: _kSlate.withValues(alpha: 0.7))),
                    decoration: _inputDecoration(
                      label: 'Course',
                      icon: Icons.menu_book_rounded,
                    ),
                    items: courseVm.courses
                        .map((c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(c.title,
                                  style: const TextStyle(
                                      color: _kInk, fontSize: 14.5)),
                            ))
                        .toList(),
                    onChanged: (int? newId) =>
                        setState(() => _selectedCourseId = newId),
                  );
                },
              ),
            ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Consumer<LeadViewmodel>(
      builder: (context, provider, _) {
        final isLoading =
            widget.isEdit ? provider.editLoading : provider.addLeadLoader;

        return Column(
          children: [
            _Pressable(
              onTap: isLoading ? () {} : () => _handleSubmit(context),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLoading ? 0.7 : 1,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _kHeaderGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _kCyan.withValues(alpha: 0.40),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isEdit
                                    ? Icons.check_circle_rounded
                                    : Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isEdit ? 'Update Lead' : 'Create Lead',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Pressable(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kLine, width: 1.5),
                ),
                child: const Center(
                  child: Text('Cancel',
                      style: TextStyle(
                          color: _kSlate,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section card (Academy module style: accent bar + gradient icon tile)
// ═════════════════════════════════════════════════════════════════════════════
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Widget> children;
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_tint(color, 0.25), color]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_tint(color, 0.22), color],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.32),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
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
                            style: const TextStyle(
                                fontSize: 12.5, color: _kSlate)),
                      ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 24, color: _kLine),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared helpers: press-scale + staggered fade-in
// ═════════════════════════════════════════════════════════════════════════════
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