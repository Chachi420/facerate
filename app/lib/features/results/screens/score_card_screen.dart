import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_utils.dart';
import '../../../models/scan_result.dart';
import '../../../widgets/eyebrow_text.dart';
import '../../../widgets/hairline_rule.dart';

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
        'My Mirror score: ${widget.result.score.toStringAsFixed(1)}/10 — ${widget.result.archetype}');
  }

  Future<void> _save() async {
    final bytes = await _capture();
    if (bytes == null) return;
    await saveImageToGallery(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final cl = Cl.of(context);
    return Scaffold(
      backgroundColor: cl.canvas,
      appBar: AppBar(
        backgroundColor: cl.canvas,
        leading: BackButton(
          color: cl.inkMuted,
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        title: EyebrowText('Share card'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HairlineRule(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _ScoreCard(result: widget.result),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: cl.rule, width: 1),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        alignment: Alignment.center,
                        child: Text('Save image',
                          style: GoogleFonts.dmSans(fontSize: 13, color: cl.ink)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _share,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: cl.accent,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          boxShadow: cl.buttonShadow,
                        ),
                        alignment: Alignment.center,
                        child: Text('Share →',
                          style: GoogleFonts.dmSans(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
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

// _ScoreCard intentionally always dark — it's a social share artifact
class _ScoreCard extends StatelessWidget {
  final ScanResult result;
  const _ScoreCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy').format(result.createdAt);
    final animalColor = AppColors.rarityColor(result.animal.rarity);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF110F0E),
        border: Border.all(color: const Color(0x47E6E0D4), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('mirror',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: const Color(0x47E6E0D4))),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: animalColor.withValues(alpha: 0.27),
                      blurRadius: 28, spreadRadius: 10,
                    )],
                  ),
                  child: Center(child: Text(result.animal.emoji, style: const TextStyle(fontSize: 72))),
                ),
                const SizedBox(height: 16),
                Text(
                  result.score.toStringAsFixed(1),
                  style: GoogleFonts.dmSans(
                    fontSize: 104,
                    color: AppColors.accent, letterSpacing: -0.04 * 104, height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.animal.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    color: const Color(0xFFE6E0D4), letterSpacing: -0.02 * 28,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1916),
                    border: Border.all(color: animalColor, width: 0.5),
                  ),
                  child: Text(
                    result.animal.rarity.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 10, fontWeight: FontWeight.w500,
                      letterSpacing: 1.6, color: animalColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  result.archetype,
                  style: GoogleFonts.dmSans(
                    fontSize: 15, color: const Color(0x8BE6E0D4)),
                ),
                const SizedBox(height: 8),
                Text(
                  'TOP ${100 - result.percentile}% GLOBALLY',
                  style: GoogleFonts.dmSans(
                    fontSize: 10, letterSpacing: 1.8, color: AppColors.teal),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr,
                      style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0x47E6E0D4))),
                    Text('mirror.app',
                      style: GoogleFonts.dmSans(fontSize: 9, color: const Color(0x47E6E0D4))),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Container(height: 4, color: animalColor),
        ],
      ),
    );
  }
}
