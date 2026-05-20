import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/scan/screens/scan_screen.dart';
import '../../features/scan/screens/loading_screen.dart';
import '../../features/results/screens/summary_screen.dart';
import '../../features/results/screens/animal_reveal_screen.dart';
import '../../features/results/screens/score_card_screen.dart';
import '../../features/results/providers/results_provider.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/credits/screens/paywall_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/pokedex/screens/pokedex_screen.dart';
import '../../models/scan_result.dart';
import '../../widgets/noise_bg.dart';

// Smooth slide-up + fade transition — used for all forward navigation
Page<void> _page(LocalKey key, Widget child) => CustomTransitionPage<void>(
  key: key,
  child: child,
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
    final forward = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final backward = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic);
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.6)),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(forward),
        child: FadeTransition(
          opacity: Tween(begin: 1.0, end: 0.92).animate(backward),
          child: SlideTransition(
            position: Tween(begin: Offset.zero, end: const Offset(0, -0.02)).animate(backward),
            child: child,
          ),
        ),
      ),
    );
  },
);

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboardingComplete') ?? false;
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (!onboardingDone) {
      context.go('/onboarding');
    } else if (user == null) {
      context.go('/auth');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: NoiseBg(
        child: Center(
          child: Text(
            'mirror.',
            style: GoogleFonts.dmSans(
              fontSize: 32, fontWeight: FontWeight.w300,
              color: AppColors.ink, letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRouteWrapper extends ConsumerWidget {
  final Object? extra;
  const _SummaryRouteWrapper({this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = extra is ScanResult
        ? extra as ScanResult
        : ref.watch(currentScanProvider);
    if (result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
      return const Scaffold(backgroundColor: AppColors.canvas);
    }
    return SummaryScreen(result: result);
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (ctx, state) => _page(state.pageKey, const _SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (ctx, state) => _page(state.pageKey, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (ctx, state) => _page(state.pageKey, const AuthScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (ctx, state) => _page(state.pageKey, const HomeScreen()),
    ),
    GoRoute(
      path: '/scan',
      pageBuilder: (ctx, state) => _page(state.pageKey, const ScanScreen()),
    ),
    GoRoute(
      path: '/loading',
      pageBuilder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>;
        return _page(state.pageKey, LoadingScreen(
          imageFile: extra['imageFile'] as File,
          mood: extra['mood'] as String,
          mode: extra['mode'] as String? ?? 'honest',
        ));
      },
    ),
    GoRoute(
      path: '/summary',
      pageBuilder: (ctx, state) =>
          _page(state.pageKey, _SummaryRouteWrapper(extra: state.extra)),
    ),
    GoRoute(
      path: '/animal-reveal',
      pageBuilder: (ctx, state) => _page(state.pageKey,
          AnimalRevealScreen(result: state.extra as ScanResult)),
    ),
    GoRoute(
      path: '/score-card',
      pageBuilder: (ctx, state) => _page(state.pageKey,
          ScoreCardScreen(result: state.extra as ScanResult)),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (ctx, state) => _page(state.pageKey, const HistoryScreen()),
    ),
    GoRoute(
      path: '/paywall',
      pageBuilder: (ctx, state) => _page(state.pageKey, const PaywallScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (ctx, state) => _page(state.pageKey, const SettingsScreen()),
    ),
    GoRoute(
      path: '/pokedex',
      pageBuilder: (ctx, state) => _page(state.pageKey, const PokedexScreen()),
    ),
  ],
);
