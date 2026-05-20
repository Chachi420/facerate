import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';

class AiInsightsSection extends StatelessWidget {
  final ScanResult result;

  const AiInsightsSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final insights = [
      ('🕰', 'Perceived Age', '${result.perceivedAge} years'),
      ('🌍', 'Skin Tone', result.skinTone),
      ('⚡', 'Vibe', result.vibe.length > 60 ? '${result.vibe.substring(0, 60)}...' : result.vibe),
    ];

    final cl = Cl.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: insights.map((item) {
        final (emoji, label, value) = item;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cl.surfaceH,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(color: cl.rule, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                          color: cl.legendary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(value,
                    style: TextStyle(color: cl.ink, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
