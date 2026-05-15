import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Scan history'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Text('All time', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (scans) {
          if (scans.isEmpty) return const _EmptyState();
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: scans.length,
            itemBuilder: (context, i) {
              final scan = scans[i];
              final prev = i + 1 < scans.length ? scans[i + 1] : null;
              return _ScanItem(scan: scan, previous: prev);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.purple)),
        error: (_, __) => const Center(child: Text('Could not load history.', style: TextStyle(color: AppColors.textSecondary))),
      ),
    );
  }
}

class _ScanItem extends StatelessWidget {
  final ScanResult scan;
  final ScanResult? previous;

  const _ScanItem({required this.scan, this.previous});

  @override
  Widget build(BuildContext context) {
    final delta = previous != null ? scan.score - previous!.score : null;
    final animalColor = AppColors.rarityColor(scan.animal.rarity);
    final dateStr = DateFormat('MMM d, yyyy').format(scan.createdAt);

    return GestureDetector(
      onTap: () => context.push('/summary', extra: scan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Text(scan.animal.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.archetype, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  Text('${scan.animal.name} · ${scan.animal.rarity}',
                      style: TextStyle(color: animalColor, fontSize: 12)),
                  Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(scan.score.toStringAsFixed(1),
                    style: const TextStyle(color: AppColors.purpleLight, fontSize: 18, fontWeight: FontWeight.bold)),
                if (delta != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        delta > 0 ? Icons.arrow_upward : (delta < 0 ? Icons.arrow_downward : Icons.remove),
                        color: delta > 0 ? AppColors.tealLight : (delta < 0 ? AppColors.red : AppColors.textMuted),
                        size: 12,
                      ),
                      Text(
                        delta == 0 ? '—' : '${delta.abs().toStringAsFixed(1)}',
                        style: TextStyle(
                          color: delta > 0 ? AppColors.tealLight : (delta < 0 ? AppColors.red : AppColors.textMuted),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 60),
          const SizedBox(height: 16),
          const Text('No scans yet', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Scan your face to get started', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/scan'),
            child: const Text('Scan now'),
          ),
        ],
      ),
    );
  }
}
