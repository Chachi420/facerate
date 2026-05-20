import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';
import '../providers/history_provider.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/folio_nav.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cl = Cl.of(context);
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Masthead(
              left: const EyebrowText('Archive'),
              right: const EyebrowText('All scans'),
            ),
            Expanded(
              child: historyAsync.when(
                data: (scans) {
                  if (scans.isEmpty) return const _EmptyState();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: scans.length,
                    itemBuilder: (context, i) {
                      final scan = scans[i];
                      final prev = i + 1 < scans.length ? scans[i + 1] : null;
                      return _ScanCard(scan: scan, previous: prev);
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: cl.accent, strokeWidth: 1),
                ),
                error: (_, __) => Center(child: EyebrowText.muted('Could not load history')),
              ),
            ),
            FolioNav(
              currentIndex: 1,
              onTap: (i) {
                final routes = ['/', '/history', '/pokedex', '/settings'];
                if (i < routes.length) context.go(routes[i]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scan card ─────────────────────────────────────────────────────────
class _ScanCard extends StatefulWidget {
  final ScanResult scan;
  final ScanResult? previous;

  const _ScanCard({required this.scan, this.previous});

  @override
  State<_ScanCard> createState() => _ScanCardState();
}

class _ScanCardState extends State<_ScanCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final delta = widget.previous != null ? widget.scan.score - widget.previous!.score : null;
    final animalColor = cl.rarityColor(widget.scan.animal.rarity);
    final dateStr = DateFormat('d MMM yyyy').format(widget.scan.createdAt);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _expanded = !_expanded);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cl.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: _expanded
                ? animalColor.withValues(alpha: 0.35)
                : cl.rule,
            width: _expanded ? 1.0 : 0.5,
          ),
          boxShadow: _expanded
              ? [
                  BoxShadow(
                    color: animalColor.withValues(alpha: cl.isDark ? 0.12 : 0.08),
                    blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: cl.isDark ? 0.25 : 0.06),
                    blurRadius: 8, offset: const Offset(0, 2),
                  ),
                ]
              : cl.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Column(
            children: [
              // ── Collapsed header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animal badge
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: animalColor.withValues(alpha: cl.isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: animalColor.withValues(alpha: 0.3), width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: animalColor.withValues(alpha: 0.15),
                            blurRadius: 10, offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(widget.scan.animal.emoji,
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name + rarity + date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: animalColor.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: animalColor.withValues(alpha: 0.4),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  widget.scan.animal.rarity.toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    letterSpacing: 1.4,
                                    color: animalColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                dateStr,
                                style: GoogleFonts.dmSans(
                                    fontSize: 11, color: cl.inkMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.scan.animal.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: cl.ink,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (widget.scan.archetype.isNotEmpty)
                            Text(
                              widget.scan.archetype,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12, color: cl.inkMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Score + delta + chevron
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.scan.score.toStringAsFixed(1),
                          style: GoogleFonts.dmSans(
                            fontSize: 30,
                            color: cl.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        if (delta != null && delta != 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${delta > 0 ? '↑' : '↓'} ${delta.abs().toStringAsFixed(1)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: delta > 0 ? cl.teal : cl.scoreDown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: cl.inkWhisper,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Expanded details ───────────────────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: _ExpandedDetails(
                  scan: widget.scan,
                  animalColor: animalColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Expanded inline details ────────────────────────────────────────────
class _ExpandedDetails extends StatelessWidget {
  final ScanResult scan;
  final Color animalColor;

  const _ExpandedDetails({required this.scan, required this.animalColor});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);

    final topFeatures = scan.features.entries.toList()
      ..sort((a, b) => b.value.score.compareTo(a.value.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Container(height: 0.5, color: cl.rule),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Archetype + face shape pills
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [scan.archetype, scan.faceShape]
                    .where((s) => s.isNotEmpty)
                    .map((p) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cl.accentDim,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            p,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: cl.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),

              // Top features (mini bars)
              ...topFeatures.take(4).map((e) => _MiniFeatureBar(
                    name: e.key,
                    score: e.value.score,
                    animalColor: animalColor,
                  )),

              // Vibe quote
              if (scan.vibe.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cl.surfaceH,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    '"${scan.vibe}"',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: cl.inkMuted,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),

        // View full reading button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/summary', extra: scan);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: animalColor.withValues(alpha: cl.isDark ? 0.12 : 0.08),
              border: Border(
                top: BorderSide(color: cl.rule, width: 0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View full reading',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: animalColor,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(Icons.arrow_forward_rounded, size: 14, color: animalColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mini feature bar ───────────────────────────────────────────────────
class _MiniFeatureBar extends StatelessWidget {
  final String name;
  final double score;
  final Color animalColor;

  const _MiniFeatureBar({
    required this.name,
    required this.score,
    required this.animalColor,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              _capitalize(name),
              style: GoogleFonts.dmSans(fontSize: 11, color: cl.inkMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score / 10.0,
                backgroundColor: cl.surfaceH,
                valueColor:
                    AlwaysStoppedAnimation(animalColor.withValues(alpha: 0.75)),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              score.toStringAsFixed(1),
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cl.ink,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Empty state ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No scans yet.',
              style: GoogleFonts.dmSans(fontSize: 22, color: cl.ink)),
          const SizedBox(height: 8),
          EyebrowText.muted('Scan your face to begin.'),
        ],
      ),
    );
  }
}
