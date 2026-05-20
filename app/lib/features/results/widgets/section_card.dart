import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String summary;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget child;

  const SectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.summary,
    required this.isOpen,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: cl.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cl.rule, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                          style: GoogleFonts.dmSans(
                            fontSize: 14, fontWeight: FontWeight.w600, color: cl.ink)),
                        Text(summary,
                          style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.chevron_right, color: cl.inkMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: child,
            ),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
