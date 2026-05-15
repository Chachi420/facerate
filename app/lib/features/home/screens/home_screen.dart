import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/admob_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../scan/providers/scan_provider.dart';
import '../../../models/scan_result.dart';

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

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProfileStreamProvider);
    final lastScanAsync = ref.watch(lastScanProvider);

    final isPro = userAsync.when(data: (u) => u?.isPro ?? false, loading: () => false, error: (_, __) => false);
    final credits = userAsync.when(data: (u) => u?.credits ?? 0, loading: () => 0, error: (_, __) => 0);
    final streak = userAsync.when(data: (u) => u?.streak ?? 0, loading: () => 0, error: (_, __) => 0);

    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final tip = AppConstants.dailyTips[dayOfYear % AppConstants.dailyTips.length];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _TopBar(credits: credits)),
                  lastScanAsync.when(
                    data: (scan) => scan != null
                        ? SliverToBoxAdapter(child: _LastScanBanner(scan: scan))
                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),
                  lastScanAsync.when(
                    data: (scan) => scan != null
                        ? SliverToBoxAdapter(child: _PercentileStrip(percentile: scan.percentile))
                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),
                  SliverToBoxAdapter(child: _ScanHero()),
                  SliverToBoxAdapter(child: _TipsRow(tip: tip, streak: streak)),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            _BottomNav(currentIndex: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            if (!isPro && _bannerAdLoaded && _bannerAd != null)
              SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int credits;
  const _TopBar({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'face', style: TextStyle(color: AppColors.textPrimary)),
                TextSpan(text: 'rate', style: TextStyle(color: AppColors.purple)),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('$credits', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LastScanBanner extends ConsumerWidget {
  final ScanResult scan;
  const _LastScanBanner({required this.scan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.push('/summary', extra: scan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Center(child: Text(scan.animal.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your archetype', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  Text(scan.archetype, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  const Text('Tap to see report', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(scan.score.toStringAsFixed(1), style: const TextStyle(color: AppColors.purpleLight, fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('score', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentileStrip extends StatelessWidget {
  final int percentile;
  const _PercentileStrip({required this.percentile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.teal.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AppColors.tealLight, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You score higher than $percentile% of users this week',
              style: const TextStyle(color: AppColors.tealLight, fontSize: 12),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.tealLight, size: 16),
        ],
      ),
    );
  }
}

class _ScanHero extends ConsumerWidget {
  const _ScanHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.push('/scan'),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.purple.withOpacity(0.22), width: 20),
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.purple.withOpacity(0.44), width: 8),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.purple, width: 2),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.purple, size: 28),
                        SizedBox(height: 4),
                        Text('SCAN', style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Scan your face', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Best results with good lighting · no filter',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/scan'),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Choose from gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border, width: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsRow extends StatelessWidget {
  final String tip;
  final int streak;

  const _TipsRow({required this.tip, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _TipCard(
              icon: Icons.auto_awesome,
              title: "Today's tip",
              body: tip,
              color: AppColors.purple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _TipCard(
              icon: Icons.local_fire_department,
              title: '$streak week streak',
              body: streak > 0 ? 'Keep scanning to build your streak!' : 'Start your first scan today.',
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _TipCard({required this.icon, required this.title, required this.body, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.history_outlined, Icons.history, 'History'),
      (Icons.bar_chart_outlined, Icons.bar_chart, 'Progress'),
      (Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final (outlineIcon, filledIcon, label) = items[i];
          final active = currentIndex == i;
          final disabled = i == 2;

          return Expanded(
            child: GestureDetector(
              onTap: disabled ? null : () {
                if (i == 1) context.push('/history');
                else if (i == 3) context.push('/settings');
                else onTap(i);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? filledIcon : outlineIcon,
                      color: disabled ? AppColors.textDim : (active ? AppColors.purple : AppColors.textSecondary),
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: disabled ? AppColors.textDim : (active ? AppColors.purple : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
