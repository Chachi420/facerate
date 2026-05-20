import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class MirrorWordmark extends StatelessWidget {
  final double size;
  const MirrorWordmark({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Text(
      'mirror',
      style: GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: cl.ink,
        letterSpacing: -0.02 * size,
      ),
    );
  }
}
