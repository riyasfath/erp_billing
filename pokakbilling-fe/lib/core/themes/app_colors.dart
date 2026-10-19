import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // PRIMARY PALETTE — use these everywhere
  // ============================================================
  static const Color navy = Color(0xFF2C354B); // dark navy   (primary)
  static const Color cyan = Color(0xFF3BBCD9); // cyan / teal (accent)
  static const Color ice = Color(0xFFE3E9F3); // light ice blue (background)

  // Aliases — kept so existing code doesn't break
  static const Color primaryColor = navy;
  static const Color violetblue = navy;
  static const Color royalBlue = cyan;
  static const Color headerPurple = navy;
  static const Color softBorder = cyan;
  static const Color lightBg = ice;
  static const Color lightGrey = ice;
  static const Color lightPurple = Color(0xFFB8D8E8);
  static const Color textfieldGrey = Color.fromARGB(37, 227, 233, 243);

  // Base
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
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
  static const Color darkGrey = Color.fromARGB(255, 115, 114, 114);
  static const Color semiTransparentGrey = Color(0xFCD9D9D9);
  static const Color hintTextGrey = Color(0xFF62748E);
  static const Color inputFill = Colors.white;

  // ============================================================
  // GRADIENTS
  // ============================================================
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [cyan, navy],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient listCardGradient = LinearGradient(
    colors: [Colors.white, cyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [navy, Color(0xFF3A4D6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // CYAN SHADES — home screen + bottom bar
  // ============================================================
  static const Color c1 = Color(0xFF3BBCD9); // primary cyan
  static const Color c2 = Color(0xFF5DD6EE); // light cyan
  static const Color c3 = Color(0xFF2A9BB8); // dark cyan

  // Light surface / background tints
  static const Color cxl = Color(0xFFEAF9FD); // ultra-light cyan
  static const Color cl = Color(0xFFD0F2FA); // light cyan
  static const Color cm = Color(0xFFA8E6F5); // mid cyan
  static const Color cgray = Color(0xFFF4FBFD); // near-white cyan
  static const Color cborder = Color(0xFFB8E8F5); // cyan border

  // Semantic text on cyan surfaces
  static const Color ctext = Color(0xFF1A6E84);
  static const Color cdark = Color(0xFF155F72);

  // ============================================================
  // STATUS / TAG COLORS
  // ============================================================
  static const Color tagRed = Color(0xFFDC2626);
  static const Color tagGreen = Color(0xFF16A34A);
  static const Color amber = Color(0xFFF59E0B);
  static const Color tagRedBg = Color(0xFFFEF2F2);
  static const Color tagGreenBg = Color(0xFFF0FDF4);
}
