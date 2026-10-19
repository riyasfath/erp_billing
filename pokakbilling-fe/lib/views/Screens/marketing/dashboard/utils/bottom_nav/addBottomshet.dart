import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pokakbilling/core/themes/app_colors.dart';
import 'package:pokakbilling/viewmodels/setup/location_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/source_viewmodel.dart';
import 'package:pokakbilling/viewmodels/setup/categoryList_viewmodel.dart';
import 'package:pokakbilling/models/data-models/marketing_model/source.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kIndigo = Color(0xFF6366F1);
const _kIndigoLight = Color(0xFF818CF8);
const _kIndigoDark = Color(0xFF4338CA);
const _kMetricInk = Color(0xFF1E1B4B);
const _kSoftLilac = Color(0xFFF0EEFF);

// ── Shared input decoration ───────────────────────────────────────────────────
InputDecoration _inputDeco(String hint, {bool isDark = false}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black38, fontSize: 13.5),
    filled: true,
    fillColor: isDark ? Colors.white.withValues(alpha: 0.07) : _kSoftLilac,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
          color: isDark
              ? _kIndigoLight.withValues(alpha: 0.2)
              : _kIndigo.withValues(alpha: 0.2),
          width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _kIndigo.withValues(alpha: 0.55), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
    ),
  );
}

// ── Shared card container ─────────────────────────────────────────────────────
class _SheetCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SheetCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 60, 14, 0),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 540),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1B3A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? _kIndigoLight.withValues(alpha: 0.18)
                    : _kIndigo.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.5)
                      : _kIndigo.withValues(alpha: 0.12),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Shared header ─────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  const _SheetHeader(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              isDark ? _kIndigo.withValues(alpha: 0.2) : _kIndigo.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(icon,
              color: isDark ? _kIndigoLight : _kIndigoDark, size: 20),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : _kMetricInk)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close_rounded,
              size: 15, color: isDark ? Colors.white60 : Colors.black54),
        ),
      ),
    ]);
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FieldLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
            color: isDark ? _kIndigoLight : _kIndigoDark));
  }
}

