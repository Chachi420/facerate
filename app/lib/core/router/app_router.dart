import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/scan/screens/scan_screen.dart';
import '../../features/scan/screens/loading_screen.dart';
import '../../features/results/screens/summary_screen.dart';
import '../../features/results/screens/animal_reveal_screen.dart';
import '../../features/results/screens/score_card_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/credits/screens/paywall_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../models/scan_result.dart';

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
    return const Scaffold(
      backgroundColor: Color(0xFF07070F),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const _SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (_, __) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/scan',
      builder: (_, __) => const ScanScreen(),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return LoadingScreen(
          imageFile: extra['imageFile'] as File,
          mood: extra['mood'] as String,
        );
      },
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) => SummaryScreen(
        result: state.extra as ScanResult,
      ),
    ),
    GoRoute(
      path: '/animal-reveal',
      builder: (context, state) => AnimalRevealScreen(
        result: state.extra as ScanResult,
      ),
    ),
    GoRoute(
      path: '/score-card',
      builder: (context, state) => ScoreCardScreen(
        result: state.extra as ScanResult,
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/paywall',
      builder: (_, __) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
