import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_utils.dart';
import '../../../models/scan_result.dart';

class ScoreCardScreen extends StatefulWidget {
  final ScanResult result;

  const ScoreCardScreen({super.key, required this.result});

  @override
  State<ScoreCardScreen> createState() => _ScoreCardScreenState();
}

class _ScoreCardScreenState extends State<ScoreCardScreen> {
  final _cardKey = GlobalKey();

  Future<Uint8List?> _capture() async {
    final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _share() async {
    final bytes = await _capture();
    if (bytes == null) return;
    await shareImage(bytes,
        'My FaceRate score: ${widget.result.score.toStringAsFixed(1)}/10 — ${widget.result.archetype} · ${widget.result.animal.emoji}${widget.result.animal.name} · facerate.app');
  }

  Future<void> _save() async {
    final bytes = await _capture();
    if (bytes == null) return;
    await saveImageToGallery(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Score card'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: RepaintBoundary(
                  key: _cardKey,
                  child: _ScoreCard(result: widget.result),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share to Instagram'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Save to camera roll'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

class _ScoreCard extends StatelessWidget {
  final ScanResult result;

  const _ScoreCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(result.createdAt);
    final animalColor = AppColors.rarityColor(result.animal.rarity);

    final statEntries = result.features.entries.take(6).toList();

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'face', style: TextStyle(color: AppColors.textDim)),
                      TextSpan(text: 'rate', style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Text(dateStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 16),
            // Archetype
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (i) => Container(
                width: 4, height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i.isEven ? AppColors.purple : AppColors.textDim,
                ),
              )),
            ),
            const SizedBox(height: 8),
            const Text('FACE ARCHETYPE',
                style: TextStyle(color: AppColors.textMuted, fontSize: 9, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(result.archetype,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            // Animal
            const SizedBox(height: 4),
            Text('${result.animal.emoji} ${result.animal.name}',
                style: TextStyle(color: animalColor, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            // Score row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: result.score.toStringAsFixed(1),
                          style: const TextStyle(color: AppColors.purpleLight, fontSize: 48, fontWeight: FontWeight.bold)),
                      const TextSpan(text: '/10', style: TextStyle(color: AppColors.textDim, fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 40, color: AppColors.border),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top ${result.percentile}%',
                        style: const TextStyle(color: AppColors.tealLight, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('this week', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  ],
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 24),
            // 6-stat grid
            if (statEntries.isNotEmpty)
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.0,
                children: statEntries.map((e) {
                  return Container(
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border, width: 0.5)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.value.score.toStringAsFixed(1),
                            style: const TextStyle(color: AppColors.purple, fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(e.key.toUpperCase(),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 7, letterSpacing: 0.5)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            // Celeb row
            Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: AppColors.pink.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: AppColors.pink, size: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Celebrity lookalike', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                      Text(result.celebrityLookalike.name,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${result.celebrityLookalike.matchPercentage}%',
                    style: const TextStyle(color: AppColors.pink, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            // Trait pills
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: result.strengths.take(3).map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
                ),
                child: Text(t, style: const TextStyle(color: AppColors.purpleLight, fontSize: 9)),
              )).toList(),
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('facerate.app', style: TextStyle(color: AppColors.textDim, fontSize: 9)),
                const SizedBox(width: 8),
                const Icon(Icons.qr_code, color: AppColors.textDim, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
