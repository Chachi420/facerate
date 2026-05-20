import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class FolioNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const FolioNav({super.key, required this.currentIndex, required this.onTap});

  static const _labels = ['Home', 'History', 'Bestiary', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.history_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      color: cl.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_labels.length, (i) {
              final active = currentIndex == i;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(i);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? cl.accentDim : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[i],
                        size: 20,
                        color: active ? cl.accent : cl.inkMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _labels[i],
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          color: active ? cl.accent : cl.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
