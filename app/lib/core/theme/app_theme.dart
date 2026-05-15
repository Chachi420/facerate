import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF07070F);
  static const surface = Color(0xFF0F0D1A);
  static const surface2 = Color(0xFF111120);
  static const border = Color(0xFF1E1E2E);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFC084FC);
  static const teal = Color(0xFF1D9E75);
  static const tealLight = Color(0xFF5DCAA5);
  static const amber = Color(0xFFEF9F27);
  static const pink = Color(0xFFED93B1);
  static const red = Color(0xFFE24B4A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAAAAAA);
  static const textMuted = Color(0xFF555555);
  static const textDim = Color(0xFF333333);
  static const common = Color(0xFF888780);
  static const uncommon = Color(0xFF5DCAA5);
  static const rare = Color(0xFF7C3AED);
  static const epic = Color(0xFFED93B1);
  static const legendary = Color(0xFFEF9F27);

  static Color rarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return legendary;
      case 'epic':
        return epic;
      case 'rare':
        return rare;
      case 'uncommon':
        return uncommon;
      default:
        return common;
    }
  }

  static int rarityDots(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 5;
      case 'epic':
        return 4;
      case 'rare':
        return 3;
      case 'uncommon':
        return 2;
      default:
        return 1;
    }
  }

  static int rarityTopPercent(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 2;
      case 'epic':
        return 8;
      case 'rare':
        return 20;
      case 'uncommon':
        return 30;
      default:
        return 40;
    }
  }
}

class AppRadius {
  static const card = 16.0;
  static const pill = 20.0;
  static const circle = 50.0;
  static const small = 10.0;
  static const large = 22.0;
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.teal,
      surface: AppColors.surface,
      background: AppColors.bg,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: const BorderSide(color: AppColors.purple, width: 1),
      ),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}
