import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';

class CelebSection extends StatelessWidget {
  final ScanResult result;

  const CelebSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final celeb = result.celebrityLookalike;
    final character = result.fictionalCharacter;

    return Column(
      children: [
        _MatchRow(
          icon: Icons.person,
          label: 'Celebrity lookalike',
          name: celeb.name,
          detail: celeb.reason,
          percentage: celeb.matchPercentage,
          color: AppColors.pink,
        ),
        const SizedBox(height: 10),
        _MatchRow(
          icon: Icons.movie,
          label: character.franchise,
          name: character.name,
          detail: character.reason,
          percentage: character.matchPercentage,
          color: AppColors.amber,
        ),
      ],
    );
  }
}

class _MatchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final String detail;
  final int percentage;
  final Color color;

  const _MatchRow({
    required this.icon,
    required this.label,
    required this.name,
    required this.detail,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Text(name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(detail,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%',
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
