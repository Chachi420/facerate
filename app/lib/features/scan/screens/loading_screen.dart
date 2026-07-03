import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../services/admob_service.dart';
import '../../../widgets/noise_bg.dart';
import '../../auth/providers/auth_provider.dart';
import '../../results/providers/results_provider.dart';
import '../../settings/providers/settings_provider.dart';
export '../../../services/api_service.dart' show NoFaceException, NoCreditsException;

// ── Rotating fact pool (shuffled each session) ──────────────────────
const _kFacts = [
  ('Face science', 'Research suggests facial symmetry is processed very quickly — often before we consciously register a face.'),
  ('Sleep science', 'Even one night of poor sleep can visibly affect skin hydration and cause under-eye puffiness by morning.'),
  ('Proportion', 'Many attractiveness studies reference "golden ratio" proportions — though what looks good varies widely by culture and individual taste.'),
  ('Sun protection', 'Daily SPF use is one of the most consistently recommended steps for slowing visible skin aging.'),
  ('Jawline', 'Habitual chewing of tougher foods may contribute to jaw muscle development over time — though genetics plays a larger role.'),
  ('Grooming', 'A well-maintained beard can reshape how the lower face reads — proportion matters more than length.'),
  ('Hydration', 'Adequate hydration supports skin elasticity and can reduce the appearance of dullness throughout the day.'),
  ('Lighting truth', 'Soft, diffuse natural light tends to be the most flattering for portraits — it minimizes harsh shadows.'),
  ('Skin type', 'Your skin type can shift with seasons, climate, and age. What worked at 20 may not at 30.'),
  ('Face shape', 'Oval face shapes are often described as the most versatile for styling choices — but every shape has its strengths.'),
  ('Collagen', 'Collagen production gradually slows with age. Vitamin C and SPF are among the most evidence-backed ways to support it.'),
  ('Cold water', 'A cold-water rinse in the morning can reduce puffiness and help wake up skin tone.'),
  ('Beard science', 'Research on beard attractiveness is surprisingly mixed — heavy stubble tends to score well, but preferences vary.'),
  ('Dark circles', 'Dark circles come from a mix of genetics (thin skin, pigment) and lifestyle (sleep, hydration, salt). Both matter.'),
  ('Brow tip', 'Groomed brows that follow your natural arch tend to frame the eyes and balance the upper face.'),
  ('Skin glow', 'Regular exercise improves circulation, which can give skin a healthier, more even appearance over time.'),
  ('Cheekbones', 'Forward-projected cheekbones are often associated with certain attractiveness patterns — though beauty is far broader than any single feature.'),
  ('Retinol', 'Retinol remains one of the most studied topical ingredients for texture and fine lines — start with a low percentage.'),
  ('Face and weight', 'Modest weight changes can visibly affect facial definition for many people, though genetics determines where fat is stored.'),
  ('Posture', 'Upright posture affects how the jawline and neck appear in photos and in person. It is also trainable.'),
  ('Haircut', 'The right cut can visually adjust perceived face proportions — longer on the sides can shorten a wide face.'),
  ('Redness', 'Green tea extract and niacinamide are among the gentler options for reducing skin redness and inflammation.'),
  ('Exfoliation', 'Chemical exfoliation (AHAs and BHAs) is generally considered gentler than physical scrubs for most skin types.'),
  ('Under-eye', 'Caffeine-infused eye products may temporarily reduce puffiness by affecting blood vessel dilation.'),
  ('Weight and face', 'Body composition changes often show in the face first for many people — though this is highly individual.'),
  ('Niacinamide', 'Niacinamide (vitamin B3) is broadly well-tolerated and has good evidence for pore appearance and skin tone.'),
  ('Lighting angle', 'Photographers commonly use light at roughly 45° to the face — it creates gentle dimension without harsh shadows.'),
  ('Forehead', 'Classical "golden thirds" proportions describe a forehead roughly one-third of total face height — a useful framing concept, not a rule.'),
  ('Zinc', 'Zinc plays a role in skin health, and deficiency can show up as acne or inflammation. It is easy to test for.'),
  ('Expression', 'A genuinely relaxed, open expression tends to read as more approachable in photos than a forced smile.'),
  ('Lip care', 'Consistent lip hydration is one of the simplest and most overlooked parts of a grooming routine.'),
  ('Skincare basics', 'Cleanser, moisturizer, and SPF — most dermatologists agree these three cover the majority of daily skin needs.'),
  ('Consistency', 'Skincare results are largely cumulative. A simple routine done consistently tends to outperform complex routines done sporadically.'),
  ('Genetics', 'Many facial features are strongly genetic. Your job is to optimize what you can — lighting, grooming, health habits.'),
  ('Perceived age', 'Perceived age often tracks with skin quality, posture, and energy — all of which respond to lifestyle changes.'),
];

class LoadingScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String mood;
  final String mode;

  const LoadingScreen({
    super.key,
    required this.imageFile,
    required this.mood,
    this.mode = 'honest',
  });

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _progressController;

  int _activeStep = 0;
  String? _error;
  bool _isNoFace = false;
  bool _isNoCredits = false;
  bool _isReturningUser = false;

  // Elapsed timer
  int _elapsed = 0;
  Timer? _elapsedTimer;

  // Rotating facts
  late final List<(String, String)> _shuffledFacts;
  int _factIndex = 0;
  Timer? _factTimer;

  final _steps = [
    'Detecting face',
    'Mapping features',
    'Matching archetype',
    'Composing reading',
  ];

  @override
  void initState() {
    super.initState();

    // Shuffle facts
    _shuffledFacts = List.of(_kFacts)..shuffle();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();

    // Elapsed clock
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });

    // Fact rotator — new fact every 5 seconds
    _factTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => _factIndex = (_factIndex + 1) % _shuffledFacts.length);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userAsync = ref.read(currentUserProfileStreamProvider);
      final profile = userAsync.value;
      final totalScans = profile?.totalScans ?? 0;
      if (mounted) setState(() => _isReturningUser = totalScans > 0);

      // Preload the post-result interstitial while the AI works, so it's ready
      // the moment the user leaves the summary. Pro users never see ads.
      if (!(profile?.isPro ?? false)) {
        AdMobService.loadInterstitialAd();
      }
    });

    _runSteps();
    _analyze();
  }

  void _runSteps() async {
    final delays = [800, 2200, 4000, 6500];
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(Duration(milliseconds: delays[i]));
      if (mounted) setState(() => _activeStep = i + 1);
    }
  }

  Future<void> _analyze() async {
    final authState = ref.read(authStateProvider).value;
    final userId = authState?.uid ?? '';
    final apiService = ApiService();

    try {
      final idToken = authState != null ? await authState.getIdToken() : null;
      final result = await apiService.analyzeFace(
          widget.imageFile, userId, widget.mood, widget.mode, idToken);
      ref.read(currentScanProvider.notifier).state = result;

      // Persist scan to history if the user has enabled it.
      // (Stats — streak, totalScans, lastScanDate — are updated by the backend.)
      if (authState != null) {
        final saveHistory = ref.read(settingsProvider).saveHistory;
        if (saveHistory) {
          await ref.read(firestoreServiceProvider).saveScan(userId, result);
        }
      }

      if (mounted) context.go('/summary', extra: result);
    } catch (e, st) {
      debugPrint('=== SCAN ERROR ===\n$e\n$st');
      if (mounted) {
        setState(() {
          _isNoFace = e is NoFaceException;
          _isNoCredits = e is NoCreditsException;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _elapsedTimer?.cancel();
    _factTimer?.cancel();
    super.dispose();
  }

  String get _elapsedLabel {
    final m = _elapsed ~/ 60;
    final s = _elapsed % 60;
    return m > 0 ? '${m}m ${s.toString().padLeft(2, '0')}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _error != null
            ? (_isNoCredits
                ? _NoCreditsView(onGetCredits: () => context.go('/paywall'))
                : _isNoFace
                    ? _PunView(pun: _error!)
                    : _ErrorView(
                        error: _error!,
                        onRetry: () {
                          setState(() { _error = null; _isNoFace = false; _isNoCredits = false; });
                          _analyze();
                        },
                      ))
            : _LoadingView(
                pulseController: _pulseController,
                progressController: _progressController,
                activeStep: _activeStep,
                steps: _steps,
                isReturningUser: _isReturningUser,
                elapsedLabel: _elapsedLabel,
                fact: _shuffledFacts[_factIndex],
                factIndex: _factIndex,
              ),
      ),
    );
  }
}

// ── Loading view ──────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController progressController;
  final int activeStep;
  final List<String> steps;
  final bool isReturningUser;
  final String elapsedLabel;
  final (String, String) fact;
  final int factIndex;

  const _LoadingView({
    required this.pulseController,
    required this.progressController,
    required this.activeStep,
    required this.steps,
    required this.isReturningUser,
    required this.elapsedLabel,
    required this.fact,
    required this.factIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return NoiseBg(
      child: Stack(
        children: [
          // Radial vignette
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.3,
                    colors: [Color(0x00000000), Color(0xDD000000)],
                    stops: [0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Upper half: fact card ──────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenH * 0.42,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar: cancel + elapsed timer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            '← Cancel',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Elapsed timer chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined, size: 11,
                                color: Colors.white.withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Text(
                                elapsedLabel,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11, fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Rotating fact card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                          child: child,
                        ),
                      ),
                      child: _FactCard(
                        key: ValueKey(factIndex),
                        label: fact.$1,
                        body: fact.$2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Fact dot indicators (shows position in pool)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final active = i == factIndex % 5;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: active ? 16 : 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Center: pulsing scan rings ─────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, __) {
                final v = pulseController.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 160 + v * 18,
                      height: 160 + v * 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.signalGreen.withValues(alpha: 0.10 + v * 0.07),
                          width: 1,
                        ),
                      ),
                    ),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.signalGreen.withValues(alpha: 0.22 + v * 0.13),
                          width: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.signalGreen.withValues(alpha: 0.07),
                        border: Border.all(
                          color: AppColors.signalGreen.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.face_retouching_natural_rounded,
                        size: 26,
                        color: AppColors.signalGreen.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Bottom progress panel ──────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E0B16).withValues(alpha: 0.97),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
                border: Border(
                  top: BorderSide(
                    color: AppColors.signalGreen.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 22, 24, bottomPad + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isReturningUser
                        ? "Welcome back. Composing today's reading."
                        : 'Analyzing your face…',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ...List.generate(steps.length, (i) {
                    final done = i < activeStep;
                    final active = i == activeStep;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done ? AppColors.signalGreen : Colors.transparent,
                              border: Border.all(
                                color: done
                                    ? AppColors.signalGreen
                                    : active
                                        ? AppColors.signalGreen.withValues(alpha: 0.5)
                                        : Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: done
                                ? const Center(
                                    child: Icon(Icons.check_rounded, size: 10, color: Colors.black),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            steps[i],
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              letterSpacing: 0.2,
                              color: done
                                  ? Colors.white
                                  : active
                                      ? Colors.white.withValues(alpha: 0.55)
                                      : Colors.white.withValues(alpha: 0.25),
                              fontWeight: done ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(width: 8),
                            _DotPulse(),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  AnimatedBuilder(
                    animation: progressController,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Stack(
                        children: [
                          Container(height: 2.5, color: Colors.white.withValues(alpha: 0.08)),
                          FractionallySizedBox(
                            widthFactor: progressController.value,
                            child: Container(
                              height: 2.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.signalGreen, AppColors.accent],
                                ),
                                boxShadow: [
                                  BoxShadow(color: AppColors.signalGreen, blurRadius: 4),
                                ],
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
          ),
        ],
      ),
    );
  }
}

// ── Fact card ─────────────────────────────────────────────────────────
class _FactCard extends StatelessWidget {
  final String label;
  final String body;
  const _FactCard({super.key, required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.signalGreen,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.signalGreen.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: GoogleFonts.dmSans(
              fontSize: 14, color: Colors.white.withValues(alpha: 0.85),
              height: 1.55, fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated three-dot pulse for active step ──────────────────────────
class _DotPulse extends StatefulWidget {
  @override
  State<_DotPulse> createState() => _DotPulseState();
}

class _DotPulseState extends State<_DotPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final delay = i / 3;
          final v = ((_ctrl.value - delay).clamp(0.0, 1.0));
          return Container(
            margin: const EdgeInsets.only(right: 3),
            width: 3, height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.signalGreen.withValues(alpha: 0.3 + v * 0.7),
            ),
          );
        }),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return NoiseBg(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cl.surface,
                    border: Border.all(color: cl.scoreDown.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Icon(Icons.error_outline_rounded, color: cl.scoreDown, size: 36),
                ),
                const SizedBox(height: 24),
                Text(
                  'Analysis failed',
                  style: GoogleFonts.dmSans(
                    fontSize: 22, color: cl.ink, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.5),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: cl.accent,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: cl.buttonShadow,
                    ),
                    child: Text(
                      'Try again',
                      style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text('Go back',
                    style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── No-face pun view ──────────────────────────────────────────────────
class _PunView extends StatelessWidget {
  final String pun;
  const _PunView({required this.pun});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return NoiseBg(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cl.surface,
                    border: Border.all(color: cl.inkWhisper, width: 0.5),
                  ),
                  child: const Center(child: Text('🤔', style: TextStyle(fontSize: 44))),
                ),
                const SizedBox(height: 24),
                Text(
                  "That's not a face!",
                  style: GoogleFonts.dmSans(
                    fontSize: 22, color: cl.ink, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Point the camera at your face and try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cl.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: cl.inkWhisper.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Text(pun,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 15, color: cl.ink, height: 1.6)),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: cl.accent,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: cl.buttonShadow,
                    ),
                    child: Text(
                      'Try again',
                      style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoCreditsView extends StatelessWidget {
  final VoidCallback onGetCredits;
  const _NoCreditsView({required this.onGetCredits});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return NoiseBg(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cl.surface,
                    border: Border.all(color: cl.legendary.withValues(alpha: 0.4), width: 1),
                  ),
                  child: const Center(child: Text('⚡', style: TextStyle(fontSize: 38))),
                ),
                const SizedBox(height: 24),
                Text('Out of credits',
                  style: GoogleFonts.dmSans(fontSize: 22, color: cl.ink, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(
                  'You need at least 1 credit to scan.\nGet credits or go Pro for unlimited scans.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.5)),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: onGetCredits,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: cl.accent,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: cl.buttonShadow,
                    ),
                    child: Text('Get credits →',
                      style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text('Go back',
                    style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
