import 'package:flutter/material.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
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
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
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
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(summary,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
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
