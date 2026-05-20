import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import 'hairline_rule.dart';

class Masthead extends StatelessWidget {
  final Widget? left;
  final Widget? right;
  final VoidCallback? onBack;

  const Masthead({super.key, this.left, this.right, this.onBack});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (onBack != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onBack!();
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: cl.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: cl.subtleShadow,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: cl.inkMuted,
                    ),
                  ),
                ),
              if (left != null) left!,
              const Spacer(),
              if (right != null) right!,
            ],
          ),
        ),
        const HairlineRule(),
      ],
    );
  }
}
