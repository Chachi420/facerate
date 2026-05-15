import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String mood;

  const LoadingScreen({super.key, required this.imageFile, required this.mood});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> with TickerProviderStateMixin {
  late final AnimationController _outerController;
  late final AnimationController _midController;
  late final AnimationController _innerController;
  late final AnimationController _progressController;

  int _activeStep = 0;
  String? _error;

  final _steps = [
    'Facial landmarks mapped',
    'Scoring features...',
    'Finding your animal',
    'Generating glow-up plan',
  ];

  @override
  void initState() {
    super.initState();
    _outerController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _midController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _innerController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..forward();

    _runSteps();
    _analyze();
  }

  void _runSteps() async {
    final delays = [1000, 3000, 5000, 7000];
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(Duration(milliseconds: delays[i]));
      if (mounted) setState(() => _activeStep = i + 1);
    }
  }

  Future<void> _analyze() async {
    final authState = ref.read(authStateProvider).value;
    final userId = authState?.uid ?? 'guest';
    final apiService = ApiService();

    try {
      final result = await apiService.analyzeFace(widget.imageFile, userId, widget.mood);
      if (mounted) {
        context.go('/summary', extra: result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  void dispose() {
    _outerController.dispose();
    _midController.dispose();
    _innerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: _error != null ? _ErrorView(error: _error!, onRetry: () {
            setState(() => _error = null);
            _analyze();
          }) : _LoadingView(
            outerController: _outerController,
            midController: _midController,
            progressController: _progressController,
            activeStep: _activeStep,
            steps: _steps,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final AnimationController outerController;
  final AnimationController midController;
  final AnimationController progressController;
  final int activeStep;
  final List<String> steps;

  const _LoadingView({
    required this.outerController,
    required this.midController,
    required this.progressController,
    required this.activeStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: outerController,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.purple.withOpacity(0.3), width: 2),
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: midController,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.purple.withOpacity(0.5), width: 2),
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.purple, width: 2),
                    ),
                    child: const Icon(Icons.face, color: AppColors.purple, size: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Analyzing your face',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('AI is mapping 48 facial landmarks\nand finding your archetype',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: progressController,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressController.value,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation(AppColors.purple),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(steps.length, (i) {
              final done = i < activeStep;
              final active = i == activeStep - 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppColors.teal
                            : (active ? AppColors.purple : AppColors.textDim),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      steps[i],
                      style: TextStyle(
                        color: done ? AppColors.tealLight : (active ? AppColors.textPrimary : AppColors.textMuted),
                        fontSize: 14,
                      ),
                    ),
                    if (done) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check, color: AppColors.teal, size: 14),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 56),
            const SizedBox(height: 16),
            const Text('Analysis failed', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go back', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
