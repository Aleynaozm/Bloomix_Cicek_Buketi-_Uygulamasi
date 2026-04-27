import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const cream = Color(0xFFFAF7F2);
  static const rose = Color(0xFFD4537E);
  static const roseDark = Color(0xFFB03D65);
  static const roseLight = Color(0xFFF4C0D1);
  static const green = Color(0xFF4A7C59);
  static const greenLight = Color(0xFFE8F5ED);
  static const brown = Color(0xFF8B6F47);
  static const beige = Color(0xFFF0E8D8);
  static const white = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1C1410);
  static const textMid = Color(0xFF6B5B45);
  static const textLight = Color(0xFF9B8B75);
  static const border = Color(0xFFE8DDD0);
  static const surface = Color(0xFFFDF9F5);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rose,
        primary: AppColors.rose,
        secondary: AppColors.green,
        surface: AppColors.cream,
      ),
      textTheme: GoogleFonts.dmSerifDisplayTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 42, color: AppColors.textDark),
        displayMedium: GoogleFonts.dmSerifDisplay(fontSize: 34, color: AppColors.textDark),
        headlineLarge: GoogleFonts.dmSerifDisplay(fontSize: 28, color: AppColors.textDark),
        headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 22, color: AppColors.textDark),
        titleLarge: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textDark),
        titleMedium: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMid, height: 1.6),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textMid, height: 1.5),
        bodySmall: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textLight),
        labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSerifDisplay(fontSize: 20, color: AppColors.textDark),
        iconTheme: const IconThemeData(color: AppColors.textDark, size: 22),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rose,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rose,
          side: const BorderSide(color: AppColors.rose, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.rose, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
        labelStyle: GoogleFonts.dmSans(color: AppColors.textLight, fontSize: 14),
        hintStyle: GoogleFonts.dmSans(color: AppColors.textLight.withOpacity(0.6), fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.border)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.rose,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 0.5),
    );
  }
}
