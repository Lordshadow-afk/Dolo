import 'package:flutter/material.dart';

/// Design system color tokens inspired by the Deel fintech aesthetic.
class AppColors {
  AppColors._();

  // --- Top Cockpit (Dark Obsidian Gradient) ---
  static const Color cockpitGradientStart = Color(0xFF09121F);
  static const Color cockpitGradientEnd = Color(0xFF132238);

  // Pure dark mode cockpit
  static const Color darkCockpitGradientStart = Color(0xFF060D17);
  static const Color darkCockpitGradientEnd = Color(0xFF0B1626);

  // --- Surface Sheets (Bottom 65%) ---
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF6F8FB);
  static const Color lightPillInactive = Color(0xFFEEF1F6);
  static const Color lightBorder = Color(0xFFCBD5E1);

  static const Color darkSurface = Color(0xFF14233A);
  static const Color darkBackground = Color(0xFF1B2B44);
  static const Color darkPillInactive = Color(0xFF1F3049);
  static const Color darkPillActive = Color(0xFF2A3E5C);
  static const Color darkBorder = Color(0xFF3A4B66);

  // --- Glass Triad Capsule ---
  static const Color glassTriadBg = Color(0x14FFFFFF); // rgba(255,255,255, 0.08)
  static const Color glassTriadBorder = Color(0x24FFFFFF); // rgba(255,255,255, 0.14)

  // --- The Financial Status Triad ---
  // 1. You Are Owed (Mint / Teal)
  static const Color mint = Color(0xFF00D1B2);
  static const Color mintTextLight = Color(0xFF0B7A6B);
  static const Color mintTextDark = Color(0xFF2DD4BF);
  static const Color mintSquircleBg = Color(0xFFDDF7F2);
  static const Color mintGlass = Color(0x2900D1B2);

  // 2. You Owe (Rose / Coral)
  static const Color rose = Color(0xFFF43F5E);
  static const Color roseTextLight = Color(0xFFBE123C);
  static const Color roseTextDark = Color(0xFFFB7185);
  static const Color roseSquircleBg = Color(0xFFFFE4EA);
  static const Color roseGlass = Color(0x2EF43F5E);

  // 3. Settled / Groups (Indigo / Purple)
  static const Color indigo = Color(0xFF818CF8);
  static const Color indigoDeep = Color(0xFF6C5CE7);
  static const Color indigoTextLight = Color(0xFF5B4FD6);
  static const Color indigoTextDark = Color(0xFFA5B4FC);
  static const Color indigoSquircleBg = Color(0xFFE8E6FF);
  static const Color indigoNotice = Color(0xFF3B30A8);

  // --- Student Categories ---
  static const Color categoryFood = Color(0xFF00D1B2);
  static const Color categoryHostel = Color(0xFF818CF8);
  static const Color categoryFuel = Color(0xFFF43F5E);
  static const Color categoryPrintouts = Color(0xFFF59E0B);
  static const Color categoryUdhar = Color(0xFF38BDF8);

  // --- Typography Contrasts ---
  static const Color textDarkPrimary = Color(0xFFFFFFFF);
  static const Color textDarkMuted = Color(0xFFA8B5C9);

  static const Color textLightPrimary = Color(0xFF09121F);
  static const Color textLightMuted = Color(0xFF64748B);
  static const Color textLightSecondary = Color(0xFF94A3B8);
}
