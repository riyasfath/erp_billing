import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _kAccent = Color(0xFF818CF8);
const Color _kPrimary = Color(0xFF6366F1);
const Color _kError = Color(0xFFEF4444);

/// ─────────────────────────────────────────────────────────────────────────────
/// AppFormField
///
/// A fully reusable, themed TextFormField wrapper that:
///  • shows a styled label above the field
///  • shows a clear, user-friendly inline error message below the field
///  • supports dark / light mode automatically
///  • exposes all common TextFormField options
///
/// Usage:
///   AppFormField(
///     label: 'First Name',
///     labelIcon: Icons.badge_outlined,
///     isRequired: true,
///     hint: 'Enter your first name',
///     controller: firstNameController,
///     validator: AppValidators.firstName,
///     onChanged: (_) => _touch('firstName'),
///     autovalidateMode: _autoMode('firstName'),
///   )
/// ─────────────────────────────────────────────────────────────────────────────
class AppFormField extends StatelessWidget {
  final String label;
  final IconData? labelIcon;
  final bool isRequired;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final AutovalidateMode autovalidateMode;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppFormField({
    super.key,
    required this.label,
    this.labelIcon,
    this.isRequired = false,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  bool _isDark(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark;

  Color _fg(BuildContext ctx) =>
      _isDark(ctx) ? Colors.white : const Color(0xFF1E1B4B);

  Color _fgMuted(BuildContext ctx) => _isDark(ctx)
      ? Colors.white.withValues(alpha: 0.5)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.5);

  Color _fieldBg(BuildContext ctx) => _isDark(ctx)
      ? Colors.white.withValues(alpha: 0.08)
      : _kPrimary.withValues(alpha: 0.05);

  Color _fieldBorder(BuildContext ctx) => _isDark(ctx)
      ? Colors.white.withValues(alpha: 0.15)
      : _kPrimary.withValues(alpha: 0.20);

  Color _hintColor(BuildContext ctx) => _isDark(ctx)
      ? Colors.white.withValues(alpha: 0.35)
      : const Color(0xFF1E1B4B).withValues(alpha: 0.35);

  Color _labelColor(BuildContext ctx) => _isDark(ctx) ? _kAccent : _kPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              if (labelIcon != null) ...[
                Icon(labelIcon, size: 13, color: _labelColor(context)),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _labelColor(context),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _kError,
                  ),
                ),
            ],
          ),
        ),

        // ── TextFormField ─────────────────────────────────────────────────
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(color: _fg(context), fontSize: 13),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          obscureText: obscureText,
          autovalidateMode: autovalidateMode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: _hintColor(context)),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 16, color: _hintColor(context))
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _fieldBg(context),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            // ── Borders ─────────────────────────────────────────────────
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _fieldBorder(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _fieldBorder(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kAccent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kError, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kError, width: 1.5),
            ),
            // ── Error style — inline, clear, friendly ──────────────────
            errorStyle: const TextStyle(
              fontSize: 11,
              color: _kError,
              height: 1.4,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
