import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';
import '../providers/results_provider.dart';
import '../widgets/section_card.dart';
import '../widgets/feature_bar.dart';
import '../widgets/glowup_section.dart';
import '../widgets/celeb_section.dart';
import '../widgets/ai_insights_section.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/noise_bg.dart';
import '../widgets/face_blueprint.dart';

class SummaryScreen extends ConsumerWidget {
  final ScanResult result;
  const SummaryScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cl = Cl.of(context);
    final openSection = ref.watch(openSectionProvider);
    final historyAsync = ref.watch(scanHistoryProvider);
    final allTimeMax   = historyAsync.when(
      data: (scans) => scans.isEmpty ? result.score : scans.map((s) => s.score).reduce(max),
      loading: () => null,
      error: (_, __) => null,
    );
    final isPB = allTimeMax != null && result.score >= allTimeMax;

    final dateStr  = DateFormat('d MMM yyyy').format(result.createdAt);
    final scanCount = historyAsync.when(data: (scans) => scans.length, loading: () => 0, error: (_, __) => 0);

    void toggleSection(int index) {
      HapticFeedback.selectionClick();
      ref.read(openSectionProvider.notifier).state = openSection == index ? null : index;
    }

    final heroGradientColors = cl.isDark
        ? const [Color(0xFF2A1F40), Color(0xFF1A1525)]
        : [cl.accentDim, cl.surface];

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Masthead(
              left: EyebrowText('Scan #${scanCount.toString().padLeft(3, '0')}'),
              right: EyebrowText(dateStr.toUpperCase()),
              onBack: () => context.canPop() ? context.pop() : context.go('/home'),
            ),
            Expanded(
              child: Stack(
                children: [
                  NoiseBg(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      children: [
                        const SizedBox(height: 24),

                        // Score hero card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: heroGradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.large),
                            boxShadow: cl.buttonShadow,
                            border: Border.all(color: cl.accent.withValues(alpha: 0.2), width: 1),
                          ),
                          child: Column(
                            children: [
                              EyebrowText.accent('Your score', textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result.score.toStringAsFixed(1),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 80, fontWeight: FontWeight.w800,
                                      color: cl.accent, height: 1, letterSpacing: -2,
                                    ),
                                  ),
                                  if (isPB) ...[
                                    const SizedBox(width: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: cl.teal.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(AppRadius.pill),
                                          border: Border.all(color: cl.teal, width: 0.5),
                                        ),
                                        child: EyebrowText.teal('New PB'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _TierChip(score: result.score),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: cl.teal.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                      border: Border.all(color: cl.teal.withValues(alpha: 0.4), width: 0.5),
                                    ),
                                    child: EyebrowText.teal('Top ${100 - result.percentile}% globally'),
                                  ),
                                ],
                              ),
                              if (result.delta != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  '${result.delta! >= 0 ? '↑' : '↓'} ${result.delta!.abs().toStringAsFixed(1)} from your last scan',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13, fontWeight: FontWeight.w500,
                                    color: result.delta! >= 0 ? cl.teal : cl.scoreDown,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // What changed
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cl.surface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            boxShadow: cl.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EyebrowText.accent(result.whatChanged != null ? 'What changed' : 'First reading'),
                              const SizedBox(height: 8),
                              Text(
                                result.whatChanged ??
                                    'Your baseline is set. Each scan from here is measured against this one.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14, color: cl.inkMuted, height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Archetype pills
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: [result.archetype, result.faceShape, if (result.strengths.isNotEmpty) result.strengths.first]
                              .map((p) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: cl.accentDim,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(p,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12, fontWeight: FontWeight.w500,
                                          color: cl.accent,
                                        )),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),

                        // Face blueprint
                        Container(
                          decoration: BoxDecoration(
                            color: cl.surface,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            boxShadow: cl.cardShadow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FaceBlueprint(
                            features: result.features,
                            goldenRatioScore: result.goldenRatioScore,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Expandable sections
                        SectionCard(
                          icon: Icons.face_rounded,
                          iconColor: cl.accent,
                          title: 'Facial Features',
                          summary: '6 features',
                          isOpen: openSection == 0,
                          onTap: () => toggleSection(0),
                          child: Column(
                            children: [
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 3.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 4,
                                children: result.features.entries
                                    .map((e) => FeatureBar(name: e.key, score: e.value.score))
                                    .toList(),
                              ),
                              if (result.goldenRatioScore > 0) ...[
                                const SizedBox(height: 8),
                                FeatureBar(name: 'Golden Ratio', score: result.goldenRatioScore),
                              ],
                            ],
                          ),
                        ),
                        SectionCard(
                          icon: Icons.auto_awesome_rounded,
                          iconColor: cl.teal,
                          title: 'Glow-Up Plan',
                          summary: '${result.skincareRoutine.length + result.haircutRecommendations.length + (result.beardTips.isNotEmpty ? 1 : 0)} tips',
                          isOpen: openSection == 1,
                          onTap: () => toggleSection(1),
                          child: GlowupSection(result: result),
                        ),
                        SectionCard(
                          icon: Icons.tips_and_updates_rounded,
                          iconColor: cl.accent,
                          title: 'Feature Tips',
                          summary: '${result.featureTips.length} features',
                          isOpen: openSection == 2,
                          onTap: () => toggleSection(2),
                          child: FeatureTipsSection(result: result),
                        ),
                        SectionCard(
                          icon: Icons.star_rounded,
                          iconColor: cl.legendary,
                          title: 'Celebrity Match',
                          summary: '${result.celebrityLookalike.matchPercentage}%',
                          isOpen: openSection == 3,
                          onTap: () => toggleSection(3),
                          child: CelebSection(result: result),
                        ),
                        SectionCard(
                          icon: Icons.lightbulb_rounded,
                          iconColor: cl.blush,
                          title: 'AI Insights',
                          summary: '3 unlocked',
                          isOpen: openSection == 4,
                          onTap: () => toggleSection(4),
                          child: AiInsightsSection(result: result),
                        ),
                      ],
                    ),
                  ),

                  // Fixed bottom actions
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cl.canvas,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: cl.isDark ? 0.3 : 0.1),
                            blurRadius: 16, offset: const Offset(0, -4)),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/score-card', extra: result);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: cl.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                  boxShadow: cl.subtleShadow,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Save',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: cl.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                final isGuest = ref.read(authStateProvider).value == null;
                                if (!result.animal.isFree && isGuest) {
                                  context.push('/paywall');
                                } else {
                                  context.push('/animal-reveal', extra: result);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: cl.accent,
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                  boxShadow: cl.buttonShadow,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${result.animal.emoji}  Reveal archetype',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: cl.canvas,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  final double score;
  const _TierChip({required this.score});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final (label, color) = score >= 8.5
        ? ('Legendary', cl.legendary)
        : score >= 7.0
            ? ('Top Tier', cl.accent)
            : score >= 5.0
                ? ('Solid', cl.teal)
                : ('Brutal', cl.scoreDown);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: color,
        ),
      ),
    );
  }
}
