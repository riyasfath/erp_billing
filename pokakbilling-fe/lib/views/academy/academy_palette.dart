import 'package:flutter/material.dart';

/// Light violet + cyan palette for the Academy module.
class AcadPal {
  // ── Violet family ──────────────────────────────────────────────────────────
  static const primary = Color(0xFF7C5CFC); // violet
  static const deep = Color(0xFF5B3FD9); // deep violet
  static const lilac = Color(0xFFA78BFA); // soft lilac
  static const orchid = Color(0xFFC084FC); // orchid
  static const plum = Color(0xFF9D4EDD); // plum
  static const indigo = Color(0xFF6366F1); // indigo

  // ── Cyan family ────────────────────────────────────────────────────────────
  static const cyan = Color(0xFF22D3EE); // light cyan
  static const cyanDeep = Color(0xFF0BA5C4); // readable cyan (text / icons)
  static const aqua = Color(0xFF67E8F9); // very light cyan
  static const cyanSoft = Color(0xFFE0F8FF); // cyan tint surface
  static const periwinkle = Color(0xFF38BDF8); // sky blue (kept name)
  static const rose = Color(0xFF14B8D4); // (kept name) now a cyan shade

  // ── Surfaces & text ────────────────────────────────────────────────────────
  static const white = Colors.white;
  static const bgSoft = Color(0xFFF6FAFF); // page background (violet-cyan mist)
  static const bg = Color(0xFFEEF4FF); // chips / inputs
  static const border = Color(0xFFD8E3FA);
  static const dark = Color(0xFF2E1065);
  static const text = Color(0xFF5B6B94);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFEF4444);

  /// Rotating shades (avatars, lists): alternates violet and cyan.
  static const List<Color> cycle = [
    primary,
    cyanDeep,
    indigo,
    cyan,
    plum,
    periwinkle,
    orchid,
    rose,
  ];

  static Color pick(int i) => cycle[i.abs() % cycle.length];

  static Color forName(String s) =>
      pick(s.codeUnits.fold<int>(0, (a, b) => a + b));

  /// Hero gradient: violet → cyan
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B6CFF), Color(0xFF7C5CFC), Color(0xFF22C7E8)],
  );

  /// Short brand gradient for pills / tabs / buttons.
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7C5CFC), Color(0xFF22C7E8)],
  );
}