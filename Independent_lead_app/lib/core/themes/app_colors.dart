import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // MAIN PALETTE  (Cyan is the primary brand color)
  // ============================================================
  static const Color navy = Color(0xFF233044); // primary text / deep header
  static const Color cyan = Color(0xFF3BBCD9); // ★ PRIMARY ACCENT
  static const Color ice = Color(0xFFF4F7FB); // app background

  // Aliases
  static const Color primaryColor = cyan;
  static const Color primary = cyan;
  static const Color primaryDark = Color(0xFF2A9BB8);
  static const Color accent = cyan;
  static const Color accentDark = Color(0xFF2A9BB8);
  static const Color violetblue = navy;
  static const Color royalBlue = cyan;
  static const Color headerPurple = navy;
  static const Color softBorder = Color(0xFFD8E3EE);
  static const Color lightBg = ice;
  static const Color lightGrey = ice;
  static const Color lightPurple = Color(0xFFE9F3FA);
  static const Color textfieldGrey = Color(0xFFEAF0F6);

  // Base
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFFF8FAFC);
  static const Color red = Colors.red;
  static const Color redAccent = Colors.redAccent;
  static const Color orange = Colors.orange;
  static const Color green = Colors.green;
  static const Color lightgreen = Colors.lightGreen;
  static const Color pink = Colors.pink;
  static const Color blue = Colors.blue;
  static const Color purple = Colors.purple;
  static const Color greenbutton = Color(0xFF00A63E);
  static const Color transparent = Colors.transparent;
  static const Color darkGrey = Color(0xFF64748B);
  static const Color semiTransparentGrey = Color(0x1A94A3B8);
  static const Color hintTextGrey = Color(0xFF8091A7);
  static const Color inputFill = Colors.white;

  // Clean surface palette
  static const Color scaffoldBg = Color(0xFFF5F8FC);
  static const Color background = scaffoldBg;
  static const Color cardBg = Colors.white;
  static const Color surface = Color(0xFFF9FBFD);
  static const Color surfaceSoft = Color(0xFFF3F6FA);
  static const Color cardBorder = Color(0xFFE3EAF2);
  static const Color border = cardBorder;
  static const Color borderSoft = Color(0xFFF0F3F8);
  static const Color softSurface = Color(0xFFF8FBFD);
  static const Color mutedSurface = Color(0xFFF1F6FA);
  static const Color softAccentBg = Color(0xFFEAF8FC);
  static const Color softAccentBorder = Color(0xFFCCEAF4);

  // Text colors
  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnDark = Colors.white;

  // ============================================================
  // CYAN FAMILY (used across cards / stats / icons)
  // ============================================================
  static const Color c1 = cyan; // #3BBCD9 – primary cyan
  static const Color c2 = Color(0xFF5DD6EE); // lighter cyan
  static const Color c3 = Color(0xFF2A9BB8); // deeper cyan

  // Soft cyan tints — used for card / chip backgrounds (BOTIM-style flat fills)
  static const Color cxl = Color(0xFFF0FBFE); // lightest tint
  static const Color cl = Color(0xFFE3F5FB); // light tint (default card bg)
  static const Color cm = Color(0xFFC7ECF8); // mid tint
  static const Color cgray = scaffoldBg;
  static const Color cborder = cardBorder;

  static const Color ctext = Color(0xFF37778A);
  static const Color cdark = navy;

  // Status colours
  static const Color tagRed = Color(0xFFDC2626);
  static const Color tagGreen = Color(0xFF16A34A);
  static const Color amber = Color(0xFFF59E0B);

  // Tag background fills
  static const Color tagRedBg = Color(0xFFFEECEC);
  static const Color tagGreenBg = Color(0xFFEAF9EF);

  // ============================================================
  // GRADIENTS
  // ============================================================
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF4FC3E7), Color(0xFF2F8FB2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient listCardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FCFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF233044), Color(0xFF31415A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
