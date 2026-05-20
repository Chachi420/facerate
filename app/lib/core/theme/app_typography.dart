import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class AppTypography {
  static TextStyle serif({
    required double size,
    bool italic = false,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle sans({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.inkMuted,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle eyebrow({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.8,
      color: color ?? AppColors.inkMuted,
    );
  }

  static TextStyle folio({Color? color}) {
    return GoogleFonts.dmSans(
      fontSize: 9,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.62,
      color: color ?? AppColors.inkWhisper,
    );
  }
}