// ── Action buttons ────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool loading;
  final VoidCallback onSave;
  final bool isDark;
  const _ActionButtons(
      {required this.loading, required this.onSave, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: SizedBox(
          height: 46,
          child: OutlinedButton(
            onPressed: loading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : _kIndigo.withValues(alpha: 0.25)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Cancel',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: loading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kIndigo,
              disabledBackgroundColor: _kIndigoLight.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save',
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
          ),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD LOCATION
// ═══════════════════════════════════════════════════════════════════════════════
class AddLocationBottomSheet extends StatefulWidget {
  const AddLocationBottomSheet({super.key});
  @override
  State<AddLocationBottomSheet> createState() => _AddLocationBottomSheetState();
}

class _AddLocationBottomSheetState extends State<AddLocationBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return _SheetCard(
      isDark: _isDark,
      child: Consumer<LocationViewmodel>(
        builder: (context, vm, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHeader(
                  title: 'Add Location',
                  subtitle: 'Create a new marketing location',
                  icon: Icons.location_on_outlined,
                  isDark: _isDark,
                ),
                const SizedBox(height: 22),

                _FieldLabel(text: 'Location Name', isDark: _isDark),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                        color: _isDark ? Colors.white : _kMetricInk,
                        fontSize: 14),
                    decoration:
                        _inputDeco('Enter location name…', isDark: _isDark)
                            .copyWith(errorText: _errorText),
                  ),
                ),

                const SizedBox(height: 20),

                // Map preview — hidden when keyboard is open
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isKeyboardOpen
                      ? const SizedBox.shrink(key: ValueKey('no_img'))
                      : Column(
                          key: const ValueKey('map_img'),
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/map.png',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                ),

                _ActionButtons(
                  loading: vm.addLocationLoading,
                  isDark: _isDark,
                  onSave: () {
                    final name = _controller.text.trim();
                    if (name.isEmpty) return;
                    final alreadyExists = vm.locations.any((l) =>
                        l.name.trim().toLowerCase() == name.toLowerCase());
                    if (alreadyExists) {
                      setState(() => _errorText = 'Location already exists');
                      return;
                    }
                    setState(() => _errorText = null);
                    vm.createLocation(name, context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD SOURCE
// ═══════════════════════════════════════════════════════════════════════════════
class AddSourceBottomSheet extends StatefulWidget {
  const AddSourceBottomSheet({super.key});
  @override
  State<AddSourceBottomSheet> createState() => _AddSourceBottomSheetState();
}

class _AddSourceBottomSheetState extends State<AddSourceBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      isDark: _isDark,
      child: Consumer<SourceViewmodel>(
        builder: (context, vm, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHeader(
                  title: 'Add Source',
                  subtitle: 'Create a new marketing source',
                  icon: Icons.share_outlined,
                  isDark: _isDark,
                ),
                const SizedBox(height: 22),

                _FieldLabel(text: 'Source Name', isDark: _isDark),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                        color: _isDark ? Colors.white : _kMetricInk,
                        fontSize: 14),
                    decoration:
                        _inputDeco('Enter source name…', isDark: _isDark)
                            .copyWith(errorText: _errorText),
                  ),
                ),
                const SizedBox(height: 14),

                // Info hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isDark ? _kIndigo.withValues(alpha: 0.12) : _kSoftLilac,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _isDark
                            ? _kIndigoLight.withValues(alpha: 0.15)
                            : _kIndigo.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16,
                          color: _isDark ? _kIndigoLight : _kIndigoDark),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Examples: Google Ads, Facebook, Organic, Referral',
                          style: TextStyle(
                              fontSize: 12,
                              color: _isDark ? _kIndigoLight : _kIndigoDark),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _ActionButtons(
                  loading: vm.addSourceLoading,
                  isDark: _isDark,
                  onSave: () {
                    final name = _controller.text.trim();
                    if (name.isEmpty) return;
                    final alreadyExists = vm.sources.any((s) =>
                        s.name.trim().toLowerCase() == name.toLowerCase());
                    if (alreadyExists) {
                      setState(() => _errorText = 'Source already exists');
                      return;
                    }
                    setState(() => _errorText = null);
                    vm.createSource(name, context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD CATEGORY
// ═══════════════════════════════════════════════════════════════════════════════
class AddCategoryBottomSheet extends StatefulWidget {
  const AddCategoryBottomSheet({super.key});
  @override
  State<AddCategoryBottomSheet> createState() => _AddCategoryBottomSheetState();
}

class _AddCategoryBottomSheetState extends State<AddCategoryBottomSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  Source? _selectedSource;
  String? _errorText;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      isDark: _isDark,
      child: Consumer2<SourceViewmodel, CategoryMarketingViewmodel>(
        builder: (context, sourceVm, categoryVm, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHeader(
                  title: 'Add Category',
                  subtitle: 'Create a new marketing category',
                  icon: Icons.local_offer_rounded,
                  isDark: _isDark,
                ),
                const SizedBox(height: 22),
                _FieldLabel(text: 'Category Name', isDark: _isDark),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _nameCtrl,
                    maxLines: 1,
                    style: TextStyle(
                        color: _isDark ? Colors.white : _kMetricInk,
                        fontSize: 14),
                    decoration:
                        _inputDeco('Enter category name…', isDark: _isDark)
                            .copyWith(errorText: _errorText),
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel(text: 'Source *', isDark: _isDark),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: DropdownButtonFormField<Source>(
                    initialValue: _selectedSource,
                    isDense: true,
                    style: TextStyle(
                        color: _isDark ? Colors.white : _kMetricInk,
                        fontSize: 14),
                    dropdownColor:
                        _isDark ? const Color(0xFF2A2750) : Colors.white,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: _isDark ? _kIndigoLight : _kIndigo, size: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      filled: true,
                      fillColor: _isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : _kSoftLilac,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: _isDark
                                ? _kIndigoLight.withValues(alpha: 0.2)
                                : _kIndigo.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: _isDark
                                ? _kIndigoLight.withValues(alpha: 0.2)
                                : _kIndigo.withValues(alpha: 0.2),
                            width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: _kIndigo.withValues(alpha: 0.55), width: 1.5),
                      ),
                    ),
                    hint: Text('Select a source…',
                        style: TextStyle(
                            color: _isDark ? Colors.white30 : Colors.black38,
                            fontSize: 13.5)),
                    onChanged: (v) => setState(() => _selectedSource = v),
                    selectedItemBuilder: (context) => sourceVm.sources
                        .map((s) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(s.name,
                                  style: TextStyle(
                                      color:
                                          _isDark ? Colors.white : _kMetricInk,
                                      fontSize: 14)),
                            ))
                        .toList(),
                    items: sourceVm.sources
                        .map((s) => DropdownMenuItem<Source>(
                              value: s,
                              child: Text(s.name,
                                  style: TextStyle(
                                      color: _isDark
                                          ? Colors.white
                                          : _kMetricInk)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                _ActionButtons(
                  loading: categoryVm.addCategoryLoading,
                  isDark: _isDark,
                  onSave: () {
                    final name = _nameCtrl.text.trim();
                    if (name.isEmpty) {
                      setState(() => _errorText = 'Category name is required');
                      return;
                    }
                    if (_selectedSource == null) {
                      setState(
                          () => _errorText = 'Please select a source first');
                      return;
                    }
                    final alreadyExists = categoryVm.categories.any((c) =>
                        c.name.trim().toLowerCase() == name.toLowerCase() &&
                        c.source == _selectedSource!.id);
                    if (alreadyExists) {
                      setState(() => _errorText =
                          'Category already exists for this source');
                      return;
                    }
                    setState(() => _errorText = null);
                    categoryVm.createCategory(
                        name, _selectedSource!.id, context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
