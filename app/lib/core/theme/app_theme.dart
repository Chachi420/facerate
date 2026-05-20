import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Dark-mode candy palette ──────────────────────────────────────────
class AppColors {
  static const Color canvas          = Color(0xFF0A0514);
  static const Color surface         = Color(0xFF160C22);
  static const Color surfaceElevated = Color(0xFF221533);
  static const Color ink             = Color(0xFFF3E8FF);
  static const Color inkMuted        = Color(0x8FF3E8FF);
  static const Color inkWhisper      = Color(0x40F3E8FF);
  static const Color rule            = Color(0x18F3E8FF);
  static const Color accent          = Color(0xFFE040FB);
  static const Color accentDeep      = Color(0xFFAA00FF);
  static const Color accentDim       = Color(0x2EE040FB);
  static const Color blush           = Color(0xFFFF4081);
  static const Color blushDim        = Color(0x2EFF4081);
  static const Color teal            = Color(0xFF1DE9B6);
  static const Color signalGreen     = Color(0xFF00E676);
  static const Color scoreUp         = Color(0xFF1DE9B6);
  static const Color scoreDown       = Color(0xFFFF1744);
  static const Color legendary       = Color(0xFFFFD740);
  static const Color epic            = Color(0xFFFF4081);
  static const Color rare            = Color(0xFF7C4DFF);
  static const Color uncommon        = Color(0xFF1DE9B6);
  static const Color common          = Color(0xFF9E9E9E);

  // Backward-compat aliases
  static const Color bg            = canvas;
  static const Color border        = rule;
  static const Color purple        = accent;
  static const Color purpleLight   = Color(0xFFF0ABFC);
  static const Color tealLight     = teal;
  static const Color amber         = legendary;
  static const Color pink          = blush;
  static const Color red           = scoreDown;
  static const Color textPrimary   = ink;
  static const Color textSecondary = inkMuted;
  static const Color textMuted     = inkWhisper;
  static const Color textDim       = Color(0x28F3E8FF);
  static const Color surface2      = surfaceElevated;

  static Color rarityColor(String rarity) => switch (rarity.toLowerCase()) {
    'legendary' => legendary,
    'epic'      => epic,
    'rare'      => rare,
    'uncommon'  => uncommon,
    _           => common,
  };

  static int rarityDots(String rarity) => switch (rarity.toLowerCase()) {
    'legendary' => 5,
    'epic'      => 4,
    'rare'      => 3,
    'uncommon'  => 2,
    _           => 1,
  };

  // Light-mode rarity colors delegated from AppColorsLight
  static Color rarityColorLight(String rarity) => AppColorsLight.rarityColor(rarity);

  static int rarityTopPercent(String rarity) => switch (rarity.toLowerCase()) {
    'legendary' => 2,
    'epic'      => 8,
    'rare'      => 20,
    'uncommon'  => 30,
    _           => 40,
  };
}

// ── Light-mode pastel palette ────────────────────────────────────────
class AppColorsLight {
  static const Color canvas           = Color(0xFFFEF7FF); // M3 background
  static const Color surface          = Color(0xFFFEF7FF);
  static const Color surfaceVariant   = Color(0xFFE7DEF7); // tonal lavender
  static const Color surfaceElevated  = Color(0xFFEDE8F5);
  static const Color ink              = Color(0xFF1C1B1F);
  static const Color inkMuted         = Color(0xFF49454F);
  static const Color inkWhisper       = Color(0xFF79747E);
  static const Color rule             = Color(0xFFCAC4D0);
  static const Color accent           = Color(0xFF7C4DFF); // brand purple
  static const Color accentContainer  = Color(0xFFEADDFF); // pastel lavender
  static const Color accentOnContainer= Color(0xFF21005D);
  static const Color accentDim        = Color(0x2E7C4DFF);
  static const Color blush            = Color(0xFFAD1457); // deep pink
  static const Color blushContainer   = Color(0xFFFFD8E4); // pastel pink
  static const Color teal             = Color(0xFF00695C); // dark teal
  static const Color tealContainer    = Color(0xFFBEF8EC); // pastel teal
  static const Color signalGreen      = Color(0xFF00897B);
  static const Color scoreUp          = Color(0xFF00695C);
  static const Color scoreDown        = Color(0xFFB71C1C);

  static Color rarityColor(String rarity) => switch (rarity.toLowerCase()) {
    'legendary' => const Color(0xFFF57C00),
    'epic'      => const Color(0xFFAD1457),
    'rare'      => const Color(0xFF7C4DFF),
    'uncommon'  => const Color(0xFF00695C),
    _           => const Color(0xFF9E9E9E),
  };
}

// ── Shape radii (Material 3 scale) ──────────────────────────────────
class AppRadius {
  static const double small  = 8.0;   // chips, badges
  static const double card   = 16.0;  // standard cards (M3 large)
  static const double large  = 28.0;  // hero cards, bottom sheets (M3 extra-large)
  static const double pill   = 100.0; // pills, full-round
  static const double circle = 50.0;
}

