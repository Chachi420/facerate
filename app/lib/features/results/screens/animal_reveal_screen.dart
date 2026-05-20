import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_utils.dart';
import '../../../models/scan_result.dart';
import '../../../services/admob_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/hairline_rule.dart';
import '../../../widgets/mirror_wordmark.dart';

class AnimalRevealScreen extends ConsumerStatefulWidget {
  final ScanResult result;
  const AnimalRevealScreen({super.key, required this.result});

  @override
  ConsumerState<AnimalRevealScreen> createState() => _AnimalRevealScreenState();
}

class _AnimalRevealScreenState extends ConsumerState<AnimalRevealScreen> {
  bool _revealed = false;
  bool _whyOpen = false;
  final _cardKey = GlobalKey();

  bool get _isLocked {
    final isFree = widget.result.animal.isFree;
    final credits = ref.read(currentUserProfileStreamProvider).value?.credits ?? 0;
    return !isFree && credits < 5 && !_revealed;
  }

  Future<void> _watchAd() async {
    await AdMobService.showRewardedAd(onRewarded: () {
      if (mounted) setState(() => _revealed = true);
    });
  }

  Future<Uint8List?> _captureCard() async {
    final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final animal = widget.result.animal;
    final color = cl.rarityColor(animal.rarity);
    final topPercent = AppColors.rarityTopPercent(animal.rarity);
    final locked = _isLocked;

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Masthead(
              left: const MirrorWordmark(size: 20),
              right: EyebrowText.accent('An archetype'),
              onBack: () => context.canPop() ? context.pop() : context.go('/home'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: _cardKey,
                      child: Column(
                        children: [
                          Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: color.withValues(alpha: 0.22),
                                blurRadius: 32, spreadRadius: 10,
                              )],
                            ),
                            child: Center(
                              child: locked
                                  ? ImageFiltered(
                                      imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                      child: Text(animal.emoji, style: const TextStyle(fontSize: 80)),
                                    )
                                  : Text(animal.emoji, style: const TextStyle(fontSize: 80)),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            locked ? '???' : animal.name,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 36, color: cl.ink, letterSpacing: -0.02 * 36,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _RarityBadge(rarity: animal.rarity, color: color),
                          const SizedBox(height: 10),
                          if (!locked)
                            EyebrowText.muted('Top $topPercent% of animals', textAlign: TextAlign.center),
                        ],
                      ),
                    ),

                    if (!locked) ...[
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '"${animal.vibeDescription}"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 14, color: cl.inkMuted, height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const HairlineRule(),

                      // Why this animal?
                      GestureDetector(
                        onTap: () => setState(() => _whyOpen = !_whyOpen),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const EyebrowText('Why this animal?'),
                              Text(
                                _whyOpen ? '−' : '+',
                                style: GoogleFonts.dmSans(fontSize: 14, color: cl.inkWhisper),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_whyOpen) ...[
                        Text(
                          animal.reason,
                          style: GoogleFonts.dmSans(
                            fontSize: 12, color: cl.inkMuted, height: 1.65,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const HairlineRule(),
                      const SizedBox(height: 18),

                      // Share button — rounded
                      GestureDetector(
                        onTap: () async {
                          final bytes = await _captureCard();
                          if (bytes != null) {
                            await shareImage(bytes,
                                'I got ${animal.name} on Mirror — ${animal.rarity} tier!');
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: cl.accent,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            boxShadow: cl.buttonShadow,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Share this archetype',
                            style: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {},
                        child: Center(
                          child: Text(
                            'SAVE TO PHOTOS',
                            style: GoogleFonts.dmSans(
                              fontSize: 10, letterSpacing: 1.6, color: cl.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 24),
                      Text(
                        'This match is ${animal.rarity} tier',
                        style: GoogleFonts.dmSans(fontSize: 16, color: color),
                      ),
                      const SizedBox(height: 20),

                      // Reveal for 5 credits — rounded
                      GestureDetector(
                        onTap: () => context.push('/paywall'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: cl.ink,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reveal for 5 credits',
                            style: GoogleFonts.dmSans(
                              fontSize: 15, fontWeight: FontWeight.w600, color: cl.canvas,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Watch ad — rounded outline
                      GestureDetector(
                        onTap: _watchAd,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: cl.inkWhisper, width: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Watch ad to reveal',
                            style: GoogleFonts.dmSans(fontSize: 13, color: cl.inkMuted),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                      child: Text(
                        'See full analysis →',
                        style: GoogleFonts.dmSans(
                          fontSize: 12, color: cl.inkMuted,
                          decoration: TextDecoration.underline,
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
    );
  }
}

class _RarityBadge extends StatelessWidget {
  final String rarity;
  final Color color;
  const _RarityBadge({required this.rarity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10, fontWeight: FontWeight.w600,
          letterSpacing: 1.6, color: color,
        ),
      ),
    );
  }
}
