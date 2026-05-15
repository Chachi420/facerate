import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FeatureBar extends StatelessWidget {
  final String name;
  final double score;

  const FeatureBar({super.key, required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name.toUpperCase(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, letterSpacing: 0.8)),
              Text(score.toStringAsFixed(1),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score / 10.0,
              backgroundColor: AppColors.surface2,
              valueColor: const AlwaysStoppedAnimation(AppColors.purple),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
