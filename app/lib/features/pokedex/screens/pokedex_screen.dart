import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
                  // Build unique animals with first-found date
                  final Map<String, AnimalMatch> uniqueAnimals = {};
                  final Map<String, DateTime> firstFound = {};
                  for (final scan in scans.reversed) {
                    // reversed = oldest first, so putIfAbsent keeps earliest
                    uniqueAnimals.putIfAbsent(scan.animal.name, () => scan.animal);
                    firstFound.putIfAbsent(scan.animal.name, () => scan.createdAt);
                  }
                  final animals = uniqueAnimals.values.toList()
                    ..sort((a, b) =>
                        _rarityOrder(b.rarity).compareTo(_rarityOrder(a.rarity)));

                  if (animals.isEmpty) return const _EmptyState();

                  // +1 for the locked "more to find" slot
                  final itemCount = animals.length + 1;

                  return Column(
                    children: [
                      // Progress header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${animals.length} discovered',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: cl.ink,
                                        ),
                                      ),
                                      Text(
                                        'Keep scanning to unlock more archetypes',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 12, color: cl.inkMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                ..._rarityBadges(animals, cl),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (animals.length / (animals.length + 3))
                                    .clamp(0.0, 1.0),
                                backgroundColor: cl.surfaceH,
                                valueColor:
                                    AlwaysStoppedAnimation(cl.accent),
                                minHeight: 4,
                              ),
                            ),
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
                            childAspectRatio: 0.88,
                          ),
                          itemCount: itemCount,
                          itemBuilder: (_, i) {
                            if (i == animals.length) {
                              return const _LockedSlot();
                            }
                            final animal = animals[i];
                            return _AnimalCard(
                              animal: animal,
                              firstFound: firstFound[animal.name],
                            );
                          },
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
  final DateTime? firstFound;
  const _AnimalCard({required this.animal, this.firstFound});

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    final color = cl.rarityColor(animal.rarity);
    final foundLabel = firstFound != null
        ? DateFormat('d MMM yy').format(firstFound!)
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
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
          Text(animal.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            animal.name,
            style: GoogleFonts.dmSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: cl.ink,
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
              border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Text(
              animal.rarity.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 9, letterSpacing: 1.2,
                fontWeight: FontWeight.w600, color: color,
              ),
            ),
          ),
          if (foundLabel != null) ...[
            const SizedBox(height: 5),
            Text(
              'Found $foundLabel',
              style: GoogleFonts.dmSans(fontSize: 9, color: cl.inkWhisper),
            ),
          ],
        ],
      ),
    );
  }
}

class _LockedSlot extends StatelessWidget {
  const _LockedSlot();

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cl.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: cl.inkWhisper.withValues(alpha: 0.3),
          width: 0.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cl.surfaceH,
              border: Border.all(color: cl.inkWhisper.withValues(alpha: 0.4), width: 0.5),
            ),
            child: Icon(Icons.lock_outline_rounded, size: 20, color: cl.inkWhisper),
          ),
          const SizedBox(height: 8),
          Text(
            'Unknown',
            style: GoogleFonts.dmSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: cl.inkWhisper),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan to discover',
            style: GoogleFonts.dmSans(fontSize: 10, color: cl.inkWhisper),
            textAlign: TextAlign.center,
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
