import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FeatureBar extends StatelessWidget {
  final String name;
  final double score;

  const FeatureBar({super.key, required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.toUpperCase(),
                  style: TextStyle(color: cl.inkMuted, fontSize: 9, letterSpacing: 0.8)),
              Text(score.toStringAsFixed(1),
                  style: TextStyle(color: cl.ink, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 10.0,
              backgroundColor: cl.surfaceH,
              valueColor: AlwaysStoppedAnimation(cl.accent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
