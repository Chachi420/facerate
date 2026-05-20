import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/animal_match.dart';
import '../../history/providers/history_provider.dart';
import '../../../widgets/masthead.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/folio_nav.dart';

class PokedexScreen extends ConsumerWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cl = Cl.of(context);
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: cl.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Masthead(
              left: const EyebrowText('Bestiary'),
              right: const EyebrowText('Archetypes'),
            ),
            Expanded(
              child: historyAsync.when(
                data: (scans) {
                  final Map<String, AnimalMatch> uniqueAnimals = {};
                  for (final scan in scans) {
                    uniqueAnimals.putIfAbsent(scan.animal.name, () => scan.animal);
                  }
                  final animals = uniqueAnimals.values.toList()
                    ..sort((a, b) =>
                        _rarityOrder(b.rarity).compareTo(_rarityOrder(a.rarity)));

                  if (animals.isEmpty) return const _EmptyState();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Row(
                          children: [
                            EyebrowText.muted('${animals.length} discovered'),
                            const Spacer(),
                            ..._rarityBadges(animals, cl),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: animals.length,
                          itemBuilder: (_, i) => _AnimalCard(animal: animals[i]),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: cl.accent, strokeWidth: 1.5),
                ),
                error: (_, __) =>
                    Center(child: EyebrowText.muted('Could not load collection')),
              ),
            ),
            FolioNav(
              currentIndex: 2,
              onTap: (i) {
                final routes = ['/', '/history', '/pokedex', '/settings'];
                if (i < routes.length) context.go(routes[i]);
              },
            ),
          ],
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

  List<Widget> _rarityBadges(List<AnimalMatch> animals, Cl cl) {
    return ['legendary', 'epic', 'rare'].map((r) {
      final count = animals.where((a) => a.rarity.toLowerCase() == r).length;
      if (count == 0) return const SizedBox.shrink();
      final color = cl.rarityColor(r);
      return Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Text(
          '$count ${r[0].toUpperCase()}',
          style: GoogleFonts.dmSans(fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      );
    }).toList();
  }
}

class _AnimalCard extends StatelessWidget {
  final AnimalMatch animal;
  const _AnimalCard({required this.animal});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final color = cl.rarityColor(animal.rarity);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cl.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(animal.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            animal.name,
            style: GoogleFonts.dmSans(
              fontSize: 15, fontWeight: FontWeight.w600, color: cl.ink,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Text(
              animal.rarity.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 10, letterSpacing: 1.2,
                fontWeight: FontWeight.w600, color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: cl.surface,
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: cl.inkWhisper, width: 0.5),
              ),
              child: const Center(child: Text('🦎', style: TextStyle(fontSize: 40))),
            ),
            const SizedBox(height: 20),
            Text(
              'No archetypes yet.',
              style: GoogleFonts.dmSans(
                fontSize: 22, fontWeight: FontWeight.w600, color: cl.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan your face to begin collecting archetypes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 15, color: cl.inkMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
