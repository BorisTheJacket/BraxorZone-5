import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF141414);
  static const Color card = Color(0xFF1C1C1C);
  static const Color cardElevated = Color(0xFF242424);

  // Neon green brand accent
  static const Color primary = Color(0xFF39FF14);
  static const Color primaryDim = Color(0xFF2ECC44);
  static const Color primaryDark = Color(0xFF1A7A0A);
  static const Color primaryOverlay = Color(0xFF39FF14);

  // Secondary accent
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color accentBlue = Color(0xFF3FA9F5);

  // Text
  static const Color textPrimary = Color(0xFFEFFEE3);   // headings — light green tint
  static const Color textSecondary = Color(0xFFFFFFFF); // body text — pure white
  static const Color textHint = Color(0xFFAAAAAA);      // placeholders & timestamps

  // Structure
  static const Color divider = Color(0xFF222222);
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderFocus = Color(0xFF39FF14);

  // State
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF39FF14);
  static const Color warning = Color(0xFFFF8C00);

  // Hex grid tones
  static const Color hexFill = Color(0xFF171717);
  static const Color hexBorder = Color(0xFF0A0A0A);

  static const List<Color> greenGradient = [
    Color(0xFF39FF14),
    Color(0xFF2ECC44),
  ];

  static const List<Color> darkCardGradient = [
    Color(0xFF242424),
    Color(0xFF1C1C1C),
  ];

  static const List<Color> heroGradient = [
    Color(0xFF0D0D0D),
    Color(0xFF141414),
  ];
}
