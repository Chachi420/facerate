import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';

class GlowupSection extends StatelessWidget {
  final ScanResult result;

  const GlowupSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final tips = [
      if (result.haircutRecommendations.isNotEmpty) result.haircutRecommendations.first,
      result.beardTips,
      if (result.skincareRoutine.isNotEmpty) result.skincareRoutine.first,
      if (result.glassesFrames.isNotEmpty) result.glassesFrames.first,
      result.collarTips,
      'Daily SPF 50 to protect and maintain skin quality.',
    ].where((t) => t.isNotEmpty).toList();

    return Column(
      children: tips
          .map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.purple),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tip,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