// ── Shadows ──────────────────────────────────────────────────────────
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x30E040FB), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x33000000), blurRadius: 6,  offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> button = [
    BoxShadow(color: Color(0x50E040FB), blurRadius: 14, offset: Offset(0, 5)),
    BoxShadow(color: Color(0x44000000), blurRadius: 4,  offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> subtle = [
    BoxShadow(color: Color(0x22E040FB), blurRadius: 8, offset: Offset(0, 2)),
  ];
}

// ── Text themes ──────────────────────────────────────────────────────

TextTheme _darkTextTheme() {
  final base = ThemeData.dark().textTheme;
  return GoogleFonts.dmSansTextTheme(base).copyWith(
    displayLarge:  GoogleFonts.dmSans(color: AppColors.ink, fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall:  GoogleFonts.dmSans(color: AppColors.ink, fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium:GoogleFonts.dmSans(color: AppColors.ink, fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge:    GoogleFonts.dmSans(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium:   GoogleFonts.dmSans(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w500),
    titleSmall:    GoogleFonts.dmSans(color: AppColors.ink, fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge:     GoogleFonts.dmSans(color: AppColors.ink, fontSize: 16),
    bodyMedium:    GoogleFonts.dmSans(color: AppColors.inkMuted, fontSize: 15),
    bodySmall:     GoogleFonts.dmSans(color: AppColors.inkMuted, fontSize: 13),
    labelLarge:    GoogleFonts.dmSans(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w600),
    labelMedium:   GoogleFonts.dmSans(color: AppColors.inkMuted, fontSize: 13, letterSpacing: 0.5),
    labelSmall:    GoogleFonts.dmSans(color: AppColors.inkMuted, fontSize: 12, letterSpacing: 1.2),
  );
}

TextTheme _lightTextTheme() {
  final base = ThemeData.light().textTheme;
  return GoogleFonts.dmSansTextTheme(base).copyWith(
    displayLarge:  GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 57, fontWeight: FontWeight.w400),
    displayMedium: GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall:  GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium:GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge:    GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium:   GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 18, fontWeight: FontWeight.w500),
    titleSmall:    GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge:     GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 16),
    bodyMedium:    GoogleFonts.dmSans(color: AppColorsLight.inkMuted, fontSize: 15),
    bodySmall:     GoogleFonts.dmSans(color: AppColorsLight.inkMuted, fontSize: 13),
    labelLarge:    GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 15, fontWeight: FontWeight.w600),
    labelMedium:   GoogleFonts.dmSans(color: AppColorsLight.inkMuted, fontSize: 13, letterSpacing: 0.5),
    labelSmall:    GoogleFonts.dmSans(color: AppColorsLight.inkMuted, fontSize: 12, letterSpacing: 1.2),
  );
}

// ── Dark theme (candy Material 3) ───────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.dark(
      primary:              AppColors.accent,
      onPrimary:            Colors.black,
      primaryContainer:     Color(0xFF3D1050),
      onPrimaryContainer:   Color(0xFFF9ABFF),
      secondary:            AppColors.blush,
      onSecondary:          Colors.black,
      secondaryContainer:   Color(0xFF4B0028),
      onSecondaryContainer: Color(0xFFFFB2C8),
      tertiary:             AppColors.teal,
      onTertiary:           Colors.black,
      tertiaryContainer:    Color(0xFF003C30),
      onTertiaryContainer:  Color(0xFF6FF7DD),
      surface:              AppColors.surface,
      onSurface:            AppColors.ink,
      surfaceContainerHighest: AppColors.surfaceElevated,
      onSurfaceVariant:     AppColors.inkMuted,
      outline:              AppColors.rule,
      outlineVariant:       AppColors.inkWhisper,
      error:                AppColors.scoreDown,
      onError:              Colors.black,
    ),
    textTheme: _darkTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      titleTextStyle: GoogleFonts.dmSans(
        color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        shadowColor: const Color(0x50E040FB),
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.inkWhisper, width: 1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.rule, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.rule, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(color: AppColors.inkWhisper, fontSize: 16),
      labelStyle: GoogleFonts.dmSans(color: AppColors.inkMuted, fontSize: 16),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.inkWhisper),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.accentDim
            : AppColors.surfaceElevated),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accentDim,
      labelStyle: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 14),
      side: const BorderSide(color: AppColors.rule, width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small)),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card)),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.inkMuted,
      titleTextStyle: GoogleFonts.dmSans(color: AppColors.ink, fontSize: 16),
      subtitleTextStyle:
          GoogleFonts.dmSans(color: AppColors.inkMuted, fontSize: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small)),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.rule, thickness: 0.5, space: 0),
  );
}

