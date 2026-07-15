import 'package:flutter/material.dart';

/// Visual tokens taken from the campus equipment loan UI mockups.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF149C89);
  static const Color primaryDark = Color(0xFF0F7A6B);
  static const Color textPrimary = Color(0xFF1A2533);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color summaryBg = Color(0xFFE9F7F5);
  static const Color successBg = Color(0xFFCCFBF1);

  static const Color laptopBg = Color(0xFFD1FAF0);
  static const Color laptopFg = Color(0xFF0F766E);
  static const Color phoneBg = Color(0xFFDBEAFE);
  static const Color phoneFg = Color(0xFF1D4ED8);
  static const Color deviceBg = Color(0xFFEDE9FE);
  static const Color deviceFg = Color(0xFF6D28D9);
  static const Color imagePlaceholder = Color(0xFFE6F7F3);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.surface,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      secondarySelectedColor: AppColors.primary,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
  );
}

({Color bg, Color fg}) categoryPalette(String category) {
  switch (category) {
    case 'Laptop':
      return (bg: AppColors.laptopBg, fg: AppColors.laptopFg);
    case 'Phone':
      return (bg: AppColors.phoneBg, fg: AppColors.phoneFg);
    default:
      return (bg: AppColors.deviceBg, fg: AppColors.deviceFg);
  }
}

String categoryBadgeLabel(String category) {
  switch (category) {
    case 'Laptop':
      return 'LAPTOP';
    case 'Phone':
      return 'PHONE';
    default:
      return 'DEVICE';
  }
}
