import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_utils.dart';
import '../../../models/scan_result.dart';
import '../../../services/admob_service.dart';
import '../../auth/providers/auth_provider.dart';

class AnimalRevealScreen extends ConsumerStatefulWidget {
  final ScanResult result;

  const AnimalRevealScreen({super.key, required this.result});

  @override
  ConsumerState<AnimalRevealScreen> createState() => _AnimalRevealScreenState();
}

class _AnimalRevealScreenState extends ConsumerState<AnimalRevealScreen> {
  bool _revealed = false;

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

  @override
  Widget build(BuildContext context) {
    final animal = widget.result.animal;
    final color = AppColors.rarityColor(animal.rarity);
    final dots = AppColors.rarityDots(animal.rarity);
    final topPercent = AppColors.rarityTopPercent(animal.rarity);
    final locked = _isLocked;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('Your animal match',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('You\'ve been matched',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Based on 48 facial data points',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 28),
              // Animal Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: color.withOpacity(0.6), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✦ ${animal.rarity} · top $topPercent%',
                            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (locked)
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Text(animal.emoji, style: const TextStyle(fontSize: 64)),
                      )
                    else
                      Text(animal.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    if (locked)
                      const Text('???',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 22, fontWeight: FontWeight.bold))
                    else
                      Text(animal.name,
                          style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (!locked)
                      Text(animal.reason,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    if (!locked) ...[
                      const Divider(color: AppColors.border, height: 24),
                      Text(animal.vibeDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic, height: 1.6)),
                    ],
                    if (locked) ...[
                      const SizedBox(height: 8),
                      Text('This match is ${animal.rarity} tier',
                          style: TextStyle(color: color, fontSize: 13)),
                      const SizedBox(height: 4),
                      Icon(Icons.lock, color: color, size: 28),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Rarity dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < dots;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? color : AppColors.textDim,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text('✦ ${animal.rarity.toUpperCase()}',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 24),
              if (locked) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/paywall'),
                    child: const Text('Reveal for 5 credits'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _watchAd,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      foregroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Watch ad to reveal'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final bytes = await _captureCard(context);
                      if (bytes != null) {
                        await shareImage(bytes,
                            'I got ${animal.name} on FaceRate — ${animal.rarity} tier! 🐾 facerate.app');
                      }
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share my animal'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Text('See full face report →',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _captureCard(BuildContext context) async {
    return null; // Screenshot logic via screenshot package
  }
}
