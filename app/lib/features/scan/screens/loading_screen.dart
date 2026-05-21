import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/noise_bg.dart';
import '../../auth/providers/auth_provider.dart';
import '../../results/providers/results_provider.dart';
import '../../settings/providers/settings_provider.dart';
export '../../../services/api_service.dart' show NoFaceException, NoCreditsException;

// ── Rotating fact pool (shuffled each session) ──────────────────────
const _kFacts = [
  ('Face science', 'Facial symmetry is processed by the brain in under 150 ms — before conscious thought kicks in.'),
  ('Sleep science', 'Just one night of poor sleep reduces skin hydration by up to 30% and puffs under-eyes by 40%.'),
  ('Golden ratio', 'The ideal eye-to-mouth distance is roughly 36% of total face length — a near-universal beauty cue.'),
  ('Skin tip', 'SPF 30 worn daily prevents up to 24% of collagen loss by age 40. Nothing else comes close.'),
  ('Jawline fact', 'Chewing tougher foods over years measurably widens and sharpens the mandibular angle.'),
  ('Grooming', 'A well-maintained beard can mask weak chin projection and visually strengthen the lower third.'),
  ('Hydration', 'Drinking 500 ml of water raises skin radiance scores by ~30% within 30 minutes.'),
  ('Lighting truth', 'Overcast natural light is the most flattering — it eliminates harsh shadows and evens skin tone.'),
  ('Eye spacing', 'Eyes spaced one eye-width apart score highest for attractiveness across all demographics studied.'),
  ('Skin type', 'Your skin type can shift seasonally — oily in summer, drier in winter — and changes each decade.'),
  ('Face shape', 'The oval face shape is considered the most universally balanced, fitting almost any hairstyle.'),
  ('Collagen', 'Collagen production drops ~1% per year after 25. Vitamin C serums can slow this measurably.'),
  ('Cold water', 'Rinsing your face with cold water for 30 seconds each morning tightens pores and reduces puffiness.'),
  ('Beard science', 'Heavy stubble (around 10 days) consistently rates highest for attractiveness in peer-reviewed studies.'),
  ('Dark circles', 'Dark circles are 60% genetic (skin thinness) and 40% lifestyle — sleep, hydration, and salt intake.'),
  ('Brow tip', 'Groomed brows that follow your natural arch frame the face and draw attention to the eyes.'),
  ('Nasal tip', 'A slightly upturned nasal tip (around 106°) is rated most attractive in Western facial research.'),
  ('Skin glow', 'A 20-minute brisk walk measurably improves skin blood flow and gives a visible post-exercise glow.'),
  ('Cheekbones', 'High, forward-projected cheekbones signal lower cortisol levels — a subconscious health cue.'),
  ('Retinol', 'Retinol is the only topical ingredient with FDA-accepted evidence for reducing fine lines. Start low.'),
  ('Face fat', 'Lower body fat percentage (15–20% for men, 22–26% for women) creates sharper facial definition.'),
  ('Posture', 'Chin-forward posture reduces the appearance of a strong jawline by 30% compared to upright posture.'),
  ('Haircut', 'The right haircut can add or subtract 1–2 cm from perceived face length or width optically.'),
  ('Redness', 'Green tea extract applied topically reduces facial redness (erythema) in 8 of 10 clinical trials.'),
  ('Nose bridge', 'A straight, defined nose bridge strengthens the midface and improves profile scores significantly.'),
  ('Exfoliation', 'Chemical exfoliation (AHA/BHA) outperforms physical scrubs — less micro-tearing, better cell turnover.'),
  ('Under-eye', 'Caffeine-based eye creams reduce puffiness by constricting blood vessels — works in under 15 minutes.'),
  ('Face card', 'Your face changes measurably with weight: 4 kg of fat loss adds visible cheek definition on average.'),
  ('Philtrum', 'A shorter philtrum (upper lip to nose distance) correlates with a youthful facial proportion.'),
  ('Niacinamide', 'Niacinamide (B3) reduces pore appearance, evens skin tone, and pairs well with every other active.'),
  ('Lighting angle', 'Light from 45° above and slightly to the side is the most used angle in professional photography.'),
  ('Forehead', 'A forehead that is roughly one-third of total face height fits the classical golden facial thirds.'),
  ('Zinc', 'Zinc deficiency is a leading cause of adult acne — often missed and easily corrected with diet.'),
  ('Eye contact', 'Faces with slightly wider-open eyes are consistently rated more approachable and attractive.'),
  ('Lip ratio', 'The ideal upper-to-lower lip ratio is roughly 1:1.6 — the lower lip slightly fuller.'),
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
      final totalScans = userAsync.when(
        data: (u) => u?.totalScans ?? 0,
        loading: () => 0,
        error: (_, __) => 0,
      );
      if (mounted) setState(() => _isReturningUser = totalScans > 0);
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
    final userId = authState?.uid ?? 'guest';
    final idToken = userId != 'guest' ? await authState!.getIdToken() : null;
    final apiService = ApiService();

    try {
      final result = await apiService.analyzeFace(
          widget.imageFile, userId, widget.mood, widget.mode, idToken);
      ref.read(currentScanProvider.notifier).state = result;

      // Persist scan to history if the user has enabled it.
      // (Stats — streak, totalScans, lastScanDate — are updated by the backend.)
      if (userId != 'guest') {
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
