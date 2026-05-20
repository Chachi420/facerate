import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class InkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool wide;

  const InkButton(this.label, {super.key, this.onPressed, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.canvas,
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.canvas,
            letterSpacing: -0.01 * 15,
          ),
        ),
      ),
    );
  }
}

class RustButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool wide;

  const RustButton(this.label, {super.key, this.onPressed, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: const Color(0xFFF4F0E8),
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.03 * 13,
            color: const Color(0xFFF4F0E8),
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool wide;

  const OutlineButton(this.label, {super.key, this.onPressed, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: wide ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.ink,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: AppColors.inkWhisper, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}
