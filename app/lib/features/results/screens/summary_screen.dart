import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class SummaryScreen extends ConsumerWidget {
  final ScanResult result;

  const SummaryScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openSection = ref.watch(openSectionProvider);
    final userAsync = ref.watch(currentUserProfileStreamProvider);
    final credits = userAsync.when(data: (u) => u?.credits ?? 0, loading: () => 0, error: (_, __) => 0);

    final historyAsync = ref.watch(scanHistoryProvider);
    final previousScore = historyAsync.when(
      data: (scans) {
        final others = scans.where((s) => s.scanId != result.scanId).toList();
        return others.isEmpty ? null : others.first.score;
      },
      loading: () => null,
      error: (_, __) => null,
    );
    final allTimeMax = historyAsync.when(
      data: (scans) => scans.isEmpty ? result.score : scans.map((s) => s.score).reduce(max),
      loading: () => null,
      error: (_, __) => null,
    );
    final delta = previousScore != null ? result.score - previousScore : null;
    final isPB = allTimeMax != null && result.score >= allTimeMax;

    void toggleSection(int index) {
      ref.read(openSectionProvider.notifier).state = openSection == index ? null : index;
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Your analysis'),
        actions: [
          GestureDetector(
            onTap: () => context.push('/score-card', extra: result),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text('Share', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            children: [
              // Hero row
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(text: result.score.toStringAsFixed(1),
                                    style: const TextStyle(color: AppColors.purpleLight)),
                                const TextSpan(text: '/10',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: 20)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          _ScoreBadge(score: result.score),
                          if (delta != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(delta >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 12, color: delta >= 0 ? AppColors.teal : AppColors.red),
                                const SizedBox(width: 2),
                                Text('${delta.abs().toStringAsFixed(1)} from last',
                                    style: TextStyle(color: delta >= 0 ? AppColors.teal : AppColors.red, fontSize: 11)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(width: 1, height: 50, color: AppColors.border),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Top ${result.percentile}%',
                              style: const TextStyle(color: AppColors.tealLight, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('of all users this week',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          if (isPB) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: AppColors.amber.withValues(alpha: 0.5), width: 0.5),
                              ),
                              child: const Text('🏆 New PB', style: TextStyle(color: AppColors.amber, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Archetype pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [result.archetype, result.faceShape, if (result.strengths.isNotEmpty) result.strengths.first]
                    .map((p) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.purple.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: Text(p, style: const TextStyle(color: AppColors.purpleLight, fontSize: 12)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Section 1: Face score breakdown
              SectionCard(
                icon: Icons.face,
                iconColor: AppColors.purple,
                title: 'Face score breakdown',
                summary: '6 features analyzed',
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
                      children: result.features.entries.map((e) {
                        return FeatureBar(name: e.key, score: e.value.score);
                      }).toList(),
                    ),
                    if (result.goldenRatioScore > 0) ...[
                      const SizedBox(height: 8),
                      FeatureBar(name: 'Golden Ratio', score: result.goldenRatioScore),
                    ],
                  ],
                ),
              ),
              // Section 2: Glow-up plan
              SectionCard(
                icon: Icons.auto_awesome,
                iconColor: AppColors.teal,
                title: 'Glow-up plan',
                summary: '6 tips',
                isOpen: openSection == 1,
                onTap: () => toggleSection(1),
                child: GlowupSection(result: result),
              ),
              // Section 3: Celeb & character match
              SectionCard(
                icon: Icons.star,
                iconColor: AppColors.pink,
                title: 'Celeb & character match',
                summary: '${result.celebrityLookalike.matchPercentage}% match',
                isOpen: openSection == 2,
                onTap: () => toggleSection(2),
                child: CelebSection(result: result),
              ),
              // Section 4: AI insights
              SectionCard(
                icon: Icons.lightbulb_outline,
                iconColor: AppColors.amber,
                title: 'AI insights',
                summary: '3 unlocked',
                isOpen: openSection == 3,
                onTap: () => toggleSection(3),
                child: AiInsightsSection(result: result),
              ),
            ],
          ),
          // Fixed bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.bg,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final isFree = result.animal.isFree;
                    if (!isFree && credits < 5) {
                      context.push('/paywall');
                    } else {
                      context.push('/animal-reveal', extra: result);
                    }
                  },
                  child: Text('${result.animal.emoji} Reveal your animal match →'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final (emoji, label, color) = score >= 8.5
        ? ('👑', 'Legendary', AppColors.amber)
        : score >= 7.0
            ? ('🔥', 'Top Tier', AppColors.purple)
            : score >= 5.0
                ? ('😤', 'Solid', AppColors.teal)
                : ('💀', 'Brutal', AppColors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text('$emoji $label', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
