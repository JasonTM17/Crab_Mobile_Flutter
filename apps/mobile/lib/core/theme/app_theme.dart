import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00B14F); // Grab green
  static const Color primaryDark = Color(0xFF008F3F);
  static const Color primaryLight = Color(0xFF4CD787);
  static const Color secondary = Color(0xFFFFB800);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);

  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderDark = Color(0xFF374151);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      textTheme:
          _textTheme(AppColors.textPrimaryLight, AppColors.textSecondaryLight),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      textTheme:
          _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge:
          TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      displayMedium:
          TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
      headlineLarge:
          TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
      headlineMedium:
          TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      titleLarge:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleMedium:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: primary),
      bodySmall: TextStyle(fontSize: 12, color: secondary),
      labelLarge:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
    );
  }
}
