import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/animal_match.dart';
import '../../history/providers/history_provider.dart';

class PokedexScreen extends ConsumerWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Animal Collection'),
      ),
      body: historyAsync.when(
        data: (scans) {
          final Map<String, AnimalMatch> uniqueAnimals = {};
          for (final scan in scans) {
            uniqueAnimals.putIfAbsent(scan.animal.name, () => scan.animal);
          }
          final animals = uniqueAnimals.values.toList()
            ..sort((a, b) => _rarityOrder(b.rarity).compareTo(_rarityOrder(a.rarity)));

          if (animals.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦎', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 16),
                    Text('No animals yet', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Scan your face to discover your first animal match', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Text('${animals.length} discovered', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const Spacer(),
                    ..._rarityBadges(animals),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.05,
                  ),
                  itemCount: animals.length,
                  itemBuilder: (_, i) => _AnimalCard(animal: animals[i]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.purple)),
        error: (_, __) => const Center(
          child: Text('Could not load collection', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  int _rarityOrder(String rarity) => switch (rarity.toLowerCase()) {
        'legendary' => 5,
        'epic' => 4,
        'rare' => 3,
        'uncommon' => 2,
        _ => 1,
      };

  List<Widget> _rarityBadges(List<AnimalMatch> animals) {
    return ['Legendary', 'Epic', 'Rare'].map((r) {
      final count = animals.where((a) => a.rarity.toLowerCase() == r.toLowerCase()).length;
      if (count == 0) return const SizedBox.shrink();
      final color = AppColors.rarityColor(r);
      return Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Text('$count ${r[0]}', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
    }).toList();
  }
}

class _AnimalCard extends StatelessWidget {
  final AnimalMatch animal;
  const _AnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.rarityColor(animal.rarity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.75),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(animal.emoji, style: const TextStyle(fontSize: 38)),
          const SizedBox(height: 8),
          Text(
            animal.name,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(animal.rarity, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
