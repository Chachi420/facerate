import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/eyebrow_text.dart';
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
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
    final cl = Cl.of(context);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _finish,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: cl.surfaceH,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: EyebrowText.muted('Skip'),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: const [_Page1(), _Page2(), _Page3()],
              ),
            ),

            // Bottom bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 28 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? cl.accent : cl.inkWhisper,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // CTA button
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: cl.accent,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: cl.buttonShadow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentPage == 2 ? 'Find my archetype →' : 'Next →',
                        style: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Sign in link
                  GestureDetector(
                    onTap: () => context.go('/auth'),
                    child: Text(
                      'Already have an account? Sign in',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: cl.inkMuted,
                        decoration: TextDecoration.underline,
                        decorationColor: cl.inkMuted,
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

// ── Page 1: Discover your archetype ──────────────────────────────────────────
class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'mirror.',
            style: GoogleFonts.dmSans(
              fontSize: 44, fontWeight: FontWeight.w700,
              color: cl.ink, letterSpacing: -0.02 * 44, height: 1,
            ),
          ),
          const SizedBox(height: 6),
          EyebrowText.muted('Face intelligence'),
          const SizedBox(height: 28),
          Container(height: 0.5, color: cl.rule),
          const SizedBox(height: 20),
          Text(
            'Discover your\narchetype.',
            style: GoogleFonts.dmSans(
              fontSize: 32, fontWeight: FontWeight.w700,
              color: cl.ink, letterSpacing: -0.02 * 32, height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'AI face analysis that gives you a score, a spirit animal, and a path forward.',
            style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.6),
          ),
          const SizedBox(height: 24),

          // Archetype cards
          Row(
            children: [
              _ArchetypeCard(emoji: '👁', label: 'Dark Ethereal', score: '8.1', rarity: 'epic'),
              const SizedBox(width: 10),
              _ArchetypeCard(emoji: '☀️', label: 'Soft Golden', score: '7.6', rarity: 'uncommon'),
              const SizedBox(width: 10),
              _ArchetypeCard(emoji: '🐆', label: 'Snow Leopard', score: '8.4', rarity: 'legendary'),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 0.5, color: cl.rule),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cl.teal),
              ),
              const SizedBox(width: 8),
              Text(
                '2.1M people discovered their archetype this month',
                style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  final String emoji, label, score, rarity;
  const _ArchetypeCard({
    required this.emoji, required this.label,
    required this.score, required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final color = cl.rarityColor(rarity);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cl.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
          boxShadow: cl.subtleShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11, fontWeight: FontWeight.w500, color: cl.ink,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                score,
                style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 2: Scan your face ────────────────────────────────────────────────────
class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowText.muted('Step 1'),
          const SizedBox(height: 12),
          Text(
            'Scan your face.',
            style: GoogleFonts.dmSans(
              fontSize: 32, fontWeight: FontWeight.w700,
              color: cl.ink, letterSpacing: -0.02 * 32, height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'One selfie. Front-facing, natural light. Our model does the rest.',
            style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.6),
          ),
          const SizedBox(height: 24),

          // Viewfinder mock
          Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: cl.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: cl.rule, width: 1),
              boxShadow: cl.subtleShadow,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _corners(cl.accent),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face_outlined, color: cl.inkMuted, size: 48),
                    const SizedBox(height: 10),
                    EyebrowText.muted('Position face here'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 0.5, color: cl.rule),
          const SizedBox(height: 14),

          // Feature pills
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ['Face score', 'Animal archetype', 'Glow-up plan'].map((t) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cl.accentDim,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: cl.accent.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text(t, style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w500, color: cl.accent)),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }

  static Widget _corners(Color accent) {
    return Stack(
      children: [
        Positioned(top: 18, left: 18, child: _Corner(color: accent, top: true, left: true)),
        Positioned(top: 18, right: 18, child: _Corner(color: accent, top: true, left: false)),
        Positioned(bottom: 18, left: 18, child: _Corner(color: accent, top: false, left: true)),
        Positioned(bottom: 18, right: 18, child: _Corner(color: accent, top: false, left: false)),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final bool top, left;
  const _Corner({required this.color, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18, height: 18,
      child: CustomPaint(
        painter: _CornerPainter(color: color, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final bool top, left;
  const _CornerPainter({required this.color, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

// ── Page 3: Get your verdict ──────────────────────────────────────────────────
class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowText.muted('Step 2'),
          const SizedBox(height: 12),
          Text(
            'Get your verdict.',
            style: GoogleFonts.dmSans(
              fontSize: 32, fontWeight: FontWeight.w700,
              color: cl.ink, letterSpacing: -0.02 * 32, height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Score, rarity tier, spirit animal — and what changed since last time.',
            style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.6),
          ),
          const SizedBox(height: 24),

          // Mock result card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cl.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: cl.legendary.withValues(alpha: 0.4), width: 0.5),
              boxShadow: cl.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🐆', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Snow Leopard',
                      style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600, color: cl.legendary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cl.legendary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: cl.legendary.withValues(alpha: 0.5), width: 0.5),
                      ),
                      child: Text(
                        'LEGENDARY',
                        style: GoogleFonts.dmSans(
                          fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w600,
                          color: cl.legendary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '8.4',
                  style: GoogleFonts.dmSans(
                    fontSize: 56, fontWeight: FontWeight.w800,
                    color: cl.accent, letterSpacing: -0.04 * 56, height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '↑ 0.3 from last scan · top 7% this week',
                  style: GoogleFonts.dmSans(fontSize: 12, color: cl.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 0.5, color: cl.rule),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: cl.accent),
              ),
              const SizedBox(width: 8),
              Text(
                'Track your score over time. Build your bestiary.',
                style: GoogleFonts.dmSans(fontSize: 12, color: cl.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
