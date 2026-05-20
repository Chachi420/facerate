import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/admob_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../../models/scan_result.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/folio_nav.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/noise_bg.dart';
import '../../../widgets/mirror_wordmark.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    AdMobService.loadRewardedAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdMobService.createBannerAd()
      ..load().then((_) {
        if (mounted) setState(() => _bannerAdLoaded = true);
      });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _handleNav(int i) {
    HapticFeedback.selectionClick();
    if (i == 1) context.push('/history');
    else if (i == 2) context.push('/pokedex');
    else if (i == 3) context.push('/settings');
    else setState(() => _navIndex = 0);
  }

  void _showRankSheet(ScanResult? scan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RankSheet(scan: scan),
    );
  }

  void _showArchetypeSheet(ArchetypeStats stats) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ArchetypeDetailSheet(stats: stats),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final userAsync = ref.watch(currentUserProfileStreamProvider);
    final lastScanAsync = ref.watch(lastScanProvider);
    final archetypeStatsAsync = ref.watch(archetypeStatsProvider);

    final isPro    = userAsync.when(data: (u) => u?.isPro ?? false,  loading: () => false, error: (_, __) => false);
    final credits  = userAsync.when(data: (u) => u?.credits ?? 0,   loading: () => 0,     error: (_, __) => 0);
    final streak   = userAsync.when(data: (u) => u?.streak ?? 0,    loading: () => 0,     error: (_, __) => 0);

    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final dayLabel = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: NoiseBg(
        child: SafeArea(
          child: Column(
            children: [
              Masthead(
                left: const MirrorWordmark(size: 22),
                right: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (streak > 0) ...[
                      _StreakBadge(streak: streak),
                      const SizedBox(width: 8),
                    ],
                    _CreditsChip(
                      credits: credits,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/paywall');
                      },
                    ),
                  ],
                ),
              ),

              // ── Scrollable content ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.dmSans(
                          fontSize: 26, fontWeight: FontWeight.w700,
                          color: cl.ink, height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabel,
                        style: GoogleFonts.dmSans(fontSize: 13, color: cl.inkMuted),
                      ),
                      const SizedBox(height: 24),

                      _ScanCard(onTap: () {
                        HapticFeedback.mediumImpact();
                        context.push('/scan');
                      }),
                      const SizedBox(height: 16),

                      lastScanAsync.when(
                        data: (scan) => scan != null
                            ? _LastScanCard(
                                scan: scan,
                                onTap: () => context.push('/summary', extra: scan))
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),

                      // ── Stat cards row ──────────────────────────────
                      Row(
                        children: [
                          // Left: top archetype
                          Expanded(
                            child: archetypeStatsAsync.when(
                              data: (stats) => _ArchetypeStatCard(
                                stats: stats,
                                onTap: stats.topAnimal != null
                                    ? () {
                                        HapticFeedback.lightImpact();
                                        _showArchetypeSheet(stats);
                                      }
                                    : null,
                              ),
                              loading: () => _ArchetypeStatCard(
                                  stats: const ArchetypeStats(), onTap: null),
                              error: (_, __) => _ArchetypeStatCard(
                                  stats: const ArchetypeStats(), onTap: null),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Right: global rank
                          Expanded(
                            child: lastScanAsync.when(
                              data: (scan) => _StatCard(
                                label: 'Global rank',
                                value: scan != null ? 'Top' : '—',
                                unit: scan != null ? '${100 - scan.percentile}%' : 'scan first',
                                accent: cl.teal,
                                ruleColor: cl.rule,
                                labelColor: cl.inkMuted,
                                surface: cl.surface,
                                cardShadow: cl.cardShadow,
                                progress: scan != null ? scan.percentile / 100 : 0,
                                onTap: scan != null
                                    ? () {
                                        HapticFeedback.lightImpact();
                                        _showRankSheet(scan);
                                      }
                                    : null,
                              ),
                              loading: () => _StatCard(
                                label: 'Global rank', value: '—', unit: '',
                                accent: cl.teal, ruleColor: cl.rule,
                                labelColor: cl.inkMuted, surface: cl.surface,
                                cardShadow: cl.cardShadow, progress: 0,
                                onTap: null,
                              ),
                              error: (_, __) => _StatCard(
                                label: 'Global rank', value: '—', unit: '',
                                accent: cl.teal, ruleColor: cl.rule,
                                labelColor: cl.inkMuted, surface: cl.surface,
                                cardShadow: cl.cardShadow, progress: 0,
                                onTap: null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── Fixed "What Mirror does" — always visible ───────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What Mirror does',
                      style: GoogleFonts.dmSans(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: cl.inkMuted, letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _CompactFeatureTile(
                          icon: Icons.auto_awesome_rounded,
                          color: cl.accent,
                          label: 'Archetypes',
                          subtitle: '500+ types',
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _CompactFeatureTile(
                          icon: Icons.trending_up_rounded,
                          color: cl.teal,
                          label: 'Progress',
                          subtitle: 'Score over time',
                        )),
                        const SizedBox(width: 8),
                        Expanded(child: _CompactFeatureTile(
                          icon: Icons.face_retouching_natural_rounded,
                          color: cl.blush,
                          label: 'AI reading',
                          subtitle: 'Deep analysis',
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              if (!isPro && _bannerAdLoaded && _bannerAd != null)
                SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),

              FolioNav(currentIndex: _navIndex, onTap: _handleNav),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Good afternoon.';
    return 'Good evening.';
  }
}

// ── Streak badge ───────────────────────────────────────────────────────
class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cl.blush.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: cl.subtleShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12, height: 1)),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: cl.blush,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Credits chip ───────────────────────────────────────────────────────
class _CreditsChip extends StatelessWidget {
  final int credits;
  final VoidCallback onTap;
  const _CreditsChip({required this.credits, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: cl.accentDim,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: cl.subtleShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 12, color: cl.accent),
            const SizedBox(width: 4),
            Text(
              '$credits credits',
              style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600, color: cl.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scan card ──────────────────────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final gradientColors = cl.isDark
        ? const [Color(0xFF2A1F40), Color(0xFF1F1A2E)]
        : [const Color(0xFFEDE8F5), const Color(0xFFF5F3FF)];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: cl.buttonShadow,
          border: Border.all(color: cl.accent.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cl.accentDim,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'NEW SCAN',
                      style: GoogleFonts.dmSans(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: cl.accent, letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan your face.',
                    style: GoogleFonts.dmSans(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: cl.ink, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI-powered face analysis\nin seconds.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13, color: cl.inkMuted, height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cl.accent,
                boxShadow: cl.buttonShadow,
              ),
              child: Icon(Icons.camera_alt_rounded, color: cl.canvas, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Last scan card ─────────────────────────────────────────────────────
class _LastScanCard extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback onTap;
  const _LastScanCard({required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final delta = scan.delta;
    final timeAgo = _timeAgo(scan.createdAt);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cl.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: cl.cardShadow,
        ),
        child: Row(
          children: [
            Text(scan.animal.emoji, style: const TextStyle(fontSize: 40, height: 1)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EyebrowText.accent('Last scan · $timeAgo'),
                  const SizedBox(height: 6),
                  Text(
                    scan.animal.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 16, fontWeight: FontWeight.w600, color: cl.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scan.archetype,
                    style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  scan.score.toStringAsFixed(1),
                  style: GoogleFonts.dmSans(
                    fontSize: 32, fontWeight: FontWeight.w700,
                    color: cl.accent, height: 1,
                  ),
                ),
                if (delta != null)
                  Text(
                    '${delta >= 0 ? '↑' : '↓'} ${delta.abs().toStringAsFixed(1)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: delta >= 0 ? cl.teal : cl.scoreDown,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'just now';
  }
}

// ── Generic stat card (global rank) ────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color accent, ruleColor, labelColor, surface;
  final List<BoxShadow> cardShadow;
  final double progress;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
    required this.ruleColor,
    required this.labelColor,
    required this.surface,
    required this.cardShadow,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inkMuted = Cl.of(context).inkMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: FontWeight.w600,
                letterSpacing: 1.2, color: labelColor,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$value ',
                    style: GoogleFonts.dmSans(
                      fontSize: 22, fontWeight: FontWeight.w700, color: accent,
                    ),
                  ),
                  TextSpan(
                    text: unit,
                    style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w400, color: inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(height: 4, color: ruleColor),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(4),
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

// ── Archetype stat card ────────────────────────────────────────────────
class _ArchetypeStatCard extends StatelessWidget {
  final ArchetypeStats stats;
  final VoidCallback? onTap;

  const _ArchetypeStatCard({required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final hasAnimal = stats.topAnimal != null;
    final animalColor =
        hasAnimal ? cl.rarityColor(stats.topAnimal!.rarity) : cl.inkMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cl.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: cl.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOP ARCHETYPE',
              style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: FontWeight.w600,
                letterSpacing: 1.2, color: cl.inkMuted,
              ),
            ),
            const SizedBox(height: 8),
            if (hasAnimal) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    stats.topAnimal!.emoji,
                    style: const TextStyle(fontSize: 22, height: 1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.topAnimal!.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: animalColor, height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '×${stats.topCount}',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: cl.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: cl.inkWhisper),
                ],
              ),
            ] else ...[
              Text('—',
                  style: GoogleFonts.dmSans(
                      fontSize: 22, fontWeight: FontWeight.w700,
                      color: cl.inkMuted)),
              Text('scan first',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: cl.inkWhisper)),
            ],
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(height: 4, color: cl.rule),
                  if (hasAnimal && stats.totalScans > 0)
                    FractionallySizedBox(
                      widthFactor:
                          (stats.topCount / stats.totalScans).clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: animalColor,
                          borderRadius: BorderRadius.circular(4),
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

// ── Compact feature tile ───────────────────────────────────────────────
class _CompactFeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, subtitle;

  const _CompactFeatureTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: cl.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600, color: cl.ink),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(fontSize: 10, color: cl.inkMuted),
          ),
        ],
      ),
    );
  }
}

// ── Global rank bottom sheet ───────────────────────────────────────────
class _RankSheet extends StatelessWidget {
  final ScanResult? scan;
  const _RankSheet({required this.scan});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: cl.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.large)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          const SizedBox(height: 4),

          if (scan == null) ...[
            const SizedBox(height: 16),
            const Text('🌍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No rank yet',
                style: GoogleFonts.dmSans(
                    fontSize: 22, fontWeight: FontWeight.w700, color: cl.ink)),
            const SizedBox(height: 8),
            Text('Scan your face to get your global rank.',
                style: GoogleFonts.dmSans(fontSize: 14, color: cl.inkMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
          ] else ...[
            const SizedBox(height: 12),
            const Text('🌍', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: 'Top ',
                  style: GoogleFonts.dmSans(
                      fontSize: 20, color: cl.inkMuted, fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: '${100 - scan!.percentile}%',
                  style: GoogleFonts.dmSans(
                      fontSize: 52, color: cl.teal, fontWeight: FontWeight.w800, height: 1),
                ),
              ]),
            ),
            const SizedBox(height: 4),
            Text('globally',
                style: GoogleFonts.dmSans(fontSize: 13, color: cl.inkMuted)),
            const SizedBox(height: 20),

            // Gradient bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [cl.scoreDown, cl.legendary, cl.teal],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    // Marker at the user's percentile
                    left: ((scan!.percentile / 100) *
                            (MediaQuery.of(context).size.width - 48 - 14))
                        .clamp(0.0, double.infinity),
                    top: -1,
                    child: Container(
                      width: 14, height: 12,
                      decoration: BoxDecoration(
                        color: cl.canvas,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: cl.teal, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bottom',
                    style: GoogleFonts.dmSans(fontSize: 10, color: cl.inkWhisper)),
                Text('Top',
                    style: GoogleFonts.dmSans(fontSize: 10, color: cl.inkWhisper)),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatPill(
                    label: 'Your score',
                    value: scan!.score.toStringAsFixed(1),
                    color: cl.teal),
                _StatPill(
                    label: 'Beat',
                    value: '${scan!.percentile}% of users',
                    color: cl.accent),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Rank updates with every new scan.',
              style:
                  GoogleFonts.dmSans(fontSize: 12, color: cl.inkWhisper),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Archetype breakdown sheet ──────────────────────────────────────────
class _ArchetypeDetailSheet extends StatelessWidget {
  final ArchetypeStats stats;
  const _ArchetypeDetailSheet({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72),
      child: Container(
        decoration: BoxDecoration(
          color: cl.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  _SheetHandle(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Your archetypes',
                        style: GoogleFonts.dmSans(
                          fontSize: 18, fontWeight: FontWeight.w700, color: cl.ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${stats.totalScans} scan${stats.totalScans == 1 ? '' : 's'}',
                        style:
                            GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Flexible(
              child: stats.allAnimals.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No scans yet.',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: cl.inkMuted)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 24),
                      itemCount: stats.allAnimals.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final (animal, count) = stats.allAnimals[i];
                        final isTop = i == 0;
                        final animalColor = cl.rarityColor(animal.rarity);
                        final barFraction = stats.topCount > 0
                            ? count / stats.topCount
                            : 0.0;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isTop
                                ? animalColor.withValues(alpha: 0.06)
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: isTop
                                  ? animalColor.withValues(alpha: 0.28)
                                  : cl.rule.withValues(alpha: 0.5),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(animal.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          animal.name,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: cl.ink,
                                          ),
                                        ),
                                        if (isTop) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: animalColor
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.pill),
                                            ),
                                            child: Text(
                                              'TOP',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2,
                                                color: animalColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Stack(
                                        children: [
                                          Container(
                                              height: 3, color: cl.surfaceH),
                                          FractionallySizedBox(
                                            widthFactor: barFraction,
                                            child: Container(
                                              height: 3,
                                              color: animalColor
                                                  .withValues(alpha: 0.65),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '×$count',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isTop ? animalColor : cl.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Center(
      child: Container(
        width: 36, height: 4,
        decoration: BoxDecoration(
          color: cl.inkWhisper,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style:
                GoogleFonts.dmSans(fontSize: 11, color: cl.inkMuted)),
      ],
    );
  }
}
