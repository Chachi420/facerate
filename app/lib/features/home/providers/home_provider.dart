import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/scan_result.dart';
import '../../../models/animal_match.dart';
import '../../auth/providers/auth_provider.dart';

final lastScanProvider = FutureProvider<ScanResult?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null || user.isAnonymous) return null;
      final firestoreService = ref.read(firestoreServiceProvider);
      final scans = await firestoreService.getScanHistory(user.uid, limit: 1);
      return scans.isEmpty ? null : scans.first;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final scanCountProvider = StateProvider<int>((ref) => 0);

class ArchetypeStats {
  final AnimalMatch? topAnimal;
  final int topCount;
  final int totalScans;
  final List<(AnimalMatch, int)> allAnimals;

  const ArchetypeStats({
    this.topAnimal,
    this.topCount = 0,
    this.totalScans = 0,
    this.allAnimals = const [],
  });
}

final archetypeStatsProvider = FutureProvider<ArchetypeStats>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null || user.isAnonymous) return const ArchetypeStats();
      final scans = await ref
          .read(firestoreServiceProvider)
          .getScanHistory(user.uid, limit: 50);
      if (scans.isEmpty) return const ArchetypeStats();

      final counts = <String, int>{};
      final animalMap = <String, AnimalMatch>{};
      for (final scan in scans) {
        counts[scan.animal.name] = (counts[scan.animal.name] ?? 0) + 1;
        animalMap[scan.animal.name] = scan.animal;
      }

      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topName = sorted.first.key;
      final allAnimals =
          sorted.map((e) => (animalMap[e.key]!, e.value)).toList();

      return ArchetypeStats(
        topAnimal: animalMap[topName],
        topCount: counts[topName]!,
        totalScans: scans.length,
        allAnimals: allAnimals,
      );
    },
    loading: () async => const ArchetypeStats(),
    error: (_, __) async => const ArchetypeStats(),
  );
});
