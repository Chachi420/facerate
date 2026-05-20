import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';

class GlowupSection extends StatelessWidget {
  final ScanResult result;
  const GlowupSection({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.skinType.isNotEmpty) ...[
          _SkinTypeBadge(skinType: result.skinType),
          const SizedBox(height: 16),
        ],

        // Skincare
        if (result.skincareRoutine.isNotEmpty) ...[
          _TipGroup(
            icon: Icons.water_drop_rounded,
            label: 'Skincare Routine',
            color: cl.teal,
            tips: result.skincareRoutine,
          ),
          const SizedBox(height: 14),
        ],

        // Haircut + glasses + collar
        () {
          final styleTips = [
            ...result.haircutRecommendations,
            ...result.glassesFrames.map((f) => 'Glasses: $f'),
            if (result.collarTips.isNotEmpty) result.collarTips,
          ].where((t) => t.isNotEmpty).toList();
          if (styleTips.isEmpty) return const SizedBox.shrink();
          return _TipGroup(
            icon: Icons.style_rounded,
            label: 'Style',
            color: cl.accent,
            tips: styleTips,
          );
        }(),

        // Grooming / beard
        if (result.beardTips.isNotEmpty) ...[
          const SizedBox(height: 14),
          _TipGroup(
            icon: Icons.face_rounded,
            label: 'Grooming',
            color: cl.blush,
            tips: [result.beardTips],
          ),
        ],
      ],
    );
  }
}

class FeatureTipsSection extends StatelessWidget {
  final ScanResult result;
  const FeatureTipsSection({super.key, required this.result});

  static const _featureOrder = [
    'skin', 'jawline', 'eyes', 'nose', 'lips', 'forehead',
  ];

  static const _featureIcons = {
    'skin': Icons.blur_circular_rounded,
    'jawline': Icons.crop_rounded,
    'eyes': Icons.visibility_rounded,
    'nose': Icons.air_rounded,
    'lips': Icons.favorite_rounded,
    'forehead': Icons.expand_less_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    if (result.featureTips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Feature tips not available for this scan.',
          style: GoogleFonts.dmSans(fontSize: 14, color: cl.inkMuted),
        ),
      );
    }

    final ordered = _featureOrder
        .where((f) => result.featureTips.containsKey(f))
        .toList();

    // Append any keys not in the fixed order
    for (final key in result.featureTips.keys) {
      if (!ordered.contains(key)) ordered.add(key);
    }

    return Column(
      children: ordered.map((feature) {
        final tips = result.featureTips[feature] ?? [];
        if (tips.isEmpty) return const SizedBox.shrink();
        final score = result.features[feature]?.score;
        final icon = _featureIcons[feature] ?? Icons.circle_rounded;
        final color = score != null
            ? (score >= 8.0
                ? cl.teal
                : score >= 6.0
                    ? cl.accent
                    : cl.blush)
            : cl.accent;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Icon(icon, size: 15, color: color),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _capitalize(feature),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cl.ink,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (score != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      score.toStringAsFixed(1),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ...tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(left: 38, bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          tip,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: cl.inkMuted,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Internal helpers ──────────────────────────────────────────────────────────

class _SkinTypeBadge extends StatelessWidget {
  final String skinType;
  const _SkinTypeBadge({required this.skinType});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final label = skinType.replaceAll('_', ' ');
    final color = _colorFor(cl, skinType);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_rounded, size: 12, color: color),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'skin type detected',
          style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted),
        ),
      ],
    );
  }

  Color _colorFor(Cl cl, String type) => switch (type) {
        'oily' => cl.teal,
        'dry' => cl.legendary,
        'combination' => cl.accent,
        'sensitive' => cl.blush,
        'acne_prone' => cl.scoreDown,
        _ => cl.accent,
      };
}

class _TipGroup extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<String> tips;
  const _TipGroup({
    required this.icon,
    required this.label,
    required this.color,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cl.ink,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(left: 38, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: cl.inkMuted,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
