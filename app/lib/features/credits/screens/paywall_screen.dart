import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/credits_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProduct = ref.watch(selectedProductProvider);
    final productsAsync = ref.watch(iapProductsProvider);

    final packs = [
      (AppConstants.creditsProduct10, '10 credits', '\$0.99', false),
      (AppConstants.creditsProduct30, '30 credits', '\$2.99', true),
      (AppConstants.creditsProduct100, '100 credits', '\$6.99', false),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Unlock everything'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('✦', style: TextStyle(color: AppColors.legendary, fontSize: 40)),
              const SizedBox(height: 8),
              const Text('Unlock everything',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Reveal your Epic or Legendary animal match',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // Blurred tease card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.legendary.withOpacity(0.4), width: 1),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: const Text('🦚', style: TextStyle(fontSize: 60)),
                        ),
                        const Icon(Icons.lock, color: AppColors.legendary, size: 28),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Your animal match is hidden',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('✦ Legendary tier detected',
                        style: TextStyle(color: AppColors.legendary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Credit packs
              ...packs.map((pack) {
                final (id, label, price, popular) = pack;
                final selected = selectedProduct == id;
                return GestureDetector(
                  onTap: () => ref.read(selectedProductProvider.notifier).state = id,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: selected ? AppColors.purple : (popular ? AppColors.purple.withOpacity(0.3) : AppColors.border),
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: selected ? AppColors.purple : AppColors.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              if (popular)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.purple,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: const Text('Most popular', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                        ),
                        Text(price,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedProduct == null
                      ? null
                      : () async {
                          final products = await ref.read(iapProductsProvider.future);
                          final product = products.firstWhere((p) => p.id == selectedProduct, orElse: () => products.first);
                          final iapService = ref.read(iapServiceProvider);
                          await iapService.purchaseProduct(product);
                        },
                  child: const Text('Buy credits'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.purple, width: 1),
                  ),
                  child: const Column(
                    children: [
                      Text('Go Pro — \$4.99/month', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Unlimited · all features · no ads', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => ref.read(iapServiceProvider).restorePurchases(),
                    child: const Text('Restore purchase', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, decoration: TextDecoration.underline)),
                  ),
                  const Text('  ·  ', style: TextStyle(color: AppColors.textMuted)),
                  const Text('Privacy policy', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, decoration: TextDecoration.underline)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
