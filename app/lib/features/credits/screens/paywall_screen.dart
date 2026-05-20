import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/credits_provider.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/hairline_rule.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../auth/providers/auth_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _buyingCredits = false;
  bool _buyingPro = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final iap = ref.read(iapServiceProvider);
    iap.onPurchaseComplete = (_) {
      if (!mounted) return;
      // Refresh the user's credits/Pro status across the app.
      ref.invalidate(currentUserProfileStreamProvider);
      setState(() {
        _buyingCredits = false;
        _buyingPro = false;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchase successful! Credits added to your account.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Cl.of(context).teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    };
    iap.onPurchaseError = (msg) {
      if (!mounted) return;
      setState(() {
        _buyingCredits = false;
        _buyingPro = false;
        _error = msg;
      });
    };
  }

  @override
  void dispose() {
    final iap = ref.read(iapServiceProvider);
    iap.onPurchaseComplete = null;
    iap.onPurchaseError = null;
    super.dispose();
  }

  // (productId, label, displayPrice, perScanLabel, isPopular, isBestValue)
  static const _packs = [
    (AppConstants.creditsProduct10,  '10 credits', '\$0.99', '~10¢/scan', false, false),
    (AppConstants.creditsProduct30,  '30 credits', '\$2.49', '~8¢/scan',  true,  false),
    (AppConstants.creditsProduct100, '100 credits', '\$5.99', '~6¢/scan', false, true),
  ];

  Future<void> _purchaseCredits() async {
    final selectedProduct = ref.read(selectedProductProvider);
    if (selectedProduct == null) return;
    setState(() { _buyingCredits = true; _error = null; });
    try {
      final products = await ref.read(iapProductsProvider.future);
      final product = products.firstWhere(
        (p) => p.id == selectedProduct,
        orElse: () => products.first,
      );
      await ref.read(iapServiceProvider).purchaseProduct(product);
    } catch (e) {
      if (mounted) setState(() { _error = 'Purchase failed. Please try again.'; });
    } finally {
      if (mounted) setState(() { _buyingCredits = false; });
    }
  }

  Future<void> _purchasePro() async {
    setState(() { _buyingPro = true; _error = null; });
    try {
      final products = await ref.read(iapProductsProvider.future);
      final proProduct = products.where((p) => p.id == AppConstants.proMonthly).firstOrNull;
      if (proProduct == null) {
        setState(() { _error = 'Pro subscription not available.'; });
        return;
      }
      await ref.read(iapServiceProvider).purchaseProduct(proProduct);
    } catch (e) {
      if (mounted) setState(() { _error = 'Purchase failed. Please try again.'; });
    } finally {
      if (mounted) setState(() { _buyingPro = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final selectedProduct = ref.watch(selectedProductProvider);
    ref.watch(iapProductsProvider);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Masthead(
              left: const EyebrowText('Unlock'),
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Blurred tease
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: const Text('🦚', style: TextStyle(fontSize: 80)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: cl.surface,
                            borderRadius: BorderRadius.circular(AppRadius.small),
                            border: Border.all(color: cl.inkWhisper, width: 0.5),
                          ),
                          child: Text(
                            'LOCKED',
                            style: GoogleFonts.dmSans(
                                fontSize: 9, letterSpacing: 2, color: cl.inkMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Reveal your archetype.',
                      style: GoogleFonts.dmSans(
                        fontSize: 28, color: cl.ink,
                        letterSpacing: -0.02 * 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: cl.legendary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                            color: cl.legendary.withValues(alpha: 0.5), width: 0.5),
                      ),
                      child: EyebrowText('✦ Legendary tier detected',
                          color: cl.legendary),
                    ),
                    const SizedBox(height: 28),
                    const HairlineRule(),
                    const SizedBox(height: 20),

                    // ── Credit packs ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EyebrowText.muted('Credit packs'),
                        Text(
                          '1 credit = 1 full scan',
                          style: GoogleFonts.dmSans(
                              fontSize: 10, color: cl.inkWhisper),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ..._packs.map((pack) {
                      final (id, label, price, perScan, isPopular, isBestValue) = pack;
                      final selected = selectedProduct == id;
                      return GestureDetector(
                        onTap: () =>
                            ref.read(selectedProductProvider.notifier).state = id,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: selected ? cl.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: selected ? cl.accent : cl.inkWhisper,
                              width: selected ? 1.0 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          label,
                                          style: GoogleFonts.dmSans(
                                              fontSize: 17, color: cl.ink),
                                        ),
                                        if (isPopular) ...[
                                          const SizedBox(width: 8),
                                          _PackBadge(
                                              label: 'POPULAR',
                                              color: cl.accent),
                                        ],
                                        if (isBestValue) ...[
                                          const SizedBox(width: 8),
                                          _PackBadge(
                                              label: 'BEST VALUE',
                                              color: cl.teal),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      perScan,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11, color: cl.inkWhisper),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                price,
                                style: GoogleFonts.dmSans(
                                  fontSize: 20,
                                  color: selected ? cl.accent : cl.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Buy credits button
                    GestureDetector(
                      onTap: (selectedProduct == null || _buyingCredits)
                          ? null
                          : _purchaseCredits,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: selectedProduct != null
                              ? cl.accent
                              : cl.surfaceH,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          boxShadow:
                              selectedProduct != null ? cl.buttonShadow : null,
                        ),
                        alignment: Alignment.center,
                        child: _buyingCredits
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 1.5),
                              )
                            : Text(
                                'Buy credits →',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        style:
                            GoogleFonts.dmSans(fontSize: 11, color: cl.scoreDown),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 20),
                    const HairlineRule(),
                    const SizedBox(height: 20),

                    // ── Pro subscription ────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cl.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                            color: cl.legendary.withValues(alpha: 0.35),
                            width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: cl.legendary.withValues(
                                alpha: cl.isDark ? 0.12 : 0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cl.legendary.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  'PRO',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: cl.legendary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cl.scoreDown.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                      color: cl.scoreDown.withValues(alpha: 0.3),
                                      width: 0.5),
                                ),
                                child: Text(
                                  'LIMITED OFFER',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: cl.scoreDown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Price row with strikethrough
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$6.99',
                                style: GoogleFonts.dmSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: cl.legendary,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$9.99',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        color: cl.inkWhisper,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: cl.inkWhisper,
                                      ),
                                    ),
                                    Text(
                                      '/ month',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: cl.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Feature list
                          ...[
                            'Unlimited scans',
                            'No ads',
                            'All rarities unlocked (Epic · Legendary)',
                            'Priority AI processing',
                          ].map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14, height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: cl.legendary.withValues(alpha: 0.15),
                                      ),
                                      child: Icon(Icons.check_rounded,
                                          size: 9, color: cl.legendary),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      feature,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13, color: cl.inkMuted),
                                    ),
                                  ],
                                ),
                              )),

                          const SizedBox(height: 14),

                          // Go Pro button
                          GestureDetector(
                            onTap: _buyingPro ? null : _purchasePro,
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: cl.legendary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                boxShadow: [
                                  BoxShadow(
                                    color: cl.legendary.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: _buyingPro
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 1.5),
                                    )
                                  : Text(
                                      'Go Pro →',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              ref.read(iapServiceProvider).restorePurchases(),
                          child: Text(
                            'Restore',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: cl.inkMuted,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text('  ·  ',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: cl.inkWhisper)),
                        Text(
                          'Privacy',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: cl.inkMuted,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
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

// ── Pack badge ─────────────────────────────────────────────────────────
class _PackBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PackBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: color,
        ),
      ),
    );
  }
}
