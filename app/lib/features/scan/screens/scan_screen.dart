import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/image_utils.dart';
import '../providers/scan_provider.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _picker = ImagePicker();
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 1200, imageQuality: 90);
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }
      final file = File(picked.path);
      final compressed = await compressImage(file);
      final mood = ref.read(selectedMoodProvider);
      final mode = ref.read(selectedModeProvider);
      if (mounted) {
        context.push('/loading', extra: {'imageFile': compressed, 'mood': mood, 'mode': mode});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not access camera or gallery. Please grant permission.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = ref.watch(selectedMoodProvider);
    final mode = ref.watch(selectedModeProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Scan your face'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Camera preview placeholder (real camera needs platform setup)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.large),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: AppColors.textMuted, size: 60),
                                  SizedBox(height: 12),
                                  Text('Tap capture or pick from gallery',
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                                ],
                              ),
                            ),
                            // Corner brackets
                            ..._buildCornerBrackets(),
                            // Oval face guide
                            Center(
                              child: Container(
                                width: 160,
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(80),
                                  border: Border.all(
                                    color: AppColors.purple.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 24,
                              left: 0,
                              right: 0,
                              child: Text('Align face in frame',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TipChip(icon: '☀', label: 'Good lighting'),
                        const SizedBox(width: 8),
                        _TipChip(icon: '👁', label: 'Face forward'),
                        const SizedBox(width: 8),
                        _TipChip(icon: '✨', label: 'No filter'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('How are you feeling?',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MoodButton(emoji: '😴', value: 'tired', current: mood, onTap: (v) => ref.read(selectedMoodProvider.notifier).state = v),
                        const SizedBox(width: 16),
                        _MoodButton(emoji: '😊', value: 'good', current: mood, onTap: (v) => ref.read(selectedMoodProvider.notifier).state = v),
                        const SizedBox(width: 16),
                        _MoodButton(emoji: '🔥', value: 'energized', current: mood, onTap: (v) => ref.read(selectedMoodProvider.notifier).state = v),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Tone', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            emoji: '🔥',
                            label: 'Roast Me',
                            value: 'honest',
                            current: mode,
                            onTap: (v) => ref.read(selectedModeProvider.notifier).state = v,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeButton(
                            emoji: '🤍',
                            label: 'Be Nice',
                            value: 'nice',
                            current: mode,
                            onTap: (v) => ref.read(selectedModeProvider.notifier).state = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleButton(
                    icon: Icons.photo_library_outlined,
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.purple, width: 4),
                      ),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2))
                          : Container(
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  _CircleButton(icon: Icons.flip_camera_android, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 24.0;
    const thickness = 2.0;
    const color = AppColors.purple;

    Widget bracket(Alignment align, bool flipX, bool flipY) {
      return Positioned(
        top: flipY ? null : 16,
        bottom: flipY ? 16 : null,
        left: flipX ? null : 16,
        right: flipX ? 16 : null,
        child: Transform.scale(
          scaleX: flipX ? -1 : 1,
          scaleY: flipY ? -1 : 1,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CornerPainter(color: color, thickness: thickness),
            ),
          ),
        ),
      );
    }

    return [
      bracket(Alignment.topLeft, false, false),
      bracket(Alignment.topRight, true, false),
      bracket(Alignment.bottomLeft, false, true),
      bracket(Alignment.bottomRight, true, true),
    ];
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;

  _CornerPainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TipChip extends StatelessWidget {
  final String icon;
  final String label;
  const _TipChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String emoji;
  final String value;
  final String current;
  final void Function(String) onTap;

  const _MoodButton({required this.emoji, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Opacity(
        opacity: selected ? 1.0 : 0.4,
        child: Text(emoji, style: const TextStyle(fontSize: 32)),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String current;
  final void Function(String) onTap;

  const _ModeButton({required this.emoji, required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.purple.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? AppColors.purple : AppColors.border,
            width: selected ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? AppColors.purpleLight : AppColors.textSecondary, fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}