// ── Light theme (pastel Material 3) ─────────────────────────────────
ThemeData buildLightAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorsLight.canvas,
    colorScheme: const ColorScheme.light(
      primary:              AppColorsLight.accent,
      onPrimary:            Colors.white,
      primaryContainer:     AppColorsLight.accentContainer,
      onPrimaryContainer:   AppColorsLight.accentOnContainer,
      secondary:            Color(0xFF9C27B0),
      onSecondary:          Colors.white,
      secondaryContainer:   Color(0xFFF3E8FF),
      onSecondaryContainer: Color(0xFF4A148C),
      tertiary:             AppColorsLight.teal,
      onTertiary:           Colors.white,
      tertiaryContainer:    AppColorsLight.tealContainer,
      onTertiaryContainer:  Color(0xFF00251A),
      surface:              AppColorsLight.surface,
      onSurface:            AppColorsLight.ink,
      surfaceContainerHighest: AppColorsLight.surfaceVariant,
      onSurfaceVariant:     AppColorsLight.inkMuted,
      outline:              AppColorsLight.rule,
      outlineVariant:       Color(0xFFD4C9E4),
      error:                AppColorsLight.scoreDown,
      onError:              Colors.white,
    ),
    textTheme: _lightTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsLight.canvas,
      surfaceTintColor: AppColorsLight.accentContainer,
      elevation: 0,
      scrolledUnderElevation: 1,
      iconTheme: const IconThemeData(color: AppColorsLight.ink, size: 22),
      titleTextStyle: GoogleFonts.dmSans(
        color: AppColorsLight.ink, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsLight.accent,
        side: const BorderSide(color: AppColorsLight.accent, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsLight.surfaceVariant.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColorsLight.rule, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(color: AppColorsLight.rule, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide:
            const BorderSide(color: AppColorsLight.accent, width: 2),
      ),
      hintStyle:
          GoogleFonts.dmSans(color: AppColorsLight.inkWhisper, fontSize: 16),
      labelStyle:
          GoogleFonts.dmSans(color: AppColorsLight.inkMuted, fontSize: 16),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColorsLight.accent
            : AppColorsLight.inkWhisper),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColorsLight.accentContainer
            : AppColorsLight.surfaceVariant),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsLight.surfaceVariant,
      selectedColor: AppColorsLight.accentContainer,
      labelStyle: GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 14),
      side: const BorderSide(color: AppColorsLight.rule, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small)),
    ),
    cardTheme: CardThemeData(
      color: AppColorsLight.surfaceElevated,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card)),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColorsLight.inkMuted,
      titleTextStyle:
          GoogleFonts.dmSans(color: AppColorsLight.ink, fontSize: 16),
      subtitleTextStyle:
          GoogleFonts.dmSans(color: AppColorsLight.inkMuted, fontSize: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small)),
    ),
    dividerTheme: const DividerThemeData(
        color: AppColorsLight.rule, thickness: 1, space: 0),
  );
}

// ── Context-aware color resolver ─────────────────────────────────────
/// Usage: `final cl = Cl.of(context);` then `cl.canvas`, `cl.surface`, etc.
class Cl {
  final bool isDark;
  const Cl._(this.isDark);
  factory Cl.of(BuildContext context) =>
      Cl._(Theme.of(context).brightness == Brightness.dark);

  Color get canvas     => isDark ? AppColors.canvas         : AppColorsLight.canvas;
  Color get surface    => isDark ? AppColors.surface        : Colors.white;
  Color get surfaceH   => isDark ? AppColors.surfaceElevated: AppColorsLight.surfaceElevated;
  Color get ink        => isDark ? AppColors.ink            : AppColorsLight.ink;
  Color get inkMuted   => isDark ? AppColors.inkMuted       : AppColorsLight.inkMuted;
  Color get inkWhisper => isDark ? AppColors.inkWhisper     : AppColorsLight.inkWhisper;
  Color get rule       => isDark ? AppColors.rule           : AppColorsLight.rule;
  Color get accent     => isDark ? AppColors.accent         : AppColorsLight.accent;
  Color get accentDim  => isDark ? AppColors.accentDim      : AppColorsLight.accentDim;
  Color get teal       => isDark ? AppColors.teal           : AppColorsLight.teal;
  Color get blush      => isDark ? AppColors.blush          : AppColorsLight.blush;
  Color get scoreDown  => isDark ? AppColors.scoreDown      : AppColorsLight.scoreDown;
  Color get scoreUp    => isDark ? AppColors.scoreUp        : AppColorsLight.scoreUp;
  Color get legendary  => isDark ? AppColors.legendary      : const Color(0xFFF57C00);
  Color get epic       => isDark ? AppColors.epic           : AppColorsLight.blush;
  Color get rare       => isDark ? AppColors.rare           : AppColorsLight.accent;
  Color get uncommon   => isDark ? AppColors.uncommon       : AppColorsLight.teal;
  Color get common     => isDark ? AppColors.common         : const Color(0xFF9E9E9E);

  Color rarityColor(String rarity) => switch (rarity.toLowerCase()) {
    'legendary' => legendary,
    'epic'      => epic,
    'rare'      => rare,
    'uncommon'  => uncommon,
    _           => common,
  };

  List<BoxShadow> get cardShadow => isDark
      ? AppShadows.card
      : const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 3)),
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ];

  List<BoxShadow> get subtleShadow => isDark
      ? AppShadows.subtle
      : const [
          BoxShadow(color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 2)),
        ];

  List<BoxShadow> get buttonShadow => isDark
      ? AppShadows.button
      : const [
          BoxShadow(color: Color(0x307C4DFF), blurRadius: 12, offset: Offset(0, 5)),
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
        ];
}
