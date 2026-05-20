import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

enum _EyebrowKind { muted, accent, teal, ink }

class EyebrowText extends StatelessWidget {
  final String text;
  final Color? _explicit;
  final _EyebrowKind _kind;
  final TextAlign? textAlign;

  const EyebrowText(this.text, {super.key, Color? color, this.textAlign})
      : _explicit = color,
        _kind = _EyebrowKind.muted;

  const EyebrowText.accent(this.text, {super.key, this.textAlign})
      : _explicit = null,
        _kind = _EyebrowKind.accent;

  const EyebrowText.teal(this.text, {super.key, this.textAlign})
      : _explicit = null,
        _kind = _EyebrowKind.teal;

  const EyebrowText.muted(this.text, {super.key, this.textAlign})
      : _explicit = null,
        _kind = _EyebrowKind.muted;

  const EyebrowText.ink(this.text, {super.key, this.textAlign})
      : _explicit = null,
        _kind = _EyebrowKind.ink;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (_explicit != null) {
      color = _explicit!;
    } else {
      final cl = Cl.of(context);
      color = switch (_kind) {
        _EyebrowKind.accent => cl.accent,
        _EyebrowKind.teal   => cl.teal,
        _EyebrowKind.ink    => cl.ink,
        _EyebrowKind.muted  => cl.inkMuted,
      };
    }
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
        color: color,
      ),
    );
  }
}
