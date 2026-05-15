import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await markOnboardingComplete(ref);
    if (mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: const [_Page1(), _Page2(), _Page3()],
            ),
            Positioned(
              top: 8,
              right: 16,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomBar(
                currentPage: _currentPage,
                onNext: _next,
                onSignIn: () => context.go('/auth'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSignIn;

  const _BottomBar({required this.currentPage, required this.onNext, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == currentPage ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i == currentPage ? AppColors.purple : AppColors.textDim,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(currentPage == 2 ? 'Find my archetype — free' : 'Next'),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSignIn,
            child: const Text(
              'Already have an account? Sign in',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.purple, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Text('AI FACE ANALYSIS',
                style: TextStyle(color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.2),
              children: [
                TextSpan(text: 'Discover your face '),
                TextSpan(text: 'archetype', style: TextStyle(color: AppColors.purple)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Get your honest score, glow-up plan, and celebrity match — in seconds.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _ArchetypeCard(icon: '👁', label: 'Dark Ethereal', score: '8.1', color: AppColors.purple),
              const SizedBox(width: 8),
              _ArchetypeCard(icon: '☀', label: 'Soft Golden', score: '7.6', color: AppColors.teal),
              const SizedBox(width: 8),
              _ArchetypeCard(icon: '🔥', label: 'Bold Classic', score: '8.4', color: AppColors.pink),
            ],
          ),
          const SizedBox(height: 32),
          const Row(
            children: [
              _AvatarStack(),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '2.1M people discovered their archetype this month',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  final String icon;
  final String label;
  final String score;
  final Color color;

  const _ArchetypeCard({required this.icon, required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(score, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 30,
      child: Stack(
        children: List.generate(4, (i) {
          return Positioned(
            left: i * 16.0,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: [AppColors.purple, AppColors.teal, AppColors.pink, AppColors.amber][i],
              child: Text(['A', 'B', 'C', 'D'][i], style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
          );
        }),
      ),
    );
  }
}

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purple, width: 2),
              color: AppColors.surface,
            ),
            child: const Icon(Icons.face, color: AppColors.purple, size: 48),
          ),
          const SizedBox(height: 32),
          const Text('Upload a selfie,\nget your report',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Face score', 'Animal match', 'Glow-up plan']
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 160),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purple, width: 2),
              color: AppColors.surface,
            ),
            child: const Icon(Icons.share, color: AppColors.purple, size: 48),
          ),
          const SizedBox(height: 32),
          const Text('Share your animal,\nflex your score',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary, height: 1.3),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                const Text('🐆 Snow Leopard', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                const Text('Legendary · top 2%',
                    style: TextStyle(color: AppColors.legendary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('8.4', style: TextStyle(color: AppColors.purpleLight, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const Text('/10', style: TextStyle(color: AppColors.textMuted, fontSize: 18)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Top 7%', style: TextStyle(color: AppColors.tealLight, fontSize: 14, fontWeight: FontWeight.bold)),
                        const Text('this week', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
